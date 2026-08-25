# texthypergraph — package roadmap

2026-08-25 (v3 — pivoted from "staging ground" to **the `texthypergraph` R
package**). This repo becomes the package; the papers/, repos/, and TODO.md
material stays as its research base (`.Rbuildignore`d).

**What the package is:** hypergraph text analysis in R — corpus in, weighted
text hypergraph out, spectral/statistical analysis through tidy verbs. First
of its kind on CRAN (gap verified 2026-08-24: no hypergraph text
classification exists in R at all, not even non-neural Zhou 2006).

**Ownership contract (no duplication):**

- `texthypergraph` owns: text → hypergraph **constructions**, text-facing
  analysis verbs, corpora, vignettes.
- `Nestimate` (Imports, via mohsaqr.r-universe.dev) keeps the engines it
  already ships: `bipartite_groups()`, `hypergraph_measures()`,
  `hypergraph_centrality()` (CEC + tensor Z/H), the Zhou/Hayashi Laplacian
  trio (clustering / transduction / embedding), `clique_expansion()`.
- `sbert` (Suggests) is the native embedding front-end; every verb also
  accepts a precomputed `embeddings` matrix so the package runs offline.
- `Saqrlab` gets the random hypergraph samplers (calibration studies).
- Oracles (local-only, never dependencies): HyperNetX (EDVW Laplacian,
  verified author-adjacent), XGI (tensor centralities), HyperG (unweighted
  constructions/samplers), gudhi (wasserstein). Full map: `repos/README.md`.

**Filter (house rules):** deterministic, base R + the two family Imports,
tidy one-verb APIs, every method oracle-tested before release, effect sizes +
CIs in vignettes, multi-seed sensitivity for every arbitrary choice (k,
window, threshold).

## v0.1 — Scaffold + the bridge (no new math)

**Status 2026-08-25:** skeleton, `text_hypergraph()`, and the four delegating
verbs are DONE — 60 tests pass, engine parity `identical()`, check clean
(1 environmental NOTE). Remaining: bundled corpus + bridge vignette + README.

- Package skeleton: DESCRIPTION, testthat 3e, pkgdown, CI matrix;
  papers/repos/TODO/ROADMAP `.Rbuildignore`d.
- `text_hypergraph(x, column, weight = c("n", "tfidf"))` — document–word
  incidence from raw text or any long table (base-R tokenization; quanteda
  dfm / tidytext tables accepted as inputs, never dependencies).
- Thin tidy verbs delegating to Nestimate: `hg_measures()`, `hg_centrality()`,
  `hg_cluster()`, `hg_classify()` (transduction), `hg_embed()` — one call,
  named arguments, tidy data.frame returns, print/summary/plot +
  `as.data.frame()` per house rules.
- Bundled corpus + the bridge vignette (the Phase-1 vignette, now living
  here instead of Nestimate).
- Gate: `--as-cran` clean; parity of every delegated verb against direct
  Nestimate calls (`identical()`).

## v0.2 — Text-native constructions

- **Windowed sequence hyperedges** — `text_hypergraph(construction =
  "window", w = )`: the HyperGAT construction, weighted/windowed extension.
  No upstream oracle; invariant-gated (window-count conservation; `w = 2`
  reduces exactly to `wtna_cooccurrence`).
- **kNN embedding hypergraph** — `knn_hypergraph(embeddings, k, weight =
  "cosine")` + `text_hypergraph(construction = "knn", model = )` calling
  sbert when installed. Construction oracle: `HyperG::knn_hypergraph`
  (unweighted). Vignette-first before the API freezes; k as a sensitivity
  axis, encoder-dependence reported per model.
- Gate: construction oracles/invariants + a real-corpus vignette for each.

## v0.3 — Theory completions (land in Nestimate, surfaced here)

- Chitra & Raphael (2019) edge-dependent random-walk centrality/PageRank —
  falsification invariant: edge-independent weights collapse to the
  plain-graph walk.
- `wasserstein_distance()` + `dual_hypergraph()` (oracles: SimplicialComplex,
  gudhi; HyperG for the dual).
- Saqrlab samplers (oracle `HyperG::sample_*`) → calibration/power vignette
  here.

## v1.0 — CRAN + the paper

- CRAN submission (the first-in-R claims re-verified against CRAN at
  submission).
- Flagship paper + vignette: **first fully-native R hypergraph text
  analysis** — sbert embeddings → kNN/windowed hyperedges → EDVW spectral
  clustering + transductive classification → tensor centralities; zero
  Python at runtime, oracle-verified against HyperNetX/XGI.
- BERTopic as the reported baseline (multi-seed, effect sizes + CIs).

## Out of scope

Neural training of any kind (HGNN/AllSet stay literature), PLM wrappers,
hMETIS/KaHyPar partitioning, retrieval stacks. Duplicating any Nestimate
engine here.
