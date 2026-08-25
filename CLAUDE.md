# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

The **`texthypergraph` R package**: hypergraph text analysis — corpus in,
weighted document–word hypergraph out, analysis through tidy verbs. It was a
documentation-only staging ground until 2026-08-25; the literature base
(`papers/`, `repos/`, `TODO.md`) remains in-tree but `.Rbuildignore`d.
`ROADMAP.md` is the authoritative plan; `repos/README.md` maps every external
repo to its role (equivalence oracle vs guiding reference).

## Ownership contract (never duplicate)

- **This package owns**: text → hypergraph constructions
  (`text_hypergraph()`), text-facing tidy verbs (`hg_*`), corpora, vignettes.
- **Nestimate** (Imports, r-universe) is a FROZEN dependency (2026-08-25:
  Nestimate is not being expanded). Its shipped engines are delegated to
  as-is: `bipartite_groups()`, `hypergraph_measures()`,
  `hypergraph_centrality()`, `hypergraph_cluster()`,
  `hypergraph_transduction()`, `hypergraph_laplacian()`, `wtna()`. New
  numerical methods (v0.3+: EDVW random-walk centrality, dual, null models)
  are implemented HERE with their own oracle/invariant gates — never added
  to Nestimate, and never duplicating an engine it already ships.
- **sbert** (Suggests, planned v0.2) provides native embeddings for the kNN
  construction; every verb must also accept precomputed embeddings.
- Oracles (HyperNetX, XGI, HyperG, gudhi) are used reticulate/local-only in
  `local_testing_and_equivalence/` (build-ignored) — never dependencies.

## Commands

```bash
/usr/local/bin/Rscript -e 'devtools::test(".")'          # run all tests
/usr/local/bin/Rscript -e 'testthat::test_file("tests/testthat/test-verbs.R")'
/usr/local/bin/Rscript -e 'devtools::document(".")'      # roxygen -> man/, NAMESPACE
/usr/local/bin/Rscript -e 'devtools::check(".", args = "--no-manual")'
```

Use `/usr/local/bin/Rscript` (R 4.5.2) — the Homebrew R 4.6 library lacks the
family packages. Nestimate >= 0.9.0 must be installed.

## Architecture

- `R/text_hypergraph.R` — constructor: base-R deterministic tokenization →
  document–word counts → `Nestimate::bipartite_groups()`. Key design points:
  `nodes = c("doc", "word")` picks the vertex set (docs-as-nodes default =
  the Hayashi 2020 document-clustering orientation; words-as-nodes = the
  HyperGAT orientation); `weight = "tfidf"` uses the *smoothed* idf
  `log((1+N)/(1+df)) + 1` so no weight is ever zero (a zero would silently
  disconnect a vertex). Returns class `c("text_hypergraph",
  "net_hypergraph")` — Nestimate verbs accept it directly. Corpus tables live
  in `$text` and are reached via `as.data.frame(hg, what = "weights" |
  "documents" | "vocabulary")`, never by `$`-reaching in user code.
- `R/verbs.R` — `hg_measures()`, `hg_centrality()`, `hg_cluster()`,
  `hg_classify()`: validate with `.thg_check_hg()`, delegate, tidy. Parity
  with direct engine calls is asserted by `identical()` in tests.
- Condition classes are namespaced `thg_*` (`thg_bad_input`,
  `thg_empty_corpus`, `thg_dropped_documents`); tests assert classes, not
  messages.

## Conventions and gotchas

- **Connectivity**: `hg_cluster()`/`hg_classify()` inherit Nestimate's classed
  `nestimate_hypergraph_disconnected` error. Doc-mode corpora are connected
  only if shared words chain every document — test/example corpora use a
  deliberate bridge word ("night").
- House R rules apply in full (the `saqr_AR` skill / global CLAUDE.md):
  tidy verbs not brackets on any public surface, no `for` loops, named
  `stopifnot()` contracts, classed conditions, hand-computed fixtures plus
  invariant tests for anything numerical, break-the-implementation sanity
  checks for new tests.
- Every roadmap method names its equivalence oracle **before**
  implementation; status changes are mirrored in `TODO.md` and
  `Nestimate/todo/COVERAGE-CATCHUP.md`.
- Session artifacts (`HANDOFF.md`, `LEARNINGS.md`, `CHANGES.md`) are never
  committed. Read them at session start.
