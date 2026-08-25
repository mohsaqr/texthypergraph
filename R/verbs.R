# Tidy analysis verbs. Each delegates to the matching Nestimate engine and
# returns a base data.frame; no numerical machinery lives in this package.

.thg_check_hg <- function(hg) {
  if (!inherits(hg, "net_hypergraph")) {
    stop(errorCondition(
      "`hg` must be a hypergraph from text_hypergraph() or Nestimate",
      class = "thg_bad_input", call = NULL
    ))
  }
  invisible(hg)
}

#' Structural measures of a hypergraph, as tidy tables
#'
#' Delegates to [Nestimate::hypergraph_measures()] and returns the requested
#' slice as a tidy data.frame.
#'
#' @param hg A [text_hypergraph()] (or any Nestimate `net_hypergraph`).
#' @param what Which table: `"nodes"` (default; one row per node with
#'   `hyperdegree`, `strength`, `max_edge_size`), `"edges"` (one row per
#'   hyperedge with its `size`), `"overlap"` (one row per hyperedge pair with
#'   `overlap`, `overlap_coefficient`, `jaccard`), or `"summary"` (one row per
#'   scalar measure).
#' @return A base `data.frame`, one row per node, edge, edge pair, or measure
#'   according to `what`.
#' @examples
#' hg <- text_hypergraph(c(
#'   a = "salt and soup and onions",
#'   b = "soup and salt",
#'   c = "stars and sky"
#' ))
#' hg_measures(hg)
#' hg_measures(hg, what = "summary")
#' @export
hg_measures <- function(hg, what = c("nodes", "edges", "overlap", "summary")) {
  .thg_check_hg(hg)
  what <- match.arg(what)
  if (.thg_is_sparse(hg)) {
    return(.thg_sparse_measures(hg, what))
  }
  m <- Nestimate::hypergraph_measures(hg)
  edges <- colnames(hg$incidence)
  switch(what,
    nodes = data.frame(
      node = names(m$hyperdegree),
      hyperdegree = as.integer(m$hyperdegree),
      strength = as.numeric(m$node_strength),
      max_edge_size = as.integer(m$max_edge_size),
      row.names = NULL
    ),
    edges = data.frame(
      edge = edges,
      size = as.integer(m$edge_sizes),
      row.names = NULL
    ),
    overlap = {
      pair <- which(upper.tri(m$edge_pairwise_overlap), arr.ind = TRUE)
      data.frame(
        edge_1 = edges[pair[, "row"]],
        edge_2 = edges[pair[, "col"]],
        overlap = as.numeric(m$edge_pairwise_overlap[pair]),
        overlap_coefficient = as.numeric(m$overlap_coefficient[pair]),
        jaccard = as.numeric(m$jaccard[pair]),
        row.names = NULL
      )
    },
    summary = data.frame(
      measure = c("n_nodes", "n_hyperedges", "density", "avg_edge_size",
                  "pairwise_participation"),
      value = c(m$n_nodes, m$n_hyperedges, m$density, m$avg_edge_size,
                m$pairwise_participation),
      row.names = NULL
    )
  )
}

#' Hypergraph node centralities, as a tidy table
#'
#' Delegates to [Nestimate::hypergraph_centrality()]: clique-expansion
#' eigenvector centrality and the tensor Z- and H-eigenvector centralities.
#'
#' @param hg A [text_hypergraph()] (or any Nestimate `net_hypergraph`).
#' @param type Centralities to compute; any of `"clique"`, `"Z"`, `"H"`
#'   (default: all three).
#' @param sort_by Optional centrality name to sort by, descending (ties broken
#'   by node name); default keeps node order.
#' @param n Return only the first `n` rows after sorting (default all) --
#'   e.g. `sort_by = "clique", n = 10` for the ten most central nodes.
#' @param max_iter,tol,normalize Passed to
#'   [Nestimate::hypergraph_centrality()].
#' @return A base `data.frame`, one row per node (or the `n` requested rows),
#'   with one column per requested centrality.
#' @examples
#' hg <- text_hypergraph(c(
#'   a = "salt and soup and onions",
#'   b = "soup and salt",
#'   c = "stars and salt"
#' ))
#' hg_centrality(hg, type = "clique")
#' @export
hg_centrality <- function(hg, type = c("clique", "Z", "H"),
                          sort_by = NULL, n = Inf,
                          max_iter = 1000L, tol = 1e-8, normalize = TRUE) {
  .thg_check_hg(hg)
  type <- match.arg(type, several.ok = TRUE)
  if (.thg_is_sparse(hg)) {
    stop(errorCondition(
      "tensor centralities need the dense representation; use hg_pagerank() at scale",
      class = "thg_sparse_unsupported", call = NULL
    ))
  }
  stopifnot(
    "`n` must be a single count >= 1" =
      length(n) == 1L && (is.infinite(n) || (is.finite(n) && n >= 1))
  )
  cen <- Nestimate::hypergraph_centrality(
    hg, type = type, max_iter = max_iter, tol = tol, normalize = normalize
  )
  out <- data.frame(node = names(cen[[1L]]), row.names = NULL)
  values <- lapply(cen, \(v) unname(as.numeric(v)))
  out <- cbind(out, values)
  if (!is.null(sort_by)) {
    sort_by <- match.arg(sort_by, choices = type)
    out <- out[order(-out[[sort_by]], out$node), , drop = FALSE]
    rownames(out) <- NULL
  }
  if (is.finite(n) && n < nrow(out)) {
    out <- out[seq_len(n), , drop = FALSE]
  }
  out
}

#' Spectral clustering of a hypergraph, as a tidy table
#'
#' Calls the in-package [hypergraph_cluster()] engine (Zhou et al. 2006 normalized
#' Laplacian, or the Hayashi et al. 2020 random-walk Laplacian with
#' edge-dependent vertex weights -- the natural choice for tf-idf-weighted
#' text hypergraphs).
#'
#' @param hg A [text_hypergraph()] (or any Nestimate `net_hypergraph`).
#' @param k Number of clusters (explicit by design; there is no correct
#'   default).
#' @param type `"zhou"` or `"random_walk"`, as in
#'   [hypergraph_cluster()].
#' @param seed Random seed passed to the engine's k-means step; set it for a
#'   reproducible partition.
#' @param nstart Number of k-means starts (default `25L`).
#' @return A base `data.frame`, one row per node, with columns `node` and
#'   `cluster`.
#' @examples
#' hg <- text_hypergraph(c(
#'   cooking_1 = "simmer the soup with onions and carrots",
#'   cooking_2 = "this soup recipe needs salt on a cold night",
#'   space_1 = "the telescope revealed a distant galaxy and stars",
#'   space_2 = "astronomers aimed the telescope at the stars all night"
#' ), stop_words = c("the", "with", "and", "a", "this", "at", "on", "all"))
#' hg_cluster(hg, k = 2, type = "random_walk", seed = 1)
#' @export
hg_cluster <- function(hg, k, type = c("zhou", "random_walk"), seed = NULL,
                       nstart = 25L) {
  .thg_check_hg(hg)
  type <- match.arg(type)
  fit <- if (.thg_is_sparse(hg)) {
    .thg_sparse_cluster(hg, k = k, type = type, edge_weights = NULL,
                        nstart = nstart, seed = seed)
  } else {
    hypergraph_cluster(hg, k = k, type = type, seed = seed,
                       nstart = nstart)
  }
  out <- fit$clusters
  rownames(out) <- NULL
  out
}

#' Transductive label spreading on a hypergraph, as a tidy table
#'
#' Calls the in-package [hypergraph_transduction()] engine (Zhou et al. 2006):
#' labels known for a few nodes spread over the hypergraph structure to
#' classify every node.
#'
#' @param hg A [text_hypergraph()] (or any Nestimate `net_hypergraph`).
#' @param labels Named character vector: names are node identifiers (documents
#'   under `nodes = "doc"`), values are their known class labels.
#' @param xi,type Passed to [hypergraph_transduction()].
#' @param normalization Decision rule for turning spread scores into
#'   predictions: `"none"` (default, the raw Zhou 2006 argmax) or
#'   `"class_mass"` (class-mass normalization, Zhu et al. 2003). Use
#'   `"class_mass"` when the labeled seeds are class-imbalanced -- the raw
#'   rule can collapse every prediction onto the majority class.
#' @return A base `data.frame`, one row per node, with columns `node`,
#'   `label` (the given label or `NA`), `predicted`, `score`, and `margin`.
#' @examples
#' hg <- text_hypergraph(c(
#'   cooking_1 = "simmer the soup with onions and carrots",
#'   cooking_2 = "this soup recipe needs salt on a cold night",
#'   space_1 = "the telescope revealed a distant galaxy and stars",
#'   space_2 = "astronomers aimed the telescope at the stars all night"
#' ), stop_words = c("the", "with", "and", "a", "this", "at", "on", "all"))
#' hg_classify(hg, labels = c(cooking_1 = "cooking", space_1 = "space"))
#' @export
hg_classify <- function(hg, labels, xi = 0.99,
                        type = c("zhou", "random_walk"),
                        normalization = c("none", "class_mass")) {
  .thg_check_hg(hg)
  type <- match.arg(type)
  normalization <- match.arg(normalization)
  fit <- if (.thg_is_sparse(hg)) {
    .thg_sparse_transduction(hg, labels = labels, xi = xi, type = type,
                             edge_weights = NULL,
                             normalization = normalization)
  } else {
    hypergraph_transduction(hg, labels = labels, xi = xi, type = type,
                            normalization = normalization)
  }
  out <- fit$predictions
  rownames(out) <- NULL
  out
}
