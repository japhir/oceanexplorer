% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/table_module.R
\name{table_ui}
\alias{table_ui}
\alias{table_server}
\title{NOAA table module}
\usage{
table_ui(id, download = NULL)

table_server(id, NOAA, variable)
}
\arguments{
\item{id}{Namespace id shiny module.}

\item{download}{Add download button.}

\item{NOAA}{Reactive value of NOAA dataset.}

\item{variable}{Reactive value for selected variable name.}
}
\value{
Shiny module.
}
\description{
NOAA table module
}
