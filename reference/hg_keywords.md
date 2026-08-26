# Characteristic hyperedges (keywords) per cluster

For a clustered hypergraph, ranks each cluster's hyperedges by the
incidence weight mass its member nodes place on them. On a
`nodes = "doc"`
[`text_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/text_hypergraph.md)
this is per-topic keyword extraction: a word's score in a cluster is the
summed (tf-idf) weight it receives from that cluster's documents, and
`share` is the fraction of the word's total corpus mass concentrated in
the cluster – `score` finds the cluster's heavy vocabulary, `share` its
distinctive vocabulary.

## Usage

``` r
hg_keywords(hg, clusters, n = 10L)
```

## Arguments

- hg:

  The hypergraph the clustering was computed on.

- clusters:

  The tidy table returned by
  [`hg_cluster()`](https://mohsaqr.github.io/texthypergraph/reference/hg_cluster.md)
  (columns `node`, `cluster`), or a named vector of cluster labels.

- n:

  Keywords per cluster (default `10`); `Inf` returns all.

## Value

A base `data.frame`, one row per cluster-keyword pair, columns
`cluster`, `rank`, `word` (the hyperedge name), `score` (in-cluster
weight mass) and `share` (`score` divided by the hyperedge's total
mass), ranked by `score` within cluster with ties broken alphabetically.

## Examples

``` r
hg <- text_hypergraph(c(
  cooking_1 = "simmer the soup with onions and carrots",
  cooking_2 = "this soup recipe needs salt on a cold night",
  space_1 = "the telescope revealed a distant galaxy and stars",
  space_2 = "astronomers aimed the telescope at the stars all night"
), stop_words = c("the", "with", "and", "a", "this", "at", "on", "all"))
topics <- hg_cluster(hg, k = 2, seed = 1)
hg_keywords(hg, topics, n = 3)
#>     cluster rank      word score share
#> 1 Cluster 1    1      soup     2     1
#> 2 Cluster 1    2   carrots     1     1
#> 3 Cluster 1    3      cold     1     1
#> 4 Cluster 2    1     stars     2     1
#> 5 Cluster 2    2 telescope     2     1
#> 6 Cluster 2    3     aimed     1     1
```
