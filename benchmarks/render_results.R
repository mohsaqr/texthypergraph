# Render benchmarks/results/*.csv as markdown tables (stdout), so every
# number in RESULTS.md and the pkgdown article is generated, never typed.
# Usage: /usr/local/bin/Rscript benchmarks/render_results.R

results_dir <- file.path("benchmarks", "results")
files <- list.files(results_dir, pattern = "^(R8|R52|mr|ohsumed|20ng)\\.csv$",
                    full.names = TRUE)
stopifnot("no result files found -- run benchmarks/run_benchmarks.R" =
            length(files) > 0L)
results <- do.call(rbind, lapply(files, utils::read.csv))

fmt <- function(x, digits = 4) formatC(x, format = "f", digits = digits)

row_md <- function(r) {
  sprintf("| %s | %s | %s [%s, %s] | %s | %d | %.1f | %.2f |",
          r$dataset, r$method, fmt(r$accuracy), fmt(r$ci_low),
          fmt(r$ci_high), fmt(r$macro_f1), r$n_unscored, r$build_s, r$fit_s)
}

cat("| Dataset | Method | Accuracy [95% CI] | Macro-F1 | Unscored |",
    "Build (s) | Fit (s) |\n")
cat("|---|---|---|---|---|---|---|\n")
ord <- order(match(results$dataset, c("20ng", "R8", "R52", "ohsumed", "mr")),
             results$method)
invisible(lapply(seq_len(nrow(results)),
                 \(i) cat(row_md(results[ord, ][i, ]), "\n")))

lowlabel_file <- file.path(results_dir, "lowlabel.csv")
if (file.exists(lowlabel_file)) {
  low <- utils::read.csv(lowlabel_file)
  cat("\n| Dataset | Seed fraction | Seeds | Method | Accuracy (mean) |",
      "SD over draws |\n")
  cat("|---|---|---|---|---|---|\n")
  lord <- order(low$dataset, low$fraction, low$method)
  invisible(lapply(seq_len(nrow(low)), \(i) {
    r <- low[lord, ][i, ]
    cat(sprintf("| %s | %d%% | %d | %s | %s | %s |\n",
                r$dataset, round(100 * r$fraction), r$n_seeds, r$method,
                fmt(r$accuracy), fmt(r$sd)))
  }))
}
