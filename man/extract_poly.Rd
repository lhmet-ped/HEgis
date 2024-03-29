% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/station-polygon.R
\name{extract_poly}
\alias{extract_poly}
\title{Extract the watershed polygon from a ONS station}
\usage{
extract_poly(
  station = info_station()[["posto"]],
  save = FALSE,
  prefix = "poligono-posto-",
  dest_dir = "output"
)
}
\arguments{
\item{station}{scalar integer, the station id ('posto')}

\item{save}{logical, default is FALSE}

\item{prefix}{character, prefix to include in the name of RDS file. An
example is 'poligono-posto-'. The station id will be appended to
this prefix followed by '.RDS'.}

\item{dest_dir}{character, path to save the RDS file. Default is 'output'.}
}
\value{
object of class \code{\link[sf]{sf}}.
}
\description{
Extract the watershed polygon from a ONS station
}
\seealso{
Other station polygon functions: 
\code{\link{prep_poly_posto}()}
}
\concept{station polygon functions}
