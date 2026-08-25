# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A **documentation-only staging ground** — no code, no build, no tests. It holds
literature, links, and consolidated todos for hypergraph methods on text/NLP
and sequence data, gathered from the 2026-08-24 coverage comparisons run from
Nestimate. Its job is to decide *where* each method lands:

- **Nestimate** (`../Nestimate`) — statistical R core (the anchor; its shipped
  hypergraph module is described in `repos/nestimate-hypergraph-module.md`)
- **Saqrlab** — simulation (random hypergraph samplers)
- **carm-text / carm-ml** — JS side, only if ever

Implementation work happens in those repos, never here. When an item ships
elsewhere, this repo's records are updated to say so (see Maintenance below).

## Layout

- `README.md` — the method map (tiered: statistical → text-specific neural →
  general HGNN → PLM baseline), the R/CRAN and Python ecosystem surveys, and
  the "existing bridge" note (quanteda/tidytext → `bipartite_groups()`).
- `TODO.md` — consolidated todos, **each item names its target repo**. The
  Nestimate items are a superset view of `Nestimate/todo/COVERAGE-CATCHUP.md`;
  keep the two in sync when status changes.
- `papers/` — 11 PDFs named `YYYY-Venue-ShortName-FirstAuthor.pdf`. Every PDF
  was title-verified after download. TODO.md ends with the reading order.
- `repos/` — one note per external repo/package/library surveyed.

## Conventions (the actual contract of this repo)

1. **Verified vs background is strictly separated and dated.** Every `repos/`
   note distinguishes facts checked against source/docs on a stated date
   ("Verified 2026-08-25: …") from background knowledge, and lists what was
   *not* verified. Never promote a background claim to verified without
   actually checking it in this session, and stamp the check date.
2. **Every `repos/` note names its role for us**: oracle (equivalence-test
   reference via reticulate — never a declared dependency), reference, or
   out-of-scope. New notes follow the same skeleton: What / Verified (date) /
   Relevance / Role for us / Not verified / Links.
3. **TODO items carry their oracle.** Each planned method names the reference
   implementation it will be equivalence-tested against (e.g. HyperNetX
   `laplacians_clustering` for the Zhou/Hayashi Laplacian, XGI for the tensor
   centralities, `HyperG` for unweighted cases).
4. **First-in-R claims are load-bearing.** The README asserts several methods
   exist nowhere on CRAN (checked 2026-08-24 via `CRAN_package_db`). If you
   touch those claims, re-verify against CRAN and update the check date.
5. **Papers added to `papers/` must be title-verified** after download and
   entered into the README method map and the TODO reading order.

## Maintenance

- When a TODO item is implemented in its target repo, mark it
  `[x] DONE YYYY-MM-DD in <repo> <file>` with the parity/oracle evidence
  (see the completed Zhou/Hayashi entry for the format), update the README
  status column, and mirror the status in
  `Nestimate/todo/COVERAGE-CATCHUP.md` if it is a Nestimate item.
- Commit messages here follow the existing style: a scope prefix
  (`TODO:`, `repos/:`, section name) plus a one-line factual summary,
  often with the date of the verification the commit records.

## Cross-references

- `Nestimate/todo/COVERAGE-CATCHUP.md` — Nestimate-side feature items
  (§3 = HyperGAT windowed construction).
- `Nestimate/HONETS-DELEGATION-PLAN.md` — the hypergraph module is NOT part
  of honets; HON-family Python (pathpy/pyHON/HYPA/HONEM) is already covered
  as oracles there (`repos/pathpy-hon-python.md`).
- `Nestimate/local_testing_and_equivalence/test-equiv-hypergraph.R` — where
  new oracle cross-checks (e.g. XGI) get added.
