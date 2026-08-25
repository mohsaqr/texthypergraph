# texthypergraph

Working folder for **hypergraph methods for text / NLP and sequence data** —
literature, links, and the todos that fell out of the 2026-08-24 coverage
comparisons run from Nestimate. Not a package (yet); a staging ground for
deciding what lands in Nestimate (statistical R side), Saqrlab (simulation),
or carm-text / carm-ml (JS side).

Origin: reading Ding et al. (2020) "HyperGAT" against Nestimate's hypergraph
module (`build_hypergraph`, `bipartite_groups`, `hypergraph_measures`,
`hypergraph_centrality` with tensor Z/H eigenvectors, `clique_expansion`) and
against CRAN's `HyperG` / `SimplicialComplex`.

## Method map

### 1. Non-neural / statistical (fits the R ecosystem)

| Method | Paper (in `papers/`) | Status vs our stack |
|---|---|---|
| Hypergraph Laplacian: spectral clustering, **transductive classification**, embedding | Zhou, Huang & Schölkopf, NeurIPS 2006 | MISSING — parked as Nestimate todo; weighted version would exceed CRAN `HyperG` |
| Random walks with edge-dependent vertex weights (Laplacian, PageRank-style ranking) | Chitra & Raphael, ICML 2019 | MISSING — natural sibling of our Z/H tensor centralities |
| **EDVW spectral clustering** (tf-idf as word-in-document weight -> random-walk Laplacian -> spectral/NMF clustering; the unsupervised better-than-LDA route) | Hayashi, Aksoy, Park & Park, CIKM 2020 | MISSING everywhere in R — shares all machinery with the Zhou item |
| kNN embedding hypergraph (contrastive embeddings -> weighted kNN hyperedges -> spectral clustering + our measures) | — (composition; unweighted precedent `HyperG::knn_hypergraph`) | MISSING — tier-3 -> tier-2 bridge, see TODO |
| Tensor Z/H-eigenvector centrality (Benson 2019) | — (implemented) | SHIPPED in Nestimate `hypergraph_centrality()` |
| Hypergraph partitioning (hMETIS/KaHyPar lineage) for document clustering | — (classical IR) | out of scope for now |
| Topic-model hyperedges (LDA top-K words per topic) | HyperGAT Sec. 3.2 | construction only; topic modeling itself = carm-text territory |

### 2. Text-specific hypergraph classifiers (neural)

| Model | Paper (in `papers/`) | Construction |
|---|---|---|
| **HyperGAT** | Ding, Wang, Li, Li & Liu, EMNLP 2020 | sentence = hyperedge + LDA-topic hyperedges; dual (node/edge-level) attention. Code: github.com/kaize0409/HyperGAT_TextClassification — verified 2026-08-24: construction in `utils.py::get_slice()`; the paper's sliding-window alternative is NOT in the code |
| HGAT (short text, semi-supervised) | Hu, Yang, Shi, Ji & Li, EMNLP 2019 | heterogeneous info network: text + topics + entities; dual-level attention. Predecessor of HyperGAT's semantic edges |

### 3. General hypergraph neural networks (applicable once a text hypergraph exists)

| Model | Paper (in `papers/`) | Idea |
|---|---|---|
| HGNN | Feng, You, Zhang, Ji & Gao, AAAI 2019 | spectral convolution via the Zhou 2006 normalized Laplacian |
| HyperGCN | Yadati et al., NeurIPS 2019 | approximate hyperedges by mediator-weighted pairwise edges, then GCN |
| HNHN | Dong, Sawin & Bengio, 2020 | alternating node -> hyperedge -> node nonlinear message passing |
| AllSet / AllSetTransformer | Chien, Pan, Peng & Milenkovic, ICLR 2022 | both aggregations as learned multiset functions (Deep Sets / Set Transformer); strongest general framework |

Not archived here (later continuation, fetch when needed): ED-HNN, hypergraph
diffusion, hypergraph transformers / state-space models (2023-2025).

### 0. Umbrella survey (context)

| Paper (in `papers/`) | Scope — and what it does NOT cover |
|---|---|
| Li, Peng, Li, Xia, Yang, Sun, Yu & He, "A Survey on Text Classification: From Traditional to Deep Learning", ACM TIST 13(2), 2022 (doi 10.1145/3495162) | Supervised classification 1961-2021: Traditional (BoW/TF-IDF + NB/KNN/SVM/DT/RF/XGBoost) and Deep (ReNN/MLP/RNN/CNN/**Attention**/Transformer/**GCN**) branches, with benchmark tables (its Table 4 = accuracy comparisons) and dataset/metric summaries. XLNet covered. Its taxonomy STOPS at GCN — **hypergraph methods are absent** (no HyperGAT/hypergraph hits in the extractable text; checked 2026-08-24), as are unsupervised discovery and non-neural spectral/transductive methods. This folder is effectively the continuation of its GCN + Attention branches into exactly those gaps. |

### 4. PLM baseline (context, not hypergraph)

| Model | Paper (in `papers/`) | Implementations |
|---|---|---|
| XLNet | Yang, Dai, Yang, Carbonell, Salakhutdinov & Le, NeurIPS 2019 | Python only: official github.com/zihangdai/xlnet (TF 1.x, per the paper's footnote) and Hugging Face `transformers` (`XLNetForSequenceClassification`). **No native R implementation exists** — R access is wrapper-only: CRAN `text` package (reticulate -> Hugging Face, any HF model id) or raw `reticulate`. Kept here as the strong-baseline family HyperGAT-era papers compare against ("be more with LESS" = fewer parameters than PLMs). |

## R / CRAN landscape (checked 2026-08-24 via CRAN_package_db)

- `HyperG` 1.0.0 — only general hypergraph toolkit; undirected, UNWEIGHTED,
  dormant since 2021, heavy deps (igraph + mclust + RSpectra).
- `SimplicialComplex` 0.1.2 — geometric point-cloud TDA; no networks/sequences.
- `causalHyperGraph` (CNA drawing), `hypergraph.sizing` (multiple testing —
  name red herring), `ghypernet` (plain-graph hypergeometric ensembles, kin to
  HYPA but not hypergraphs). `rhype` no longer on CRAN. Bioconductor:
  `hypergraph`/`hyperdraw` (ancient data structures).
- **No hypergraph text classification exists in R at all** — not even the
  non-neural Zhou 2006 transductive classifier. No HGNN layers for torch-R.

Consequence: the parked items below are first-in-R contributions, not catch-up.

## The existing bridge (no new code needed)

A `quanteda` dfm / `tidytext` tidy table IS a document-word incidence
structure. `Nestimate::bipartite_groups(long_df, player = "word",
group = "doc", weight = "n")` ingests it today: documents as weighted
hyperedges over words, feeding `hypergraph_measures()` and
`hypergraph_centrality()`. Classification/clustering unlocks once the Zhou
Laplacian lands. Vignette candidate.

## Python ecosystem (verified 2026-08-25)

Python has everything R lacks — which matters to us mainly as ORACLES for the
local equivalence suites (reticulate, never declared deps, pyHON/pathpy
pattern):

- **XGI** — measures, connectivity, and (verified in docs) `h_eigenvector_`,
  `z_eigenvector_`, `clique_eigenvector_centrality`, Katz: an independent
  second oracle for Nestimate's SHIPPED `hypergraph_centrality()` trio.
- **HyperNetX** (PNNL) — verified in source: `laplacians_clustering.py`
  implements the Hayashi EDVW pipeline exactly (`prob_trans`, `get_pi`,
  `norm_lap`, `spec_clus`, citing the paper — Aksoy is PNNL). THE oracle for
  the parked Zhou/Hayashi Laplacian item. Also: hypergraph modularity (Kumar),
  homology, temporal hypergraphs, generators.
- **HypergraphX (HGX)** — measures, communities, motifs (Battiston group).
- **DHG (DeepHypergraph)** — HGNN/HGNN+/HyperGCN/UniGNN on PyTorch;
  `HypergraphConv` also in PyTorch Geometric; TopoNetX/TopoModelX for
  topological deep learning. (Neural tier; reference-only for us.)
- **TDA**: gudhi, ripser.py, giotto-tda — outclass both R TDA packages;
  candidate oracles for `wasserstein_distance()` too.
- **Text tiers**: BERTopic, Top2Vec, sentence-transformers, CTM — all native.

Consequence: every parked Nestimate item has a Python reference
implementation available for equivalence testing; the first-in-R claim stands.

## What R actually has (verified 2026-08-24 against CRAN)

- **Native CRAN**: `uwot` (UMAP), `dbscan` (HDBSCAN), `BTM` (short-text
  topics), `word2vec`/`doc2vec` (older native embeddings), `topicmodels`/`stm`
  (classical). `HyperG::knn_hypergraph` / `cluster_spectral` exist but are
  UNWEIGHTED only.
- **Python wrappers on CRAN**: `text` (HF transformer embeddings via
  reticulate — SimCSE/E5/BGE-class by model id), `BERTopic` 0.1.0 (reticulate
  wrapper of Python BERTopic — fit/transform/reduce/visualize).
- **Missing entirely**: native contrastive encoders; weighted hypergraph
  Laplacian; Zhou transduction; Hayashi EDVW clustering; weighted kNN
  hypergraphs. The last four are the parked Nestimate items.

So the embedding step is wrapper-only, but everything downstream of it can be
native R — and the statistical hypergraph layer is the genuine gap.

## Files

- `papers/` — 11 PDFs, every one title-verified after download (see TODO.md
  for the reading order).
- `TODO.md` — consolidated todos with target repo per item.
- `repos/` — one note per relevant repo/package, each separating VERIFIED
  facts (with date) from background knowledge, and naming its role for us
  (oracle / reference / out-of-scope):
  - ours: `nestimate-hypergraph-module.md` (the anchor)
  - R: `hyperg-r.md`, `simplicialcomplex-r.md`, `text-r.md`, `bertopic.md`
  - Python structural: `xgi.md`, `hypernetx.md`, `hypergraphx.md`
  - Python neural: `deephypergraph.md`, `hypergat-textclassification.md`,
    `allset.md`
  - TDA: `tda-python.md`

Related: `Nestimate/todo/COVERAGE-CATCHUP.md` (the Nestimate-side feature
items; §3 = HyperGAT), `Nestimate/HONETS-DELEGATION-PLAN.md` (higher-order
delegation — hypergraph module is NOT part of honets).
