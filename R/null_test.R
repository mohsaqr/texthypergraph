# Degree-preserving null-model test for hypergraph structure. The null
# fixes both margins of the binary membership matrix (every vertex keeps its
# hyperdegree, every hyperedge its size) and randomizes which memberships
# occur, via checkerboard swaps (the bipartite swap null of Gotelli 2000).
# Observed structure beyond that null is structure the degree sequences
# alone cannot explain.

# One MCMC chain of checkerboard swap attempts on a binary matrix. A swap
# picks two rows and two columns showing a [1,0;0,1] or [0,1;1,0] pattern
# and flips it, preserving all row and column sums exactly.
.thg_swap_chain <- function(m, attempts) {
  n_row <- nrow(m)
  n_col <- ncol(m)
  rows_1 <- sample.int(n_row, attempts, replace = TRUE)
  rows_2 <- sample.int(n_row, attempts, replace = TRUE)
  cols_1 <- sample.int(n_col, attempts, replace = TRUE)
  cols_2 <- sample.int(n_col, attempts, replace = TRUE)
  # sequential MCMC: each accepted swap changes the state the next attempt
  # sees, so the loop cannot be vectorized; candidate indices are drawn in
  # one vectorized batch above
  for (i in seq_len(attempts)) {
    r1 <- rows_1[i]; r2 <- rows_2[i]; c1 <- cols_1[i]; c2 <- cols_2[i]
    if (r1 == r2 || c1 == c2) next
    a <- m[r1, c1]; b <- m[r1, c2]; d <- m[r2, c1]; e <- m[r2, c2]
    if (a + e == 2L && b + d == 0L) {
      m[r1, c1] <- 0L; m[r2, c2] <- 0L; m[r1, c2] <- 1L; m[r2, c1] <- 1L
    } else if (a + e == 0L && b + d == 2L) {
      m[r1, c1] <- 1L; m[r2, c2] <- 1L; m[r1, c2] <- 0L; m[r2, c1] <- 0L
    }
  }
  m
}

# Statistics on the binary membership, computed through the delegated
# measures so no formula is duplicated.
.thg_null_statistics <- function(m, statistic) {
  nz <- which(m > 0, arr.ind = TRUE)
  long <- data.frame(
    vertex = rownames(m)[nz[, "row"]],
    edge = colnames(m)[nz[, "col"]],
    w = 1
  )
  hg <- Nestimate::bipartite_groups(long, player = "vertex", group = "edge",
                                    weight = "w")
  summary_tab <- hg_measures(hg, what = "summary")
  vapply(statistic, \(s) {
    if (identical(s, "avg_jaccard")) {
      mean(hg_measures(hg, what = "overlap")$jaccard)
    } else {
      summary_tab$value[summary_tab$measure == s]
    }
  }, numeric(1))
}

#' Degree-preserving null-model test of hypergraph structure
#'
#' Tests whether an observed structural statistic exceeds what the degree
#' sequences alone imply. The null model fixes both margins of the binary
#' membership (every vertex keeps its hyperdegree, every hyperedge its
#' size) and randomizes the memberships by checkerboard swaps (Gotelli
#' 2000) -- a sequential MCMC with burn-in `10 * nnz` swap attempts and
#' thinning `nnz` between samples, `nnz` being the number of memberships.
#' Statistics are evaluated on the binarized hypergraph (weights carry no
#' meaning under this null), through the same delegated measures as
#' [hg_measures()].
#'
#' The permutation p-value is `(1 + extreme) / (n + 1)` (Phipson & Smyth
#' 2010), two-sided by default around the null mean; `null_lo`/`null_hi`
#' are the 2.5% and 97.5% null quantiles -- report them with the observed
#' value, not the p-value alone.
#'
#' @param hg A [text_hypergraph()], [knn_hypergraph()], or any Nestimate
#'   `net_hypergraph`.
#' @param statistic Statistics to test; any of `"pairwise_participation"`,
#'   `"density"`, `"avg_edge_size"`, `"avg_jaccard"` (mean pairwise edge
#'   Jaccard). Several allowed.
#' @param n Number of null samples (default `199L`).
#' @param seed Seed for the swap chain; set it for a reproducible test.
#'   The global RNG state is restored on exit.
#' @param alternative `"two_sided"` (default), `"greater"`, or `"less"`.
#' @return A base `data.frame`, one row per statistic: `statistic`,
#'   `observed`, `null_mean`, `null_lo`, `null_hi`, `z`, `p_value`, `n`.
#' @section Conditions: Raises `thg_bad_input` for broken contracts.
#' @references
#' Gotelli, N. J. (2000). Null model analysis of species co-occurrence
#' patterns. *Ecology*, 81(9).
#'
#' Phipson, B., & Smyth, G. K. (2010). Permutation p-values should never be
#' zero. *Statistical Applications in Genetics and Molecular Biology*, 9(1).
#' @examples
#' hg <- text_hypergraph(c(
#'   a = "salt and soup and onions",
#'   b = "soup and salt",
#'   c = "stars and sky and salt",
#'   d = "stars and sky"
#' ))
#' hg_null_test(hg, statistic = "pairwise_participation", n = 49, seed = 1)
#' @export
hg_null_test <- function(hg,
                         statistic = c("pairwise_participation", "density",
                                       "avg_edge_size", "avg_jaccard"),
                         n = 199L, seed = NULL,
                         alternative = c("two_sided", "greater", "less")) {
  .thg_check_hg(hg)
  statistic <- match.arg(statistic, several.ok = TRUE)
  alternative <- match.arg(alternative)
  stopifnot(
    "`n` must be a single count >= 19" =
      length(n) == 1L && is.finite(n) && n >= 19
  )

  if (!is.null(seed)) {
    old_seed <- if (exists(".Random.seed", envir = globalenv())) {
      get(".Random.seed", envir = globalenv())
    } else {
      NULL
    }
    on.exit({
      if (is.null(old_seed)) {
        rm(".Random.seed", envir = globalenv())
      } else {
        assign(".Random.seed", old_seed, envir = globalenv())
      }
    }, add = TRUE)
    set.seed(seed)
  }

  membership <- (hg$incidence > 0) * 1L
  nnz <- sum(membership)
  observed <- .thg_null_statistics(membership, statistic)

  state <- .thg_swap_chain(membership, attempts = 10L * nnz)
  draws <- vapply(seq_len(n), \(i) {
    state <<- .thg_swap_chain(state, attempts = nnz)
    .thg_null_statistics(state, statistic)
  }, numeric(length(statistic)))
  draws <- matrix(draws, nrow = length(statistic))

  rows <- lapply(seq_along(statistic), \(i) {
    null_draws <- draws[i, ]
    null_mean <- mean(null_draws)
    null_sd <- stats::sd(null_draws)
    centered_obs <- abs(observed[i] - null_mean)
    extreme <- switch(alternative,
      two_sided = sum(abs(null_draws - null_mean) >= centered_obs -
                        sqrt(.Machine$double.eps)),
      greater = sum(null_draws >= observed[i] - sqrt(.Machine$double.eps)),
      less = sum(null_draws <= observed[i] + sqrt(.Machine$double.eps))
    )
    data.frame(
      statistic = statistic[i],
      observed = unname(observed[i]),
      null_mean = null_mean,
      null_lo = unname(stats::quantile(null_draws, 0.025)),
      null_hi = unname(stats::quantile(null_draws, 0.975)),
      z = if (null_sd > 0) (observed[i] - null_mean) / null_sd else NA_real_,
      p_value = (1 + extreme) / (n + 1),
      n = as.integer(n)
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out
}
