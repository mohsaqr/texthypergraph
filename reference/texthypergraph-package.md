# texthypergraph: Hypergraph Text Analysis

Builds weighted hypergraphs from text corpora and analyzes them with
tidy verbs. Documents and words form a bipartite incidence structure
that becomes a hypergraph in either orientation: documents as vertices
connected by shared words, or words as vertices connected by shared
documents. Term weighting supports raw counts and smoothed tf-idf
following Manning, Raghavan and Schutze (2008, ISBN:9780521865715).
Spectral analysis implements the normalized hypergraph Laplacian of
Zhou, Huang and Schoelkopf (2006) and the random-walk Laplacian with
edge-dependent vertex weights of Hayashi, Aksoy, Park and Park (2020)
[doi:10.1145/3340531.3412034](https://doi.org/10.1145/3340531.3412034) ,
with spectral clustering and transductive classification; structural
measures and tensor eigenvector centralities are delegated to the
'Nestimate' engines.

## See also

Useful links:

- <https://github.com/mohsaqr/texthypergraph>

- Report bugs at <https://github.com/mohsaqr/texthypergraph/issues>

## Author

**Maintainer**: Mohammed Saqr <mohammed.saqr@uef.fi>
([ORCID](https://orcid.org/0000-0001-5881-3109)) \[copyright holder\]
