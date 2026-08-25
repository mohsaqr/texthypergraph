# Windowed construction: hand-computed windows, conservation invariant, and
# the w = 2 reduction to Nestimate::wtna() co-occurrence counts.

test_that("sliding windows are hand-computed correctly", {
  hg <- text_hypergraph(c(d = "a b c a b"), construction = "window",
                        window = 2)
  expect_identical(
    as.data.frame(hg),
    data.frame(
      edge = c("a+b", "a+b", "a+c", "a+c", "b+c", "b+c"),
      word = c("a", "b", "a", "c", "b", "c"),
      weight = c(2, 2, 1, 1, 1, 1)
    )
  )
  expect_identical(hg$text$n_windows, 4L)
})

test_that("tumbling windows include the trailing partial chunk", {
  hg <- text_hypergraph(c(d = "a b c a b"), construction = "window",
                        window = 2, window_mode = "tumbling")
  expect_identical(
    as.data.frame(hg),
    data.frame(
      edge = c("a+b", "a+b", "a+c", "a+c", "b"),
      word = c("a", "b", "a", "c", "b"),
      weight = c(1, 1, 1, 1, 1)
    )
  )
  expect_identical(hg$text$n_windows, 3L)
})

test_that("repeated tokens inside a window collapse to a singleton edge", {
  hg <- text_hypergraph(c(d = "a a b"), construction = "window", window = 2)
  expect_identical(
    as.data.frame(hg),
    data.frame(
      edge = c("a", "a+b", "a+b"),
      word = c("a", "a", "b"),
      weight = c(1, 1, 1)
    )
  )
})

test_that("a document shorter than the window forms one whole-document window", {
  hg <- text_hypergraph(c(d = "a b"), construction = "window", window = 5)
  expect_identical(
    as.data.frame(hg),
    data.frame(edge = c("a+b", "a+b"), word = c("a", "b"), weight = c(1, 1))
  )
  expect_identical(hg$text$n_windows, 1L)
})

test_that("windows never cross document boundaries", {
  hg <- text_hypergraph(c(x = "a b", y = "c d"), construction = "window",
                        window = 2)
  expect_identical(sort(unique(as.data.frame(hg)$edge)), c("a+b", "c+d"))
})

test_that("window counts are conserved", {
  corpus <- c(d1 = "a b c a b c a", d2 = "b c b c b")
  hg <- text_hypergraph(corpus, construction = "window", window = 3)
  # sliding, full windows: (7 - 3 + 1) + (5 - 3 + 1) = 8
  tab <- as.data.frame(hg)
  per_edge <- aggregate(weight ~ edge, data = tab, FUN = max)
  expect_identical(sum(per_edge$weight), 8)
  expect_identical(hg$text$n_windows, 8L)
  # every member of an edge carries the same weight (the window count)
  spread <- aggregate(weight ~ edge, data = tab, FUN = \(w) diff(range(w)))
  expect_true(all(spread$weight == 0))
})

test_that("min_count filtering closes the gap before windowing", {
  hg <- text_hypergraph(c(d = "a q b a b"), construction = "window",
                        window = 2, min_count = 2L)
  tab <- as.data.frame(hg)
  expect_false("q" %in% tab$word)
  # filtered sequence a b a b -> windows (a,b),(b,a),(a,b) -> a+b weight 3
  expect_identical(
    tab,
    data.frame(edge = c("a+b", "a+b"), word = c("a", "b"),
               weight = c(3, 3))
  )
})

# The specified reduction: with window = 2, the OFF-DIAGONAL pairwise
# co-occurrence counts implied by the hypergraph equal Nestimate::wtna(
# method = "cooccurrence") on the one-hot coded sequence, for both window
# modes. The diagonals legitimately differ: wtna crossproducts window count
# vectors (a window (a,a) adds 4 to its "aa" cell), while a set-valued
# hyperedge deliberately collapses within-window repeats.
.pair_counts_from_hg <- function(hg) {
  tab <- as.data.frame(hg)
  vocab <- sort(unique(tab$word))
  m <- matrix(0, length(vocab), length(vocab),
              dimnames = list(vocab, vocab))
  edges <- split(tab, tab$edge)
  contributions <- Map(\(e) {
    members <- sort(e$word)
    count <- e$weight[1L]
    list(members = members, count = count)
  }, edges)
  for (con in contributions) {
    # tiny fixed-size test helper loop over <= a dozen edges; vectorizing
    # would obscure the hand-checkable contribution rule
    idx <- match(con$members, vocab)
    m[idx, idx] <- m[idx, idx] + con$count
  }
  m
}

test_that("window = 2 reduces exactly to wtna co-occurrence counts", {
  toks <- c("a", "b", "b", "c", "a", "a", "b")
  onehot <- data.frame(
    a = as.integer(toks == "a"),
    b = as.integer(toks == "b"),
    c = as.integer(toks == "c")
  )
  corpus <- c(d = paste(toks, collapse = " "))

  off_diagonal <- function(m) {
    diag(m) <- 0
    m
  }

  sliding <- text_hypergraph(corpus, construction = "window", window = 2)
  wtna_overlap <- Nestimate::wtna(onehot, method = "cooccurrence",
                                  window_size = 2, mode = "overlapping")
  expect_equal(off_diagonal(.pair_counts_from_hg(sliding)),
               off_diagonal(wtna_overlap$weights))

  tumbling <- text_hypergraph(corpus, construction = "window", window = 2,
                              window_mode = "tumbling")
  wtna_tumble <- Nestimate::wtna(onehot, method = "cooccurrence",
                                 window_size = 2, mode = "non-overlapping")
  expect_equal(off_diagonal(.pair_counts_from_hg(tumbling)),
               off_diagonal(wtna_tumble$weights))
})

test_that("windowed hypergraphs feed the verbs and print distinctly", {
  hg <- text_hypergraph(c(d1 = "a b c a b", d2 = "b c d"),
                        construction = "window", window = 2)
  nodes <- hg_measures(hg, what = "nodes")
  expect_identical(nrow(nodes), hg$n_nodes)
  expect_output(print(hg), "windowed hyperedges: w = 2, sliding")
})

test_that("window construction rejects tf-idf and window < 2", {
  expect_error(
    text_hypergraph(c(d = "a b c"), construction = "window",
                    weight = "tfidf"),
    class = "thg_bad_input"
  )
  expect_error(
    text_hypergraph(c(d = "a b c"), construction = "window", window = 1)
  )
})
