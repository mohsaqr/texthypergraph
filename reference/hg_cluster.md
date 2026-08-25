# Spectral clustering of a hypergraph, as a tidy table

Calls the in-package
[`hypergraph_cluster()`](https://mohsaqr.github.io/texthypergraph/reference/hypergraph_cluster.md)
engine (Zhou et al. 2006 normalized Laplacian, or the Hayashi et al.
2020 random-walk Laplacian with edge-dependent vertex weights – the
natural choice for tf-idf-weighted text hypergraphs).

## Usage

``` r
hg_cluster(hg, k, type = c("zhou", "random_walk"), seed = NULL, nstart = 25L)
```

## Arguments

- hg:

  A
  [`text_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/text_hypergraph.md)
  (or any Nestimate `net_hypergraph`).

- k:

  Number of clusters (explicit by design; there is no correct default).

- type:

  `"zhou"` or `"random_walk"`, as in
  [`hypergraph_cluster()`](https://mohsaqr.github.io/texthypergraph/reference/hypergraph_cluster.md).

- seed:

  Random seed passed to the engine's k-means step; set it for a
  reproducible partition.

- nstart:

  Number of k-means starts (default `25L`).

## Value

A base `data.frame`, one row per node, with columns `node` and
`cluster`.

## Examples

``` r
hg <- text_hypergraph(c(
  cooking_1 = "simmer the soup with onions and carrots",
  cooking_2 = "this soup recipe needs salt on a cold night",
  space_1 = "the telescope revealed a distant galaxy and stars",
  space_2 = "astronomers aimed the telescope at the stars all night"
), stop_words = c("the", "with", "and", "a", "this", "at", "on", "all"))
hg_cluster(hg, k = 2, type = "random_walk", seed = 1)
#>        node   cluster
#> 1 cooking_1 Cluster 1
#> 2 cooking_2 Cluster 1
#> 3   space_1 Cluster 2
#> 4   space_2 Cluster 2
```
