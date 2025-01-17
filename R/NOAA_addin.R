#' Ocean explorer addin
#'
#' @param server Server function.
#' @param extended Boolean whether to launch the extended app (default = `TRUE`)
#'  or the limited version for usage as a RStudio gadget.
#'
#' @return Rstudio gadget
#' @export
NOAA_addin <- function(server = NOAA_server(extended = FALSE)) {

  ui <- miniPage(
    shinyjs::useShinyjs(), # use shinyjs
    gadgetTitleBar("NOAA WORLD OCEAN ATLAS"),
    miniTabstripPanel(
      id = "tabset",
      miniTabPanel(
        "Parameters",
        icon = icon("sliders-h"),
        miniContentPanel(
          waiter::use_waiter(),
          input_ui("NOAA", citation = citation_ui("NOAA"), extended = FALSE),
          )
      ),
      miniTabPanel(
        "Map",
        icon = icon("map-marked-alt"),
        miniContentPanel(
          padding = 0,
          plot_ui("worldmap")
          ),
        filter_ui("depth", extended = FALSE)
      ),
      miniTabPanel(
        "Table",
        icon = icon("table"),
        miniContentPanel(table_ui("table"))
      )
    )
  )

  runGadget(shinyApp(ui, server), viewer = paneViewer())
  }
