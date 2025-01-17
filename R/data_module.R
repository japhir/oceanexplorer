#' NOAA data module
#'
#' @param id Namespace id shiny module.
#' @param NOAA Reactive value for the dataset containing the locations
#'  coordinates.
#' @param citation Additional space for citation element.
#' @param variable Reactive value for the selected variable name.
#' @param extended Boolean whether to build the extended module
#'  (default = `TRUE`).
#'
#' @return Shiny module.
#' @export
input_ui <- function(id, citation = NULL, extended = TRUE) {

  vars <- tagList(
    selectInput(
      NS(id, "var"),
      h5("Variable"),
      choices = c("temperature", "phosphate", "nitrate", "silicate", "oxygen",
                  "salinity", "density")
    ),
    selectInput(
      NS(id, "spat"),
      h5("Resolution"),
      choices = c(1, 5)
    ),
    selectInput(
      NS(id, "temp"),
      h5("Averaging"),
      choices = c("annual", month.name, "winter", "spring", "summer", "autumn")
    )
  )

  load <- tagList(
    tags$br(),
    tags$br(),
    actionButton(NS(id, "go"), h5("Load data")),
    tags$br(),
    tags$br(),
    citation,
  )

  if (isTRUE(extended)) {
    layout <- tagList(
      fluidRow(column(6, vars[[1]], vars[[2]]), column(6, vars[[3]]))
    )
    tagAppendChildren(layout, load)
  } else {
    fillRow(fillCol(vars), fillCol(load))
  }
}
#' @rdname input_ui
#'
#' @export
citation_ui <- function(id) {

  tagList(tags$br(), tags$br(), uiOutput(NS(id,  "citation")))

}
#' @rdname input_ui
#'
#' @export
output_ui <- function(id) {
  downloadButton(NS(id, "download"), "Download")
}
#' @rdname input_ui
#'
#' @export
input_server <- function(id) {

  moduleServer(id, function(input, output, session) {

    # citation
    output$citation <- renderUI({

      if (input$var %in% c("phosphate", "nitrate", "silicate")) {
        citations("nutrients")
      } else {
        citations(input$var)
      }
    }) %>%
      bindEvent(input$go)

    # input data
    x <- eventReactive(input$go, {
      waiter <- waiter::Waiter$new()
      waiter$show()
      on.exit(waiter$hide())

      # call for data retrieval
      call_NOAA <- glue::glue("get_NOAA({glue::double_quote(input$var)},",
                              "{input$spat}, {glue::double_quote(input$temp)})")

      # execute
      exec_NOAA <- get_NOAA(input$var, input$spat, input$temp)

      list(data = exec_NOAA, code = call_NOAA)
    })

    # output
    list(
      data = reactive(x()$data),
      code = reactive(x()$code),
      variable = reactive(input$var)
    )
  })
}
#' @rdname input_ui
#'
#' @export
output_server <- function(id, NOAA, variable) {

  stopifnot(is.reactive(variable))
  stopifnot(is.reactive(NOAA))

  moduleServer(id, function(input, output, session) {

    # format
    pretty_table <- reactive({
      req(NOAA())
      req(variable())

      format_table(NOAA(), variable())
    })

    output$download <- downloadHandler(
      filename = function() {
        paste0(variable(), ".csv")
      },
      content = function(file) {
        utils::write.csv(pretty_table(), file)
      }
    )

  })
}

# cite the papers
vc_cite <- c(
  temperature = paste0(
    "Locarnini, R. A., A. V. Mishonov, O. K. Baranova, T. P. Boyer, M. M. ",
    "Zweng, H. E. Garcia, J. R. Reagan, D. Seidov, K. Weathers, C. R. Paver, ",
    "and I. Smolyar, 2018. World Ocean Atlas 2018, Volume 1: Temperature. A. ",
    "Mishonov Technical Ed.; NOAA Atlas NESDIS 81, 52pp."
  ),
  salinity = paste0(
    "Zweng, M. M., J. R. Reagan, D. Seidov, T. P. Boyer, R. A. Locarnini, H. ",
    "E. Garcia, A. V. Mishonov, O. K. Baranova, K. Weathers, C. R. Paver, and",
    "I. Smolyar, 2018. World Ocean Atlas 2018, Volume 2: Salinity. A.  ",
    "Mishonov Technical Ed.; NOAA Atlas NESDIS 82, 50pp."
  ),
  oxygen = paste0(
    "Garcia, H. E., K. Weathers, C. R. Paver, I. Smolyar, T. P. Boyer, R. A. ",
    "Locarnini, M. M. Zweng, A. V. Mishonov, O. K. Baranova, D. Seidov, and  ",
    "J. R. Reagan, 2018. World Ocean Atlas 2018, Volume 3: Dissolved Oxygen,  ",
    "Apparent Oxygen Utilization, and Oxygen Saturation. A. Mishonov ",
    "Technical Ed.; NOAA Atlas NESDIS 83, 38pp."
  ),
  nutrients = paste0(
    "Garcia, H. E., K. Weathers, C. R. Paver, I. Smolyar, T. P. Boyer, R. A. ",
    "Locarnini, M. M. Zweng, A. V. Mishonov, O. K. Baranova, D. Seidov, and ",
    "J. R. Reagan, 2018. World Ocean Atlas 2018, Volume 4: Dissolved Inorganic",
    " Nutrients (phosphate, nitrate and nitrate+nitrite, silicate). A.  ",
    "Mishonov Technical Ed.; NOAA Atlas NESDIS 84, 35pp."
  ),
  density = paste0(
    "Locarnini, R.A., T.P. Boyer, A.V. Mishonov, J.R. Reagan, M.M. Zweng,  ",
    "O.K. Baranova, H.E. Garcia, D. Seidov, K.W. Weathers, C.R. Paver, and  ",
    "I.V. Smolyar (2019). World Ocean Atlas 2018, Volume 5: Density. A. ",
    "Mishonov, Technical Editor. NOAA Atlas NESDIS 85, 41pp."
  )
)

citations <- function(x) {

  HTML(
    paste(vc_cite[x],
    a(
      href="https://www.ncei.noaa.gov/products/world-ocean-atlas",
      "(Click here for the original papers)")
    )
  )
}
