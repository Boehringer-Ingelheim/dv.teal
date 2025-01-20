# Use a list to declare the specs

specs_list <- list

mod_teal <- specs_list(
  start = "mod_teal() should wrap teal modules so that they run within the module manager",
  dataset_switching = "Wrapped teal modules should work with the dataset switching functionality of {dv.manager}",
  global_filter = "Wrapped teal modules should work with the global filter functionality"
)

specs <- specs_list(
  mod_teal = mod_teal
)
