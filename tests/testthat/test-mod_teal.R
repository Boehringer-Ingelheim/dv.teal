# nolint start

testthat::test_that("mod_teal enables running teal modules inside Module Manager" %>%
  vdoc[["add_spec"]](specs$mod_teal$start), {

  app_dir <- "./apps/mod_teal/"
  app <- shinytest2::AppDriver$new(app_dir = app_dir, name = "mod_teal", height = 964, width = 1611)

  # necessary to set this to fixed values since the default uses a
  # time stamp which causes the test to fail
  app$set_inputs("distribution-hist_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("distribution-qq_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("out-box_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("out-cum_density_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("out-density_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("sum-table-downbutton-file_name" = "test_file_name")
  app$set_inputs("events-table-downbutton-file_name" = "test_file_name")


  app$wait_for_idle()
  expected <- app$get_values()
  testthat::expect_snapshot(expected, cran = TRUE)

  app$set_inputs(main_tab_panel = "Outliers")
  app$wait_for_idle()
  expected <- app$get_values()
  testthat::expect_snapshot(expected, cran = TRUE)


  app$set_inputs(main_tab_panel = "Summary")
  app$wait_for_idle()
  expected <- app$get_values()
  testthat::expect_snapshot(expected, cran = TRUE)

  app$set_inputs(main_tab_panel = "distribution")
  app$wait_for_idle()
  expected <- app$get_values()
  testthat::expect_snapshot(expected, cran = TRUE)
  app$stop()
})


test_that("mod_teal works with global filter" %>%
  vdoc[["add_spec"]](specs$mod_teal$global_filter), {

  app_dir <- "./apps/mod_teal/"
  app <- shinytest2::AppDriver$new(app_dir = app_dir, name = "mod_teal_global_filter", height = 964, width = 1611)

  # necessary to set this to fixed values since the default uses a
  # time stamp which causes the test to fail
  app$set_inputs("distribution-hist_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("distribution-qq_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("out-box_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("out-cum_density_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("out-density_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("sum-table-downbutton-file_name" = "test_file_name")
  app$set_inputs("events-table-downbutton-file_name" = "test_file_name")

  app$wait_for_idle()
  expected <- app$get_values()
  testthat::expect_snapshot(expected, cran = TRUE)

  app$set_inputs(`global_filter-vars` = "ARM")
  app$set_inputs(`global_filter-ARM` = c("Placebo", "Screen Failure"))

  app$wait_for_idle()
  expected <- app$get_values()
  testthat::expect_snapshot(expected, cran = TRUE)

  app$stop()
})

test_that("mod_teal works with dataset switching" %>%
  vdoc[["add_spec"]](specs$mod_teal$dataset_switching), {

  app_dir <- "./apps/mod_teal/"
  app <- shinytest2::AppDriver$new(app_dir = app_dir, name = "mod_teal_dataset_switching", height = 964, width = 1611)

  # necessary to set this to fixed values since the default uses a
  # time stamp which causes the test to fail
  app$set_inputs("distribution-hist_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("distribution-qq_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("out-box_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("out-cum_density_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("out-density_plot-downbutton-file_name" = "test_file_name")
  app$set_inputs("sum-table-downbutton-file_name" = "test_file_name")
  app$set_inputs("events-table-downbutton-file_name" = "test_file_name")

  app$wait_for_idle()
  app$set_inputs(selector = "demo2")

  app$wait_for_idle()
  expected <- app$get_values()
  testthat::expect_snapshot(expected, cran = TRUE)

  app$stop()
})

# nolint end
