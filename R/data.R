#' COVID-19 education research abstracts
#'
#' A deterministic stratified sample of 165 abstracts (up to 40 per year,
#' 2020--2024) from a Scopus export of COVID-19 education research, the same
#' source corpus used by the `sbert` package's topic-modeling articles.
#' Rebuilt by `data-raw/covid_abstracts.R`.
#'
#' @format A data frame with 165 rows and 4 columns:
#' \describe{
#'   \item{doc}{Scopus EID, the unique document identifier.}
#'   \item{title}{Article title.}
#'   \item{abstract}{Abstract text (each at least 400 characters).}
#'   \item{year}{Publication year (integer, 2020--2024).}
#' }
#' @source Scopus export of COVID-19 education research, 2020--2024.
#' @examples
#' hg <- text_hypergraph(covid_abstracts, column = "abstract", id = "doc")
#' hg
"covid_abstracts"
