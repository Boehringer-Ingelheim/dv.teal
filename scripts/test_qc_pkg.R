#! /usr/local/bin/Rscript

success <- c(
  test = FALSE,
  valdoc = FALSE
)

# Getting package information ----
pkg_name <- read.dcf("DESCRIPTION")[1, "Package"]
pkg_version <- read.dcf("DESCRIPTION")[1, "Version"]

# Building ----

message("############################")
message("###### INSTALLING (S) ######")
message("############################")

devtools::install(upgrade = FALSE, args = "--install-tests")

message("############################")
message("###### INSTALLING (F) ######")
message("############################")

# Testing ----

message("##########################")
message("###### TESTING  (S) ######")
message("##########################")

reporter <- testthat::MultiReporter$new(
  list(
    testthat::ProgressReporter$new()
  )
)

test_results <- tibble::as_tibble(
  withr::with_envvar(
    new = list(CI = TRUE, no_proxy = "127.0.0.1", NOT_CRAN = TRUE, TESTTHAT_CPUS = 1),
    code = {
      testthat::set_max_fails(Inf)
      testthat::test_package(pkg_name, reporter, stop_on_failure = FALSE)
    }
  )
)

success[["test"]] <- (sum(test_results[["failed"]]) == 0) && !(any(test_results[["error"]]))

# Copy _snaps folder so it can be archived later for test debugging
# Empty if no errors are found
root <- Sys.getenv("GITHUB_WORKSPACE")
archive_folder <- file.path(root, "snaps_archive")
if (!dir.exists(archive_folder)) dir.create(archive_folder)

if (!success[["test"]]) {
  snap_folder <- system.file("tests/testthat/_snaps", package = pkg_name, mustWork = TRUE)
  file.copy(snap_folder, archive_folder, recursive = TRUE)
}

message("##########################")
message("###### TESTING  (F) ######")
message("##########################")

# Validation ----

message("#######################################")
message("###### RENDERING VALIDATION  (S) ######")
message("#######################################")

validation_root <- "./inst/validation"
validation_exists <- dir.exists(validation_root)
validation_report_rmd <- file.path(validation_root, "val_report.Rmd")
validation_skip <- file.path(validation_root, "skip_qc")
validation_report_html <- "val_report.html"
validation_results <- file.path(validation_root, "results")
val_param_rds <- file.path(validation_results, "val_param.rds")


if (!dir.exists(validation_root)) {
  message("### Quality Control documentation is not present")
  message("### Include quality control documentation or skip it by creating following file 'inst/validation/skip_qc'")
  stop("QC_doc_not_present")
}

if (file.exists(validation_skip)) {
  writeLines("", file.path(validation_results, "skipped_qc"))
  success[["valdoc"]] <- NA
} else {

stopifnot(file.exists(validation_report_rmd))
stopifnot(dir.exists(validation_results))
unlink(list.files(validation_results))

success[["valdoc"]] <- local({
  # This is evaluated inside a local because, otherwise, all the variables created in the chunks of the rendered
  # document leak into the environment

  saveRDS(
    list(
      package = pkg_name,
      tests = test_results,
      version = pkg_version
    ),
    val_param_rds
  )

  rmarkdown::render(
    input = validation_report_rmd,
    params = list(
      package = pkg_name,
      tests = test_results,
      version = pkg_version
    ),
    output_dir = validation_results,
    output_file = validation_report_html
  )

  # We use one of the leaked variables, created inside the validation report to asses if the validation is succesful or not
  VALIDATION_PASSED
})

}


message("#######################################")
message("###### RENDERING VALIDATION  (F) ######")
message("#######################################")

# Exit ----
message("##############################")
message("###### BUILD RESULT (S) ######")
message("##############################")

message(paste("Was", names(success), "successful?\t", success, collapse = "\n"))

# Write GITHUB ACTIONS summary
github_summary_file <- Sys.getenv("GITHUB_STEP_SUMMARY")
summary <- "# Test Summary"
summary <- c(
  summary,
  purrr::imap_chr(success, ~{
    symbol <- "\U02753"
    if (isTRUE(.x)) symbol <- "\U02705"
    if (isFALSE(.x)) symbol <- "\U0274C"
    if (is.na(.x)) symbol <- "\U02757"
    paste(" - ", symbol, .y)
  })
)

CON <- file(github_summary_file, "a")
on.exit(close(CON))
writeLines(summary, CON)

stopifnot(all(success | is.na(success)))

message("##############################")
message("###### BUILD RESULT (F) ######")
message("##############################")
