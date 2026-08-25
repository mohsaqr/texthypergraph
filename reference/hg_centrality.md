# Hypergraph node centralities, as a tidy table

Delegates to
[`Nestimate::hypergraph_centrality()`](https://saqr.me/Nestimate/reference/hypergraph_centrality.html):
clique-expansion eigenvector centrality and the tensor Z- and
H-eigenvector centralities.

## Usage

``` r
hg_centrality(
  hg,
  type = c("clique", "Z", "H"),
  sort_by = NULL,
  n = Inf,
  max_iter = 1000L,
  tol = 1e-08,
  normalize = TRUE
)
```

## Arguments

- hg:

  A
  [`text_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/text_hypergraph.md)
  (or any Nestimate `net_hypergraph`).

- type:

  Centralities to compute; any of `"clique"`, `"Z"`, `"H"` (default: all
  three).

- sort_by:

  Optional centrality name to sort by, descending (ties broken by node
  name); default keeps node order.

- n:

  Return only the first `n` rows after sorting (default all) – e.g.
  `sort_by = "clique", n = 10` for the ten most central nodes.

- max_iter, tol, normalize:

  Passed to
  [`Nestimate::hypergraph_centrality()`](https://saqr.me/Nestimate/reference/hypergraph_centrality.html).

## Value

A base `data.frame`, one row per node (or the `n` requested rows), with
one column per requested centrality.

## Examples

``` r
hg <- text_hypergraph(c(
  a = "salt and soup and onions",
  b = "soup and salt",
  c = "stars and salt"
))
hg_centrality(hg, type = "clique")
#>   node    clique
#> 1    a 0.6059128
#> 2    b 0.6059128
#> 3    c 0.5154991
```
