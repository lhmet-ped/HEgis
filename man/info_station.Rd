% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/station-polygon.R
\name{info_station}
\alias{info_station}
\title{Get basic info of ONS station}
\usage{
info_station(
  name_regex = "MUNHOZ",
  YYYYMM = format.Date(Sys.Date() - 40, "\%Y\%m")
)
}
\arguments{
\item{name_regex}{a string or regex to search for the name of the ONS station}

\item{YYYYMM}{character vector with year (YYYY) and month (MM). Accepted
formats are for example "201809", "2018", "2018.02", "2018-03",
"2018-04-01", "2018/05".}
}
\value{
a \code{\link[tibble]{tibble}}
}
\description{
Get basic info of ONS station
}
\examples{
if(FALSE){
 info_station("MUNHOZ")
}
}
\seealso{
\code{\link[HEgis]{confhd_data}}
}
\concept{station metadata functions}
