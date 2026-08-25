# texthypergraph

Hypergraph text analysis in R: a corpus goes in, a weighted document–word
hypergraph comes out, and tidy verbs analyze it — spectral clustering,
transductive classification, structural measures, and tensor eigenvector
centralities. The spectral engines — the Zhou,
Huang & Schölkopf (2006) and Hayashi, Aksoy, Park & Park (2020) Laplacians,
clustering, and transduction — live in this package (HyperNetX-parity
verified); structural measures, tensor centralities, and the incidence
construction delegate to [Nestimate](https://github.com/mohsaqr/Nestimate).
No Python, no NLP dependencies.

A document–word corpus is a bipartite incidence structure, which is a
hypergraph in either orientation:

- `nodes = "doc"` (default): documents are vertices, each word is a hyperedge
  over the documents containing it — the orientation for document clustering
  and few-label document classification.
- `nodes = "word"`: words are vertices, each document is a hyperedge — the
  orientation for vocabulary structure and central-term ranking.

## Installation

```r
install.packages(
  "texthypergraph",
  repos = c("https://mohsaqr.r-universe.dev", getOption("repos"))
)
```

## Quick start

```r
library(texthypergraph)

hg <- text_hypergraph(
  covid_abstracts,          # bundled: 165 COVID-19 education abstracts, 2020-2024
  column = "abstract",
  id = "doc",
  weight = "tfidf",
  stop_words = stop_words_en(),
  min_count = 3L
)
hg
#> Text hypergraph: 165 documents, 1464 words (documents as nodes, weight = tfidf)
#> Hyperedges: 1464 (words); sizes 1-140, median 4

hg_cluster(hg, k = 4, type = "random_walk", seed = 1)   # Hayashi EDVW pipeline
hg_classify(hg, labels = c("2-s2.0-85085897904" = "early",
                           "2-s2.0-85107489479" = "late"))
hg_measures(hg, what = "summary")
```

Every verb returns a base `data.frame`. Word-level structure uses the same
API in the other orientation:

```r
word_hg <- text_hypergraph(covid_abstracts, column = "abstract", id = "doc",
                           nodes = "word", weight = "tfidf",
                           stop_words = stop_words_en(), min_count = 3L)
hg_centrality(word_hg, type = "clique", sort_by = "clique", n = 10)
```

On the bundled corpus this ranking reads *covid*, *pandemic*, *education*,
*study*, *students*, *learning*, *online*, *teaching* — the corpus in
miniature, recovered without reading an abstract. (*study* and *research*
also rank high: abstract boilerplate worth adding to the stop list, as the
vignette does with `c(stop_words_en(), "study", ...)`.)

## Verbs

| Verb | Does | Engine |
|---|---|---|
| `text_hypergraph()` | corpus → weighted hypergraph (counts or smoothed tf-idf; stop words; `min_count`) | `Nestimate::bipartite_groups()` |
| `hg_cluster()` | spectral document/word clustering (`"zhou"` or `"random_walk"` EDVW) | in-package `hypergraph_cluster()` |
| `hg_classify()` | transductive label spreading from a few labeled nodes | in-package `hypergraph_transduction()` |
| `hg_centrality()` | clique-expansion + tensor Z/H eigenvector centralities, with `sort_by`/`n` | `Nestimate::hypergraph_centrality()` |
| `hg_measures()` | tidy structural tables: nodes, edges, overlaps, summary | `Nestimate::hypergraph_measures()` |

Two further constructions use word order and embedding space
(`vignette("constructions")`): `construction = "window"` makes every token
window a hyperedge (the HyperGAT sequential construction, weighted; its
w = 2 off-diagonal counts provably match `Nestimate::wtna()`), and
`construction = "knn"` builds each document's k-nearest-neighbor hyperedge
from sbert embeddings — the bundled `covid_embeddings` matrix keeps it
offline, and `knn_hypergraph(embeddings, k)` takes any embedding matrix
directly (binary support verified against `HyperG::knn_hypergraph`).

`as.data.frame()` on a text hypergraph returns the tidy weight table;
`what = "documents"` and `what = "vocabulary"` return the other two corpus
tables.

The full worked analysis — clustering, a `k` sensitivity check, few-label
classification and its honest limits — is the package vignette:

```r
vignette("texthypergraph")
```

## Existing quanteda/tidytext pipelines

Any long document–word table is already the incidence structure; no
conversion layer is needed (see the vignette's bridge section):

```r
Nestimate::bipartite_groups(tidytext::tidy(my_dfm),
                            player = "term", group = "document",
                            weight = "count")
```

## Research base and roadmap

The package grew out of a literature survey of hypergraph text/NLP methods;
the `papers/` folder, per-repo notes in `repos/` (each naming its role as
equivalence oracle or reference — see `repos/README.md`), and `TODO.md`
remain in-tree as the research base. `ROADMAP.md` is the release plan;
v0.2 delivered the windowed and kNN constructions, v0.3 brings the theory
completions (edge-dependent random-walk centrality, wasserstein, samplers).

## References

- Zhou, D., Huang, J., & Schölkopf, B. (2006). Learning with hypergraphs:
  Clustering, classification, and embedding. *NeurIPS 2006*.
- Hayashi, K., Aksoy, S. G., Park, C. H., & Park, H. (2020). Hypergraph
  random walks, Laplacians, and clustering. *CIKM 2020*.
  doi:10.1145/3340531.3412034
- Ding, K., Wang, J., Li, J., Li, D., & Liu, H. (2020). Be more with less:
  Hypergraph attention networks for inductive text classification.
  *EMNLP 2020*.
