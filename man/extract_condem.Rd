% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract-elevation.R
\name{extract_condem}
\alias{extract_condem}
\title{Extract a subset of a Raster object.}
\usage{
extract_condem(condem = rawdem_br, poly_station, dis.buf = 0)
}
\arguments{
\item{condem}{character, path file of hydrologically conditioned elevation
model (CON) from Hydrosheds data set.
Default: raster("~/Dropbox/datasets/GIS/hydrosheds/sa_con_3s_hydrosheds.grd").}

\item{poly_station}{a sf polygon or a raster extent, Default: extract_poly(station = 74).}

\item{dis.buf}{scalar numeric.}
}
\value{
Raster object.
}
\description{
Extract (crop and mask) a geographic subset of a Raster object.
}
\details{
This function was created with the intention of use to create the
input NETCDF file for the FUSE model, \code{elevation_bands.nc}. The function for
processing of hydrosheds CON raster is available at \code{data-raw/con-hydrosheds.R}.
The resulting CON raster for South America (sa_con_3s_hydrosheds.gr*,
spatial resolution of ~90 m) can be downloaded
\href{https://www.dropbox.com/sh/1agi2378wckr6c3/AAAu2_IBc_9LWTdzvA52VL-Ja?dl=0}{here}.
}
\note{
The CON raster file is not distributed with the package due to its
huge size (12.5 GB).
}
\examples{
\dontrun{
if(FALSE){
  info_posto <- info_station(name_regex = "MUNHOZ")
  poly_posto <- extract_poly(station = info_posto$posto)
  rawdem_br <- raster(
    system.file("extdata", "BRA_msk_alt.grd", package = "HEgis")
  )
  con_posto <- extract_condem(
   rawdem_br,
   poly_posto,
   dis.buf = 0
  )
  con_posto
}
}
}
\seealso{
\code{\link[HEgis]{prep_poly_posto}},
\code{\link[raster]{mask}},\code{\link[raster]{crop}}
}
\concept{elevation bands functions}
