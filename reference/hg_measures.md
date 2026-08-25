# Structural measures of a hypergraph, as tidy tables

Delegates to
[`Nestimate::hypergraph_measures()`](https://saqr.me/Nestimate/reference/hypergraph_measures.html)
and returns the requested slice as a tidy data.frame.

## Usage

``` r
hg_measures(hg, what = c("nodes", "edges", "overlap", "summary"))
```

## Arguments

- hg:

  A
  [`text_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/text_hypergraph.md)
  (or any Nestimate `net_hypergraph`).

- what:

  Which table: `"nodes"` (default; one row per node with `hyperdegree`,
  `strength`, `max_edge_size`), `"edges"` (one row per hyperedge with
  its `size`), `"overlap"` (one row per hyperedge pair with `overlap`,
  `overlap_coefficient`, `jaccard`), or `"summary"` (one row per scalar
  measure).

## Value

A base `data.frame`, one row per node, edge, edge pair, or measure
according to `what`.

## Examples

``` r
hg <- text_hypergraph(c(
  a = "salt and soup and onions",
  b = "soup and salt",
  c = "stars and sky"
))
hg_measures(hg)
#>   node hyperdegree strength max_edge_size
#> 1    a           4        8             3
#> 2    b           3        7             3
#> 3    c           3        5             3
hg_measures(hg, what = "summary")
#>                  measure     value
#> 1                n_nodes 3.0000000
#> 2           n_hyperedges 6.0000000
#> 3                density 0.5555556
#> 4          avg_edge_size 1.6666667
#> 5 pairwise_participation 1.0000000
```
