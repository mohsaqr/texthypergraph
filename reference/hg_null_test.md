# Degree-preserving null-model test of hypergraph structure

Tests whether an observed structural statistic exceeds what the degree
sequences alone imply. The null model fixes both margins of the binary
membership (every vertex keeps its hyperdegree, every hyperedge its
size) and randomizes the memberships by checkerboard swaps (Gotelli
2000) – a sequential MCMC with burn-in `10 * nnz` swap attempts and
thinning `nnz` between samples, `nnz` being the number of memberships.
Statistics are evaluated on the binarized hypergraph (weights carry no
meaning under this null), through the same delegated measures as
[`hg_measures()`](https://mohsaqr.github.io/texthypergraph/reference/hg_measures.md).

## Usage

``` r
hg_null_test(
  hg,
  statistic = c("pairwise_participation", "density", "avg_edge_size", "avg_jaccard"),
  n = 199L,
  seed = NULL,
  alternative = c("two_sided", "greater", "less")
)
```

## Arguments

- hg:

  A
  [`text_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/text_hypergraph.md),
  [`knn_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/knn_hypergraph.md),
  or any Nestimate `net_hypergraph`.

- statistic:

  Statistics to test; any of `"pairwise_participation"`, `"density"`,
  `"avg_edge_size"`, `"avg_jaccard"` (mean pairwise edge Jaccard).
  Several allowed.

- n:

  Number of null samples (default `199L`).

- seed:

  Seed for the swap chain; set it for a reproducible test. The global
  RNG state is restored on exit.

- alternative:

  `"two_sided"` (default), `"greater"`, or `"less"`.

## Value

A base `data.frame`, one row per statistic: `statistic`, `observed`,
`null_mean`, `null_lo`, `null_hi`, `z`, `p_value`, `n`.

## Details

The permutation p-value is `(1 + extreme) / (n + 1)` (Phipson & Smyth
2010), two-sided by default around the null mean; `null_lo`/`null_hi`
are the 2.5% and 97.5% null quantiles – report them with the observed
value, not the p-value alone.

## Conditions

Raises `thg_bad_input` for broken contracts.

## References

Gotelli, N. J. (2000). Null model analysis of species co-occurrence
patterns. *Ecology*, 81(9).

Phipson, B., & Smyth, G. K. (2010). Permutation p-values should never be
zero. *Statistical Applications in Genetics and Molecular Biology*,
9(1).

## Examples

``` r
hg <- text_hypergraph(c(
  a = "salt and soup and onions",
  b = "soup and salt",
  c = "stars and sky and salt",
  d = "stars and sky"
))
hg_null_test(hg, statistic = "pairwise_participation", n = 49, seed = 1)
#>                statistic observed null_mean null_lo null_hi  z p_value  n
#> 1 pairwise_participation        1         1       1       1 NA       1 49
```
