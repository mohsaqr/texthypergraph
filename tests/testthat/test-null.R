# Degree-preserving null-model test: margin preservation, invariances,
# calibration, and detection of blatant structure.

blocky <- c(
  a = "soup salt onion", b = "soup salt pepper", c = "salt onion pepper",
  d = "stars sky moon", e = "stars sky comet", f = "sky moon comet"
)

test_that("checkerboard swaps preserve both margins exactly", {
  hg <- text_hypergraph(blocky)
  m <- (hg$incidence > 0) * 1L
  set.seed(1)
  swapped <- texthypergraph:::.thg_swap_chain(m, attempts = 5000L)
  expect_identical(rowSums(swapped), rowSums(m))
  expect_identical(colSums(swapped), colSums(m))
  expect_true(all(swapped %in% c(0L, 1L)))
  # and the chain actually moves
  expect_gt(sum(swapped != m), 0)
})

test_that("avg_edge_size is invariant under the null, by construction", {
  hg <- text_hypergraph(blocky)
  out <- hg_null_test(hg, statistic = "avg_edge_size", n = 29, seed = 1)
  expect_equal(out$observed, out$null_mean)
  expect_identical(out$p_value, 1)
  expect_true(is.na(out$z))
})

test_that("the test is deterministic given a seed and restores the RNG", {
  hg <- text_hypergraph(blocky)
  set.seed(999)
  before <- get(".Random.seed", envir = globalenv())
  a <- hg_null_test(hg, statistic = "pairwise_participation", n = 29,
                    seed = 42)
  after <- get(".Random.seed", envir = globalenv())
  expect_identical(before, after)
  b <- hg_null_test(hg, statistic = "pairwise_participation", n = 29,
                    seed = 42)
  expect_identical(a, b)
})

test_that("observed values match hg_measures and p stays in bounds", {
  hg <- text_hypergraph(blocky)
  out <- hg_null_test(hg,
                      statistic = c("pairwise_participation", "density"),
                      n = 29, seed = 7)
  summary_tab <- hg_measures(hg, what = "summary")
  expect_equal(
    out$observed[out$statistic == "pairwise_participation"],
    summary_tab$value[summary_tab$measure == "pairwise_participation"]
  )
  expect_true(all(out$p_value >= 1 / 30 & out$p_value <= 1))
  expect_identical(names(out),
                   c("statistic", "observed", "null_mean", "null_lo",
                     "null_hi", "z", "p_value", "n"))
})

test_that("blatant block structure is detected against the null", {
  # two vocabulary blocks that never mix: observed pairwise participation
  # (0.4) sits far below what degree-preserving rewiring produces
  hg <- text_hypergraph(blocky)
  out <- hg_null_test(hg, statistic = "pairwise_participation", n = 99,
                      seed = 11, alternative = "less")
  expect_lt(out$observed, out$null_mean)
  expect_lt(out$p_value, 0.05)
})

test_that("contract violations raise classed or plain errors", {
  hg <- text_hypergraph(blocky)
  expect_error(hg_null_test(42), class = "thg_bad_input")
  expect_error(hg_null_test(hg, n = 5))
})

test_that("direct null statistics equal the delegated measures path", {
  set.seed(11)
  m <- matrix(rbinom(12 * 30, 1, 0.3), nrow = 12,
              dimnames = list(paste0("d", seq_len(12)),
                              paste0("w", seq_len(30))))
  # drop empty rows/columns so the rebuilt hypergraph matches exactly
  m <- m[rowSums(m) > 0, colSums(m) > 0]
  stats <- c("density", "avg_edge_size", "pairwise_participation",
             "avg_jaccard")
  fast <- .thg_null_statistics(m, stats)
  nz <- which(m > 0, arr.ind = TRUE)
  long <- data.frame(vertex = rownames(m)[nz[, "row"]],
                     edge = colnames(m)[nz[, "col"]], w = 1)
  ref_hg <- Nestimate::bipartite_groups(long, player = "vertex",
                                        group = "edge", weight = "w")
  s_tab <- hg_measures(ref_hg, what = "summary")
  expect_equal(unname(fast["density"]),
               subset(s_tab, measure == "density")$value,
               tolerance = 1e-12)
  expect_equal(unname(fast["avg_edge_size"]),
               subset(s_tab, measure == "avg_edge_size")$value,
               tolerance = 1e-12)
  expect_equal(unname(fast["pairwise_participation"]),
               subset(s_tab, measure == "pairwise_participation")$value,
               tolerance = 1e-12)
  expect_equal(unname(fast["avg_jaccard"]),
               mean(hg_measures(ref_hg, what = "overlap")$jaccard),
               tolerance = 1e-12)
})
