#' Hydrologically conditioned elevation for ONS station 74.
#'
#' As of Sep 2020.
#'
#' @format A RasterLayer with elevation in m.
#' \describe{
#' \item{crs}{coordinate reference system is '+proj=longlat +datum=WGS84'}
#' \item{dimensions}{1957 rows, 3329 columns, 6514853 cells}
#' \item{resolution}{0.0008333333 arc degrees, ~90 m at equator}
#' }
#' @source \url{https://www.hydrosheds.org/downloads}
"condem74"


#' Catchment polygon of ONS station 74.
#'
#' As of Sep 2020.
#'
#' @format A Simple Feature Polygon.
#' \describe{
#' \item{codONS}{Code ID from ONS station}
#' \item{codANA}{code ID by ANA}
#' \item{nome}{name}
#' \item{nomeOri}{name}
#' \item{adkm2}{drainage area in squared kilometers}
#' \item{volhm3}{reservoir volume in hm3}
#' \item{rio}{river name}
#' \item{cobacia}{code ID for the Ottobacia}
#' \item{tpopera}{operator}
#' }
#' @note CRS is SIRGAS 2000 (EPSG: 4674)
#' @source The data were kindly provided by Saulo Aires
#' (Water Resources Specialist from ANA) through Prof. Carlos Lima
#' (UnB, e-mail in 2020-03-17).
"poly74"


