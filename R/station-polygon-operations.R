#-------------------------------------------------------------------------------
#' Get basic info of ONS station
#'
#' @param name_regex a string or regex to search for the name of the ONS station
#'
#' @return  a \code{\link[tibble]{tibble}}
#' @export
#' @examples
#' if(FALSE){
#'  info_station("MUNHOZ")
#' }
info_station <- function(name_regex = "MUNHOZ"){

  info_uhes <- HEgis::confhd_data(format.Date(Sys.Date(), "%Y%m"))

  # UHE Governador Bento Munhoz da Rocha Neto
  nome_posto <- dplyr::filter(
    info_uhes,
    str_detect(nome, name_regex)
  )[["nome"]]

  stopifnot(length(nome_posto) == 1)

  info <- info_posto_sel(info_uhes, nome_posto)
  info
}

info_posto_sel <- function(info, nome_posto){
  info %>%
    dplyr::filter(nome == nome_posto)
}


#-----------------------------------------------------------------------------
# Save data from a ONS station in a RDS file
.save_data <- function(data_posto = qnat_posto,
                      .prefix = "qnat-obs-posto-",
                      .posto_id = info_posto$posto[1],
                      .dest_dir = "output"){

  data_posto_file <- paste0(.prefix, .posto_id, ".RDS")
  data_posto_file <- file.path(.dest_dir, data_posto_file)

  saveRDS(data_posto, file = data_posto_file)
  checkmate::assert_file_exists(data_posto_file)
  data_posto_file
}

#-----------------------------------------------------------------------------
#' Extract the watershed polygon from a ONS station
#'
#' @param station scalar integer, the station id ('posto')
#' @param save logical, default is FALSE
#' @param prefix character, prefix to include in the name of RDS file. An
#'  example is 'poligono-posto-'. The station id will be appended to
#'  this prefix followed by '.RDS'.
#' @param dest_dir character, path to save the RDS file. Default is 'output'.
#'
#' @return object of class \code{\link[sf]{sf}}.
#' @export
#'

extract_poly <- function(
  station = info_station()[["posto"]],
  save = FALSE,
  prefix = "poligono-posto-",
  dest_dir = "output") {

  #checkmate::assert_true(exists("info"))
  # Obter poligonos das UHEs
  # HEgis should be installed to have acces to gis data
  #checkmate::assert_count(station)
  station <- as.character(station)
  checkmate::assert_true(all(!is.na(extract_numeric(station))))
  checkmate::assert_true(requireNamespace("HEgis", quietly = TRUE))
  checkmate::assert_true(requireNamespace("lhmetools", quietly = TRUE))

  bhs_rar <- system.file(
    "extdata",
    "BaciasHidrograficasONS_JUNTOS.rar",
    package = "HEgis"
  )

  # if folder already exists just read shape
  path2extractedfiles <- fs::path_ext_remove(bhs_rar)
  if(dir.exists(path2extractedfiles)){
    path_shp <- fs::dir_ls(path2extractedfiles, regexp = "UHEsONS\\.shp$")
    bhs_pols <- HEgis::import_bhs_ons(path_shp, quiet = TRUE)
  } else {
    # lhmetools to unrar
    shps <- lhmetools::unrar(bhs_rar, overwrite = TRUE)
    bhs_shp <- shps[grep("Bacias.*\\.shp$", fs::path_file(shps))]
    bhs_pols <- HEgis::import_bhs_ons(bhs_shp, quiet = TRUE)
  }
  #checkmate::assert_subset('74', bhs_pols[["codONS"]])
  checkmate::assert_subset(station, bhs_pols[["codONS"]])
  # G.B. MUNHOZ é FOZ DO AREIA !!!
  # filter(bhs_pols, nomeOri == "UHE Governador Bento Munhoz da Rocha Neto")

  #poly_posto <- dplyr::filter(bhs_pols, codONS == info$posto)
  poly_posto <- dplyr::filter(bhs_pols, codONS %in% station)
  message("The data is not projected. We are taking CRS as SIRGAS 2000 (EPSG: 4674), the same as that of BHO-ANA on which the provider was based.")
  poly_posto <- sf::st_set_crs(poly_posto, 4674)

  if (save) {
    .save_data(
      data_posto = poly_posto,
      .prefix = prefix,
      .posto_id = info$posto[1],
      .dest_dir = dest_dir
    )
  }

  poly_posto
}

#-------------------------------------------------------------------------------
#' Prepares the station's polygon to determine the spatial average of a
#' meterological variable.
#'
#' Sets appropriate CRS to station's polygon and apply buffer.
#'
#' @param poly_station a polygon of class \code{\link[sf]{sf}}
#' @param ref_crs character, the base coordinate reference system. Default:
#' '+proj=longlat +datum=WGS84'.
#' @param dis.buf numeric, default: 0.25 (degrees). When `dis.buf = 0`,
#' the only action over the `poly_station` is the conversion of coordinates to
#'  `ref_crs`.
#'
#' @return object of class \code{\link[sf]{sf}}
#' @export
#'
prep_poly_posto <- function(poly_station,
                            dis.buf = 0.25,#res(b_prec)[1]
                            ref_crs = "+proj=longlat +datum=WGS84"
) {

  checkmate::assert_class(poly_station, c("sf", "data.frame"))
  checkmate::assert_number(dis.buf)
  checkmate::assert_character(ref_crs)

  #poly_posto <- readRDS(poly_posto_file) # %>% st_geometry()
  # conversion to the CRS of meteorological dataset
  poly_posto_ll <- sf::st_transform(poly_station, ref_crs)
  if(dis.buf == 0) return(poly_posto_ll)
  # st_crs(poly_posto)
  # buffer of res(b_prec)[1]
  poly_posto_b <- suppressWarnings(
    sf::st_buffer(poly_posto_ll, dist = dis.buf)
    )
  poly_posto_b
}

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


# r <- raster("~/Dropbox/datasets/GIS/hydrosheds/sa_con_3s_hydrosheds.grd")
# condem_posto <- extract_condem(
#   condem = r,
#   poly_station = poly_posto,
#   dis.buf = 0
# )


#' Convert output from hist() to tibble
#' @noRd

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
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' if(FALSE){
#'   poly_posto <- suppressMessages(extract_poly(station = 74))
#   con_posto <- extract_condem(
#'    raster("~/Dropbox/datasets/GIS/hydrosheds/sa_con_3s_hydrosheds.grd"),
#'    poly_posto,
#'    dis.buf = 0
#'  )
#'   elev_bands(z = con_posto, dz = 100)
#'   elev_bands(z = con_posto, nbands = 5)
#' }
#' }
elev_bands <- function(z, dz = 100, nbands = NULL){
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











