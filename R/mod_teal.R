#' Wrapper function for teal modules to enable their use with `dv.manager`
#'
#' @param module_id `[character(1)]`
#'
#' Unique identifier for the module.
#' @param teal_module `[teal_module]`
#'
#' Teal module like [teal.modules.clinical::tm_t_events()]
#' @param j_keys `[join_keys]`
#'
#' object with dataset column relationships used for joining. Will be created by [teal.data::join_keys()]
#'
#' @return A list containing the following elements to be used by
#' \pkg{dv.manager}:
#' \itemize{
#' \item{\code{ui}: A UI function of the \pkg{dv.teal} module.}
#' \item{\code{server}: A server function of the \pkg{dv.teal} module.}
#' \item{\code{module_id}: A unique identifier.}
#' }
#'
#' @export
#'
#' @examples
#'\dontrun{
#' dm <- pharmaversesdtm::dm
#'
#' ae <- pharmaversesdtm::ae
#'
#' data_list <- list(
#'   dm = dm,
#'   ae = ae
#' )
#'
#' j_keys <- teal.data::join_keys(
#'   teal.data::join_key(
#'     "dm",
#'     keys = c("STUDYID", "USUBJID")
#'   ),
#'   teal.data::join_key(
#'     "ae",
#'     keys = c("STUDYID", "USUBJID")
#'   ),
#'   teal.data::join_key(
#'     "dm",
#'     "ae",
#'     keys = c("STUDYID", "USUBJID")
#'   )
#' )
#'
#' mod_events <- teal.modules.clinical::tm_t_events(
#'   label = "Adverse Event Table",
#'   dataname = "ae",
#'   parentname = "dm",
#'   arm_var = choices_selected(c("ARM", "ARMCD"), "ARM"),
#'   llt = choices_selected(
#'     choices = variable_choices(ae, c("AETERM", "AEDECOD")),
#'     selected = c("AEDECOD")
#'   ),
#'   hlt = choices_selected(
#'     choices = variable_choices(ae, c("AEBODSYS", "AESOC")),
#'     selected = "AEBODSYS"
#'   ),
#'   add_total = TRUE,
#'   event_type = "adverse event"
#' )
#'
#' module_list <- list(
#'   "Events" = mod_teal(
#'     module_id = "events",
#'     teal_module = mod_events,
#'     j_keys = j_keys
#'   )
#' )
#'
#' dv.manager::run_app(
#'   data = list("demo" = data_list),
#'   module_list = module_list,
#'   filter_data = "dm"
#' )
#'}
mod_teal <- function(
  module_id,
  teal_module,
  j_keys = teal.data::join_keys()
) {

  checkmate::assert_string(module_id)
  checkmate::assert_multi_class(teal_module, "teal_module")
  # with teal.modules.clinical version 0.10.0 transformators were introduced
  # to account for that and still be able to work with older versions the if statement is needed
  if (length(names(teal_module)) == 6) {
    checkmate::assert_set_equal(names(teal_module), c("label", "server", "ui", "datanames", "server_args", "ui_args"))
  } else {
    checkmate::assert_set_equal(
      names(teal_module),
      c("label", "server", "ui", "datanames", "server_args", "ui_args", "transformators")
      )
  }
  checkmate::assert_multi_class(j_keys, c("join_keys", "list"))

  mod <- list(
    ui = function(module_id) {
      ui <- shiny::tagList(
        shiny::tags$head(
          shiny::tags$style(
            shiny::HTML(
              # width of the picker inputs is set to 100% in teal.widgets
              # set width of the picker inputs inside the global filter div back to auto
              "div.menu-contents .dropdown-menu.open {
                 width: auto;
              }"
            )
          )
        ),
        do.call(
          teal_module$ui,
          args = c(
            id = module_id,
            teal_module$ui_args
          )
        )
      )

      # create tag query list to remove the teal reporter
      tag_query <- htmltools::tagQuery(ui)

      # remove reporter from ui
      # the div with class block mb-4 p-1 contains the ui for the reporter
      updated_tag_query <- tag_query$find("div")$filter(".block.mb-4.p-1")$remove()
      # select all tags to be displayed
      updated_tag_query$allTags()
    },

    server = function(afmm) {

      data_list <- shiny::reactive({

        # filtered_dataset throws an error after switching datasets
        if (is(try(afmm$filtered_dataset(), silent = TRUE), "try-error")) {
          base_data <- afmm$unfiltered_dataset()
        } else {
          base_data <- afmm$filtered_dataset()
        }


        if ("all" %in% names(base_data)) {
          warning(
            paste(
              "You should not name input datasets \"all\", because this might cause problems,",
              "since teal uses \"all\" to check if all",
              "datasets provided (e.g. adsl, adae, ...) should be used."
            )
          )
        }

        if (length(teal_module$datanames) == 1 && teal_module$datanames == "all") {
          data <- base_data
        } else {
          data <- base_data[teal_module$datanames]
        }

        t_data <- do.call(
          teal.data::teal_data,
          args = c(
            data
          )
        )

        checkmate::assert_subset(names(data), names(j_keys), .var.name = "j_keys")

        teal.data::join_keys(t_data) <- j_keys

        t_data

      })

      ## The observeEvent is needed because for some modules in teal.modules.general a reactive environment is missing
      ## this will hopefully be changed for the next release of teal.modules.general > 0.3.0
      ## we should revisit this approach after the new release of teal.modules.general
      shiny::observeEvent(data_list(), {
        shiny::req(data_list())
        do.call(
          teal_module$server,
          args = c(
            id = module_id,
            data = data_list,
            teal_module$server_args
          )
        )
     }, once = TRUE) # needed for not re-running each time the global filter changes the data_list and with that reset the module state #nolint

    },
    module_id = module_id
  )

  if (length(teal_module$datanames) > 1 || teal_module$datanames != "all") {
    mod$meta <- list(
      dataset_info = list(
        all = teal_module$datanames
      )
    )
  }
  return(mod)
}
