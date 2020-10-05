#------------------------------------------------------------------------------
#' Extract a subset of a Raster object.
#'
#' @description Extract (crop and mask) a geographic subset of a Raster object.
#' @param condem character, path file of hydrologically conditioned elevation
#'  model (CON) from Hydrosheds data set.
#'  Default: raster("~/Dropbox/datasets/GIS/hydrosheds/sa_con_3s_hydrosheds.grd").
#' @param poly_station a sf polygon or a raster extent, Default: extract_poly(station = 74).
#' @param dis.buf scalar numeric.
#' @return Raster object.
#' @details This function was created with the intention of use to create the
#' input NETCDF file for the FUSE model, `elevation_bands.nc`. The function for
#' processing of hydrosheds CON raster is available at `data-raw/con-hydrosheds.R`.
#' The resulting CON raster for South America (sa_con_3s_hydrosheds.gr*,
#' spatial resolution of ~90 m) can be downloaded
#' [here](https://www.dropbox.com/sh/1agi2378wckr6c3/AAAu2_IBc_9LWTdzvA52VL-Ja?dl=0).
#' @note The CON raster file is not distributed with the package due to its
#' huge size (12.5 GB).
#' @examples
#' \dontrun{
#' if(FALSE){
#'   info_posto <- info_station(name_regex = "MUNHOZ")
#'   poly_posto <- extract_poly(station = info_posto$posto)
#'   con_posto <- extract_condem(
#'    raster("~/Dropbox/datasets/GIS/hydrosheds/sa_con_3s_hydrosheds.grd"),
#'    poly_posto,
#'    dis.buf = 0
#'   )
#' }
#' }
#' @seealso
#'  \code{\link[HEgis]{prep_poly_posto}},
#'  \code{\link[raster]{mask}},\code{\link[raster]{crop}}
#' @export
#' @importFrom raster mask crop
#' @family elevation bands functions
extract_condem <- function(
  condem = raster::raster("~/Dropbox/datasets/GIS/hydrosheds/sa_con_3s_hydrosheds.grd"),
  poly_station,
  dis.buf = 0
){


  if("Extent" %in% class(poly_station)){
    return(raster::crop(condem, poly_station))
  }

  poly_posto_buf <- prep_poly_posto(
    poly_station,
    ref_crs = raster::projection(condem),
    dis.buf
  )
  condem_cm <- raster::mask(raster::crop(condem, poly_posto_buf), poly_posto_buf)
  #plot(condem_c)
  #plot(st_geometry(poly_posto), add = TRUE, border = "black", col = "transparent")
  condem_cm
}


