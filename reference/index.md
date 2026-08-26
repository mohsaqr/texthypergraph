# Package index

## Constructions

Corpus and embeddings to weighted hypergraph.

- [`text_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/text_hypergraph.md)
  : Build a weighted hypergraph from a text corpus
- [`knn_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/knn_hypergraph.md)
  : Build a k-nearest-neighbor hypergraph from embeddings
- [`dual_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/dual_hypergraph.md)
  : Dual of a hypergraph
- [`stop_words_en()`](https://mohsaqr.github.io/texthypergraph/reference/stop_words_en.md)
  : English function-word stop list

## Analysis verbs

Tidy tables from the delegated Nestimate engines and the in-package
methods.

- [`hg_measures()`](https://mohsaqr.github.io/texthypergraph/reference/hg_measures.md)
  : Structural measures of a hypergraph, as tidy tables
- [`hg_centrality()`](https://mohsaqr.github.io/texthypergraph/reference/hg_centrality.md)
  : Hypergraph node centralities, as a tidy table
- [`hg_pagerank()`](https://mohsaqr.github.io/texthypergraph/reference/hg_pagerank.md)
  : Hypergraph PageRank with edge-dependent vertex weights
- [`hg_cluster()`](https://mohsaqr.github.io/texthypergraph/reference/hg_cluster.md)
  : Spectral clustering of a hypergraph, as a tidy table
- [`hg_classify()`](https://mohsaqr.github.io/texthypergraph/reference/hg_classify.md)
  : Transductive label spreading on a hypergraph, as a tidy table
- [`hg_null_test()`](https://mohsaqr.github.io/texthypergraph/reference/hg_null_test.md)
  : Degree-preserving null-model test of hypergraph structure

## Neural tier

Hypergraph neural networks in native R torch.

- [`hg_neural()`](https://mohsaqr.github.io/texthypergraph/reference/hg_neural.md)
  : Hypergraph neural network classifier (HGNN)

## Spectral engines

The in-package Zhou (2006) and Hayashi (2020) machinery behind the
verbs.

- [`hypergraph_laplacian()`](https://mohsaqr.github.io/texthypergraph/reference/hypergraph_laplacian.md)
  : Normalized hypergraph Laplacian
- [`hypergraph_cluster()`](https://mohsaqr.github.io/texthypergraph/reference/hypergraph_cluster.md)
  : Spectral clustering of hypergraph vertices
- [`hypergraph_transduction()`](https://mohsaqr.github.io/texthypergraph/reference/hypergraph_transduction.md)
  : Transductive label spreading on a hypergraph

## Methods and accessors

- [`print(`*`<text_hypergraph>`*`)`](https://mohsaqr.github.io/texthypergraph/reference/print.text_hypergraph.md)
  : Print a text hypergraph
- [`as.data.frame(`*`<text_hypergraph>`*`)`](https://mohsaqr.github.io/texthypergraph/reference/as.data.frame.text_hypergraph.md)
  : Tidy tables of a text hypergraph
- [`print(`*`<net_hypergraph_cluster>`*`)`](https://mohsaqr.github.io/texthypergraph/reference/print.net_hypergraph_cluster.md)
  : Print method for net_hypergraph_cluster
- [`summary(`*`<net_hypergraph_cluster>`*`)`](https://mohsaqr.github.io/texthypergraph/reference/summary.net_hypergraph_cluster.md)
  : Summary method for net_hypergraph_cluster
- [`as.data.frame(`*`<net_hypergraph_cluster>`*`)`](https://mohsaqr.github.io/texthypergraph/reference/as.data.frame.net_hypergraph_cluster.md)
  : Coerce a net_hypergraph_cluster to a data.frame
- [`print(`*`<net_hypergraph_transduction>`*`)`](https://mohsaqr.github.io/texthypergraph/reference/print.net_hypergraph_transduction.md)
  : Print method for net_hypergraph_transduction
- [`summary(`*`<net_hypergraph_transduction>`*`)`](https://mohsaqr.github.io/texthypergraph/reference/summary.net_hypergraph_transduction.md)
  : Summary method for net_hypergraph_transduction
- [`as.data.frame(`*`<net_hypergraph_transduction>`*`)`](https://mohsaqr.github.io/texthypergraph/reference/as.data.frame.net_hypergraph_transduction.md)
  : Coerce a net_hypergraph_transduction to a data.frame

## Data

- [`covid_abstracts`](https://mohsaqr.github.io/texthypergraph/reference/covid_abstracts.md)
  : COVID-19 education research abstracts
- [`covid_embeddings`](https://mohsaqr.github.io/texthypergraph/reference/covid_embeddings.md)
  : Sentence embeddings of the COVID-19 abstracts
