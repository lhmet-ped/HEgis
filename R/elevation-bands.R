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






#------------------------------------------------------------------------------

#' Convert output from hist() to tibble
#' @noRd
#' @family elevation bands functions
#' @seealso \code{\link{hist}}
#' @note Instead of table(cut(x, br)), hist(x, br, plot = FALSE) is more
#' efficient and less memory hungry.
.hist2tab <- function(hist.list){

  brks <- hist.list$breaks
  z_bands <- brks %>%
    tibble::tibble(inf = ., sup = dplyr::lead(.)) %>%
    head(-1) %>%
    dplyr::mutate(.,
                  mean_elev = hist.list$mids,
                  count = hist.list$counts,
                  area_frac = count/sum(count),
                  band = 1:nrow(.))
  z_bands
}


#' Fraction of the catchment covered by each Elevation band
#'
#' @param z raster or numeric vector
#' @param dz numeric scalar, interval (m) to elevation bands. Calculates basin
#'  area distributions within 100 m elevation by default.
#' @param nbands numeric scalar. Default: NULL (use `dz` to build elevation
#' bands).
#' @keywords internal
#' @family elevation bands functions
#'
z_bands <- function(z, dz = 100, nbands = NULL){
  checkmate::assert_number(dz)
  if(checkmate::test_class(z, "RasterLayer")){
    z <- raster::values(z, )
  }

  #z <- values(con_posto)
  z <- z[!is.na(z)]
  zrange <- range(z)

  # elevation bands using based on nbands
  if(!is.null(nbands)){
    # nbands = 4
    checkmate::assert_number(nbands)
    brks <- seq(zrange[1], zrange[2], length.out = nbands)
    dist <- hist(x = z, breaks = brks, plot = FALSE)
    ftab <- .hist2tab(dist)
    return(ftab)
  }

  # elevation bands using based on a dz m for each band
  # (nbands variable between catchments)
  checkmate::assert_true(diff(zrange) > dz)
  brks <- seq(zrange[1], zrange[2], by = dz)
  if(max(brks) < zrange[2]) brks <- c(brks, brks[length(brks)] + dz)
  #discrete_dist <- table(cut(z, brks, include.lowest = TRUE))
  dist <- hist(x = z, breaks = brks, plot = FALSE)
  ftab <- .hist2tab(dist) %>%
    dplyr::select(band, dplyr::everything())
  ftab
}


#' Fraction of precipitation and catchment area by elevation bands
#'
#' @param con_dem raster of conditioned elevation of catchment
#' @param meteo_raster raster of meteorological field (precipitation,
#' evapotranspiration, ...).
#' @inheritParams z_bands
#' @export
#' @examples
#' \dontrun{
#'   if(FALSE){
#'    elev_bands(con_dem = condem74, meteo_raster = precclim74, dz = 100)
#'   }
#' }
#' @family elevation bands functions
#' @seealso \code{\link[raster]{cut}}, \code{\link[raster]{resample}},
#' \code{\link[raster]{zonal}}
elev_bands <- function(con_dem, meteo_raster = NULL, dz = 100, nbands = NULL){
  # con_dem = condem74; meteo_raster = precclim74; dz = 100; nbands = NULL
  bands <- z_bands(z = con_dem, dz, nbands)

  if(is.null(meteo_raster)) return(bands)

  brks <- c(bands$inf, bands$sup[nrow(bands)]) %>%
    unique() %>%
    sort()
  rbands <- raster::cut(con_dem, breaks = brks, include.lowest = TRUE)
  # plot(rbands)
  rasterOptions(progress = "text")
  prec_res <- raster::resample(meteo_raster, rbands)
  rm(meteo_raster, condem)

  # plot(prec_clim_res); plot(st_geometry(poly_station), add = TRUE)
  zone_frac <- raster::zonal(prec_res,
                             rbands,
                             fun = "sum"
  ) %>%
    tibble::as_tibble() %>%
    dplyr::rename('band' = zone, 'prec_frac' = sum) %>%
    dplyr::mutate(prec_frac = prec_frac/sum(prec_frac))
  #sum(zone_frac$frac_prec)
  zone_frac <- dplyr::full_join(zone_frac, bands, by = "band") %>%
    dplyr::select(band, inf, sup, mean_elev, count, area_frac, prec_frac)
  zone_frac
}

