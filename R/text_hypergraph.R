# Constructor: corpus -> weighted document-word hypergraph.
#
# The bipartite document-word structure becomes a hypergraph in either
# orientation (Hayashi et al. 2020 analyze documents as vertices with words as
# hyperedges; HyperGAT-style construction uses the reverse). All spectral and
# structural machinery is delegated to Nestimate; this file owns tokenization,
# weighting, and the tidy text-facing surface.

# Tokenize a character vector into a list of word vectors: lowercase
# (optionally), normalize curly apostrophes (U+2019, written escaped for ASCII-clean source) so possessives stay one
# token, split on non-letter runs, trim edge apostrophes, drop empties.
.thg_tokenize <- function(text, lowercase) {
  if (isTRUE(lowercase)) {
    text <- tolower(text)
  }
  text <- gsub("\u2019", "'", text)
  tokens <- strsplit(text, "[^[:alpha:]']+")
  lapply(tokens, \(x) {
    x <- gsub("^'+|'+$", "", x)
    x[nzchar(x)]
  })
}

#' Build a weighted hypergraph from a text corpus
#'
#' Tokenizes a corpus (base R, deterministic), counts document-word
#' occurrences, and builds a weighted hypergraph through
#' [Nestimate::bipartite_groups()]. With `nodes = "doc"` (the default),
#' documents are the vertices and each word is a hyperedge connecting the
#' documents it occurs in -- the orientation used for document clustering and
#' transductive document classification (Hayashi et al. 2020). With
#' `nodes = "word"`, words are the vertices and each document is a hyperedge
#' (the HyperGAT orientation).
#'
#' Tokens are maximal runs of letters (with internal apostrophes); digits and
#' punctuation are separators. `weight = "tfidf"` uses the smoothed formula
#' `tf * (log((1 + N) / (1 + df)) + 1)` with `tf` the raw count, `N` the
#' number of documents, and `df` the word's document frequency -- the
#' `smooth_idf` variant of Manning, Raghavan and Schutze (2008) as popularized
#' by scikit-learn, which is never zero and so never silently disconnects a
#' vertex.
#'
#' @param x A character vector of documents, or a `data.frame` containing a
#'   text column.
#' @param column Name of the text column when `x` is a `data.frame`.
#' @param id Optional name of an ID column when `x` is a `data.frame`; its
#'   values (unique, non-missing) become the document identifiers. Defaults to
#'   the names of `x` when it is a named character vector, otherwise
#'   `"doc_1"`, `"doc_2"`, ...
#' @param nodes Which entity is the vertex set: `"doc"` (default) or
#'   `"word"`.
#' @param weight Term weighting: `"n"` (raw count, default) or `"tfidf"`
#'   (smoothed tf-idf, see Details).
#' @param stop_words Optional character vector of words to drop after
#'   tokenization (compared after lowercasing when `lowercase = TRUE`).
#' @param min_count Minimum total corpus count for a word to be kept
#'   (default `1L`, keep everything).
#' @param lowercase Lowercase the text before tokenization (default `TRUE`).
#'
#' @return An object of class `c("text_hypergraph", "net_hypergraph")` -- a
#'   [Nestimate::bipartite_groups()] hypergraph accepted by every Nestimate
#'   hypergraph verb and by [hg_measures()], [hg_centrality()],
#'   [hg_cluster()], and [hg_classify()] -- with a `text` field recording the
#'   corpus tables. Use [as.data.frame.text_hypergraph()] for the tidy
#'   document-word weight table, and its `what` argument for the document and
#'   vocabulary tables.
#'
#' @section Conditions: Raises `thg_bad_input` (broken argument contract),
#'   `thg_empty_corpus` (no document survives tokenization and filtering), and
#'   warns with `thg_dropped_documents` when some documents end up empty.
#'
#' @references
#' Hayashi, K., Aksoy, S. G., Park, C. H., & Park, H. (2020). Hypergraph
#' random walks, Laplacians, and clustering. *CIKM 2020*.
#' \doi{10.1145/3340531.3412034}
#'
#' Manning, C. D., Raghavan, P., & Schutze, H. (2008). *Introduction to
#' Information Retrieval*. Cambridge University Press.
#'
#' @examples
#' corpus <- c(
#'   cooking_1 = "Simmer the soup with onions and carrots",
#'   cooking_2 = "This soup recipe needs a pinch of salt",
#'   space_1   = "The telescope revealed a distant galaxy",
#'   space_2   = "Astronomers aimed the telescope at the night sky"
#' )
#' hg <- text_hypergraph(corpus, weight = "tfidf")
#' hg
#' as.data.frame(hg)
#' as.data.frame(hg, what = "vocabulary")
#' @export
text_hypergraph <- function(x, column = NULL, id = NULL,
                            nodes = c("doc", "word"),
                            weight = c("n", "tfidf"),
                            stop_words = NULL,
                            min_count = 1L,
                            lowercase = TRUE) {
  nodes <- match.arg(nodes)
  weight <- match.arg(weight)
  stopifnot(
    "`x` must be a character vector or a data.frame" =
      is.character(x) || is.data.frame(x),
    "`stop_words` must be NULL or a character vector" =
      is.null(stop_words) || is.character(stop_words),
    "`min_count` must be a single count >= 1" =
      length(min_count) == 1L && is.finite(min_count) && min_count >= 1,
    "`lowercase` must be TRUE or FALSE" =
      isTRUE(lowercase) || isFALSE(lowercase)
  )

  if (is.data.frame(x)) {
    if (is.null(column) || !is.character(column) || length(column) != 1L ||
        !column %in% names(x)) {
      stop(errorCondition(
        "when `x` is a data.frame, `column` must name one of its columns",
        class = "thg_bad_input", call = NULL
      ))
    }
    text <- as.character(x[[column]])
    if (is.null(id)) {
      doc_id <- sprintf("doc_%d", seq_len(nrow(x)))
    } else {
      if (!is.character(id) || length(id) != 1L || !id %in% names(x)) {
        stop(errorCondition(
          "`id` must name a column of `x`",
          class = "thg_bad_input", call = NULL
        ))
      }
      doc_id <- as.character(x[[id]])
      if (anyNA(doc_id) || anyDuplicated(doc_id) > 0L) {
        stop(errorCondition(
          sprintf("`%s` must hold unique, non-missing document IDs", id),
          class = "thg_bad_input", call = NULL
        ))
      }
    }
    meta <- x[setdiff(names(x), c(column, id))]
  } else {
    text <- x
    doc_id <- names(x) %||% sprintf("doc_%d", seq_along(x))
    if (anyNA(doc_id) || anyDuplicated(doc_id) > 0L || !all(nzchar(doc_id))) {
      stop(errorCondition(
        "names of `x` must be unique, non-empty document IDs",
        class = "thg_bad_input", call = NULL
      ))
    }
    meta <- NULL
  }
  text[is.na(text)] <- ""

  tokens <- .thg_tokenize(text, lowercase = lowercase)
  if (!is.null(stop_words)) {
    tokens <- lapply(tokens, \(x) x[!x %in% stop_words])
  }

  words <- unlist(tokens, use.names = FALSE) %||% character(0)
  if (length(words) == 0L) {
    stop(errorCondition(
      "no document contains any token after tokenization and filtering",
      class = "thg_empty_corpus", call = NULL
    ))
  }
  long <- data.frame(
    doc = rep(doc_id, lengths(tokens)),
    word = words,
    n = 1L
  )
  counts <- stats::aggregate(n ~ doc + word, data = long, FUN = sum)

  if (min_count > 1L) {
    total <- tapply(counts$n, counts$word, sum)
    keep <- names(total)[total >= min_count]
    counts <- counts[counts$word %in% keep, , drop = FALSE]
    if (nrow(counts) == 0L) {
      stop(errorCondition(
        sprintf("no word reaches `min_count = %d`", as.integer(min_count)),
        class = "thg_empty_corpus", call = NULL
      ))
    }
  }

  kept_docs <- doc_id[doc_id %in% counts$doc]
  dropped <- setdiff(doc_id, kept_docs)
  if (length(dropped) > 0L) {
    warning(warningCondition(
      sprintf(
        "%d document(s) had no remaining tokens and were dropped: %s",
        length(dropped), paste(dropped, collapse = ", ")
      ),
      class = "thg_dropped_documents"
    ))
  }

  n_docs <- length(kept_docs)
  doc_freq <- tapply(counts$doc, counts$word, \(d) length(unique(d)))
  vocabulary <- data.frame(
    word = names(doc_freq),
    n = as.integer(tapply(counts$n, counts$word, sum)),
    doc_freq = as.integer(doc_freq)
  )
  vocabulary <- vocabulary[order(vocabulary$word), , drop = FALSE]
  rownames(vocabulary) <- NULL

  if (identical(weight, "tfidf")) {
    idf <- log((1 + n_docs) / (1 + doc_freq)) + 1
    vocabulary$idf <- as.numeric(idf[vocabulary$word])
    counts$w <- counts$n * as.numeric(idf[counts$word])
  } else {
    counts$w <- as.numeric(counts$n)
  }
  stopifnot("internal: non-positive weights produced" = all(counts$w > 0))

  hg <- if (identical(nodes, "doc")) {
    Nestimate::bipartite_groups(counts, player = "doc", group = "word",
                                weight = "w")
  } else {
    Nestimate::bipartite_groups(counts, player = "word", group = "doc",
                                weight = "w")
  }

  n_tokens <- tapply(counts$n, counts$doc, sum)
  n_types <- tapply(counts$word, counts$doc, \(w) length(unique(w)))
  documents <- data.frame(
    doc = kept_docs,
    n_tokens = as.integer(n_tokens[kept_docs]),
    n_types = as.integer(n_types[kept_docs])
  )
  if (!is.null(meta) && ncol(meta) > 0L) {
    meta_kept <- meta[match(kept_docs, doc_id), , drop = FALSE]
    rownames(meta_kept) <- NULL
    documents <- cbind(documents, meta_kept)
  }
  rownames(documents) <- NULL

  weights <- data.frame(doc = counts$doc, word = counts$word,
                        n = counts$n, weight = counts$w)
  weights <- weights[order(weights$doc, weights$word), , drop = FALSE]
  rownames(weights) <- NULL

  hg$text <- list(
    documents = documents,
    vocabulary = vocabulary,
    weights = weights,
    nodes = nodes,
    weighting = weight,
    n_dropped = length(dropped)
  )
  class(hg) <- c("text_hypergraph", class(hg))
  hg
}

#' Print a text hypergraph
#'
#' @param x A [text_hypergraph()] object.
#' @param ... Passed to the underlying `net_hypergraph` print method.
#' @return `x`, invisibly.
#' @export
print.text_hypergraph <- function(x, ...) {
  cat(sprintf(
    "Text hypergraph: %d documents, %d words (%s as nodes, weight = %s)\n",
    nrow(x$text$documents), nrow(x$text$vocabulary),
    if (identical(x$text$nodes, "doc")) "documents" else "words",
    x$text$weighting
  ))
  size <- as.integer(sub("size_", "", names(x$size_distribution)))
  sizes <- rep(size, x$size_distribution)
  cat(sprintf(
    "Hyperedges: %d (%s); sizes %d-%d, median %g\n",
    x$n_hyperedges,
    if (identical(x$text$nodes, "doc")) "words" else "documents",
    min(sizes), max(sizes), stats::median(sizes)
  ))
  invisible(x)
}

#' Tidy tables of a text hypergraph
#'
#' @param x A [text_hypergraph()] object.
#' @param row.names,optional Ignored; present for S3 consistency.
#' @param what Which table: `"weights"` (default; one row per document-word
#'   pair with `doc`, `word`, `n`, `weight`), `"documents"` (one row per
#'   document with `doc`, `n_tokens`, `n_types` plus any metadata columns
#'   carried from the input), or `"vocabulary"` (one row per word with
#'   `word`, `n`, `doc_freq`, and `idf` under tf-idf weighting).
#' @param ... Unused.
#' @return A base `data.frame` as described under `what`.
#' @examples
#' hg <- text_hypergraph(c(a = "salt and soup", b = "soup and stars"))
#' as.data.frame(hg)
#' as.data.frame(hg, what = "documents")
#' @export
as.data.frame.text_hypergraph <- function(x, row.names = NULL,
                                          optional = FALSE,
                                          what = c("weights", "documents",
                                                   "vocabulary"),
                                          ...) {
  what <- match.arg(what)
  x$text[[what]]
}
