# texthypergraph — package roadmap

2026-08-25 (v3 — pivoted from “staging ground” to **the `texthypergraph`
R package**). This repo becomes the package; the papers/, repos/, and
TODO.md material stays as its research base (`.Rbuildignore`d).

**What the package is:** hypergraph text analysis in R — corpus in,
weighted text hypergraph out, spectral/statistical analysis through tidy
verbs. First of its kind on CRAN (gap verified 2026-08-24: no hypergraph
text classification exists in R at all, not even non-neural Zhou 2006).

**Ownership contract (no duplication):**

- `texthypergraph` owns: text → hypergraph **constructions**,
  text-facing analysis verbs, corpora, vignettes.
- `Nestimate` (Imports, via mohsaqr.r-universe.dev) is a **frozen
  dependency** (decision 2026-08-25: Nestimate is not being expanded).
  Its shipped engines are used as-is: `bipartite_groups()`,
  `hypergraph_measures()`, `hypergraph_centrality()` (CEC + tensor Z/H),
  the Zhou/Hayashi Laplacian trio, `clique_expansion()`, `wtna()`.
  **Every NEW method is implemented in texthypergraph**, with its own
  oracle/invariant gates — nothing new goes into Nestimate.
- `sbert` (Suggests) is the native embedding front-end; every verb also
  accepts a precomputed `embeddings` matrix so the package runs offline.
- Oracles (local-only, never dependencies): HyperNetX (EDVW Laplacian,
  verified author-adjacent), XGI (tensor centralities), HyperG
  (unweighted constructions/samplers), gudhi (wasserstein). Full map:
  `repos/README.md`.

**Filter (house rules):** deterministic, base R + the two family
Imports, tidy one-verb APIs, every method oracle-tested before release,
effect sizes + CIs in vignettes, multi-seed sensitivity for every
arbitrary choice (k, window, threshold).

## v0.1 — Scaffold + the bridge (no new math)

**Status 2026-08-25: v0.1 COMPLETE.** Skeleton,
[`text_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/text_hypergraph.md)
(+ curly-apostrophe normalization),
[`stop_words_en()`](https://mohsaqr.github.io/texthypergraph/reference/stop_words_en.md),
four delegating verbs (+ `sort_by`/`n` on centrality), `covid_abstracts`
dataset (165 abstracts, 2020-2024), full worked vignette (clustering +
k-sensitivity + few-label classification with verified numbers), package
README. 74 tests pass, engine parity
[`identical()`](https://rdrr.io/r/base/identical.html), R CMD check 0
errors / 0 warnings / 1 environmental NOTE.

- Package skeleton: DESCRIPTION, testthat 3e, pkgdown, CI matrix;
  papers/repos/TODO/ROADMAP `.Rbuildignore`d.
- `text_hypergraph(x, column, weight = c("n", "tfidf"))` — document–word
  incidence from raw text or any long table (base-R tokenization;
  quanteda dfm / tidytext tables accepted as inputs, never
  dependencies).
- Thin tidy verbs delegating to Nestimate:
  [`hg_measures()`](https://mohsaqr.github.io/texthypergraph/reference/hg_measures.md),
  [`hg_centrality()`](https://mohsaqr.github.io/texthypergraph/reference/hg_centrality.md),
  [`hg_cluster()`](https://mohsaqr.github.io/texthypergraph/reference/hg_cluster.md),
  [`hg_classify()`](https://mohsaqr.github.io/texthypergraph/reference/hg_classify.md)
  (transduction), `hg_embed()` — one call, named arguments, tidy
  data.frame returns, print/summary/plot +
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html) per
  house rules.
- Bundled corpus + the bridge vignette (the Phase-1 vignette, now living
  here instead of Nestimate).
- Gate: `--as-cran` clean; parity of every delegated verb against direct
  Nestimate calls
  ([`identical()`](https://rdrr.io/r/base/identical.html)).

## v0.2 — Text-native constructions

**Status 2026-08-25: v0.2 COMPLETE.** Both constructions shipped:
`text_hypergraph(construction = "window")` (sliding/tumbling, set-valued
window hyperedges; w = 2 off-diagonal parity with
[`Nestimate::wtna()`](https://saqr.me/Nestimate/reference/wtna.html)
shipped as a package test — diagonals differ by design, wtna counts
within-window repeats) and `construction = "knn"` +
[`knn_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/knn_hypergraph.md)
(cosine-weighted, deterministic tie-breaks, classed refusal of
non-positive similarities; binary support verified identical to
`HyperG::knn_hypergraph` in local_testing_and_equivalence/).
`covid_embeddings` bundled (sbert all-MiniLM-L6-v2, 165x384).
[`vignette("constructions")`](https://mohsaqr.github.io/texthypergraph/articles/constructions.md)
demonstrates both on the real corpus with w and k sensitivity checks.
136 tests; check 0 / 0 / 1 environmental NOTE. Version 0.2.0.

- **Windowed sequence hyperedges** —
  `text_hypergraph(construction = "window", w = )`: the HyperGAT
  construction, weighted/windowed extension. No upstream oracle;
  invariant-gated (window-count conservation; `w = 2` reduces exactly to
  `wtna_cooccurrence`).
- **kNN embedding hypergraph** —
  `knn_hypergraph(embeddings, k, weight = "cosine")` +
  `text_hypergraph(construction = "knn", model = )` calling sbert when
  installed. Construction oracle: `HyperG::knn_hypergraph` (unweighted).
  Vignette-first before the API freezes; k as a sensitivity axis,
  encoder-dependence reported per model.
- Gate: construction oracles/invariants + a real-corpus vignette for
  each.

## v0.3 — Theory completions (implemented HERE; Nestimate frozen)

**Status 2026-08-25: v0.3 COMPLETE** (hg_pagerank + dual_hypergraph +
hg_null_test; 180 tests; check 0/0/1 environmental NOTE; version 0.3.0).

DONE 2026-08-25:
**[`hg_pagerank()`](https://mohsaqr.github.io/texthypergraph/reference/hg_pagerank.md)**
(Chitra & Raphael 2019 EDVW walk

- damping/personalization). Four verification layers: direct
  linear-solve reference; collapse-theorem closed form (1e-12);
  Nestimate `$pi` parity (1e-12); HyperNetX
  `get_pi(prob_trans(weights=TRUE))` parity (1.4e-16).

DONE 2026-08-25:
**[`dual_hypergraph()`](https://mohsaqr.github.io/texthypergraph/reference/dual_hypergraph.md)**
— transpose identity, involution, and dual ==
opposite-orientation-construction tests shipped; HyperG::dual_hypergraph
support parity PASS (local).

DONE 2026-08-25:
**[`hg_null_test()`](https://mohsaqr.github.io/texthypergraph/reference/hg_null_test.md)**
— degree-preserving checkerboard null (Gotelli 2000), permutation p
(Phipson & Smyth 2010), null quantiles + z; margin-conservation and
blocky-structure detection tests shipped; avg_edge_size invariance as
built-in falsification.

Gate: same discipline — hand-computed fixtures, invariants, oracle
scripts, real-corpus vignette.

## v1.0 — CRAN + the paper

- CRAN submission (the first-in-R claims re-verified against CRAN at
  submission).
- Flagship paper + vignette: **first fully-native R hypergraph text
  analysis** — sbert embeddings → kNN/windowed hyperedges → EDVW
  spectral clustering + transductive classification → tensor
  centralities; zero Python at runtime, oracle-verified against
  HyperNetX/XGI.
- BERTopic as the reported baseline (multi-seed, effect sizes + CIs).

## Out of scope

Neural training of any kind (HGNN/AllSet stay literature), PLM wrappers,
hMETIS/KaHyPar partitioning, retrieval stacks. Duplicating any Nestimate
engine here.
