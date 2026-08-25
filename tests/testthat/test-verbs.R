# Delegating verbs: parity with the Nestimate engines, tidy shapes, conditions.

verb_corpus <- c(
  cooking_1 = "simmer the soup with onions and carrots",
  cooking_2 = "this soup recipe needs salt on a cold night",
  space_1 = "the telescope revealed a distant galaxy and stars",
  space_2 = "astronomers aimed the telescope at the stars all night"
)
verb_stop <- c("the", "with", "and", "a", "this", "at", "on", "all")

test_that("hg_measures matches the engine and returns tidy tables", {
  hg <- text_hypergraph(verb_corpus, stop_words = verb_stop)
  m <- Nestimate::hypergraph_measures(hg)

  nodes <- hg_measures(hg, what = "nodes")
  expect_identical(nodes$node, names(m$hyperdegree))
  expect_identical(nodes$hyperdegree, unname(as.integer(m$hyperdegree)))
  expect_identical(nodes$strength, unname(as.numeric(m$node_strength)))
  expect_identical(nrow(nodes), hg$n_nodes)

  edges <- hg_measures(hg, what = "edges")
  expect_identical(edges$edge, colnames(hg$incidence))
  expect_identical(edges$size, unname(as.integer(m$edge_sizes)))

  overlap <- hg_measures(hg, what = "overlap")
  expect_identical(
    nrow(overlap),
    (hg$n_hyperedges * (hg$n_hyperedges - 1L)) %/% 2L
  )
  expect_true(all(overlap$jaccard >= 0 & overlap$jaccard <= 1))

  summary_tab <- hg_measures(hg, what = "summary")
  expect_identical(names(summary_tab), c("measure", "value"))
  expect_identical(
    summary_tab$value[summary_tab$measure == "n_nodes"],
    as.numeric(hg$n_nodes)
  )
})

test_that("hg_centrality matches the engine value for value", {
  hg <- text_hypergraph(verb_corpus, stop_words = verb_stop)
  direct <- Nestimate::hypergraph_centrality(hg, type = c("clique", "Z", "H"))

  tab <- hg_centrality(hg)
  expect_identical(names(tab), c("node", "clique", "Z", "H"))
  expect_identical(tab$node, names(direct$clique))
  expect_identical(tab$clique, unname(as.numeric(direct$clique)))
  expect_identical(tab$Z, unname(as.numeric(direct$Z)))
  expect_identical(tab$H, unname(as.numeric(direct$H)))

  one <- hg_centrality(hg, type = "clique")
  expect_identical(names(one), c("node", "clique"))
})

test_that("hg_cluster matches the seeded engine partition and is reproducible", {
  hg <- text_hypergraph(verb_corpus, stop_words = verb_stop)
  direct <- Nestimate::hypergraph_cluster(hg, k = 2, type = "random_walk",
                                          seed = 7)
  expected <- direct$clusters
  rownames(expected) <- NULL

  tab <- hg_cluster(hg, k = 2, type = "random_walk", seed = 7)
  expect_identical(tab, expected)
  expect_identical(tab, hg_cluster(hg, k = 2, type = "random_walk", seed = 7))
  expect_identical(nrow(tab), hg$n_nodes)
  expect_identical(length(unique(tab$cluster)), 2L)
})

test_that("hg_classify matches the engine and preserves given labels", {
  hg <- text_hypergraph(verb_corpus, stop_words = verb_stop)
  labels <- c(cooking_1 = "cooking", space_1 = "space")
  direct <- Nestimate::hypergraph_transduction(hg, labels = labels)
  expected <- direct$predictions
  rownames(expected) <- NULL

  tab <- hg_classify(hg, labels = labels)
  expect_identical(tab, expected)
  expect_identical(names(tab),
                   c("node", "label", "predicted", "score", "margin"))
  expect_identical(
    tab$label[tab$node == "cooking_1"],
    "cooking"
  )
  expect_true(is.na(tab$label[tab$node == "cooking_2"]))
})

test_that("every verb rejects a non-hypergraph with a classed error", {
  expect_error(hg_measures(42), class = "thg_bad_input")
  expect_error(hg_centrality(list()), class = "thg_bad_input")
  expect_error(hg_cluster("x", k = 2), class = "thg_bad_input")
  expect_error(hg_classify(NULL, labels = c(a = "x")),
               class = "thg_bad_input")
})
