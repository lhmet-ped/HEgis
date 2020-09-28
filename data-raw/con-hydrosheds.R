## code to prepare `DATASET` dataset goes here
easypackages::libraries(c("HEgis", "sf", "glue", "raster"))

#-------------------------------------------------------------------------------
# Mosaic BIL files from hydrosheds 'Hydrologically conditioned elevation' - CON

info_posto <- info_station(name_regex = "MUNHOZ")
info_posto
poly_posto <- extract_poly(station = info_posto$posto)

file_prefix <- function(file){
  prefix <- file %>%
    fs::path_file() %>%
    fs::path_ext_remove() %>%
    stringr::str_split("_") %>%
    unlist()
  prefix <- prefix[1]
  prefix
}

read_bil <- function(zipfile) {
  # zipfile <- zip_files[3]
  td <- fs::path_temp()
  unzip(zipfile, exdir = td, overwrite = TRUE)
  prefix <- file_prefix(zipfile)
  # dir(td)
  bil_file <- list.files(td,
                         pattern = as.character(glue::glue("{prefix}.*bil$")),
                         full.names = TRUE
  )
  # class(bil_file)
  r <- raster::raster(bil_file)
  # fs::dir_delete(td)
  return(r)
}


.set_temp_dir <- function(){
  if(HEobs:::.check_user()){
    rasterOptions(tmpdir = "~/temp", progress = "text")
    message("Setting directory to store temporary files in ", tmpDir())
  }
}

.ask_check_space <- function(){
  message(
    "This operation requires around 11 Gb of your disk space in the form of temporary files."
  )
  ans <- readline(" Do you want to proceed? Type 'Yes' (Y) or 'No' (N).")
  checkmate::assert_subset(ans, c("", "Yes", "yes", "Y"))
}

mosaic_rasters <- function(
  tiles_dir = "~/Dropbox/datasets/GIS/hydrosheds/sa_con_3s_zip_bil",
  dest_dir = fs::path_dir(tiles_dir)) {
  #path_zips_condem_hs

  zip_files <- fs::dir_ls(tiles_dir, regex = "zip$")
  #zip_files <- zip_files[1:2]
  #read_bil(zipfile)
  # zip_files <- zip_files[c(5, 6, 7)]

  .ask_check_space()
  .set_temp_dir()

  raster_list <- lapply(zip_files,
                        function(ifile) {
                          cat(ifile, "\n")
                          read_bil(ifile)
                        }
  )
  # raster::merge doesn't work with a named list
  names(raster_list) <- NULL
  gc()

  # saveRDS(raster_list, file = "../fusepoc-prep/output/raster_list.RDS")
  # raster_list <- readRDS("../fusepoc-prep/output/raster_list.RDS")

  # raster_list <- raster_list[1:5]
  raster_mosaico <- do.call(raster::merge, raster_list)
  #mosaic_all <- Reduce(function(...) mosaic(..., fun = mean), raster_list)
  #class(raster_mosaico)

  out_file <- fs::path(dest_dir, "sa_con_3s_hydrosheds.grd")
  #filename(raster_mosaico) <- out_file

  raser::writeRaster(
    raster_mosaico,
    filename = out_file,
    datatype='INT2U'
  )
  checkmate::assert_file_exists(out_file)
  fs::file_delete(fs::dir_ls("~/temp"))
  out_file
}

#mosaic_rasters()



#------------------------------------------------------------------------------
#' Extract a subset of a Raster object.
#'
#' @description Extract (crop and mask) a geographic subset of a Raster object.
#' @param condem character, path file of hydrologically conditioned elevation
#'  model (CON) from Hydrosheds data set.
#'  Default: raster("~/Dropbox/datasets/GIS/hydrosheds/sa_con_3s_hydrosheds.grd")
#' @param poly_station a sf polygon or a raster extent, Default: extract_poly(station = 74).
#' @param dis.buf scalar numeric.
#' @return Raster object.
#' @details This function was created with the intention of use to create the
#' input NETCDF file for the FUSE model, `elevation_bands.nc`. The function for
#' processing of hydrosheds CON raster is available at `data-raw/con-hydrosheds.R`.
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
#'  \code{\link[raster]{mask}},\code{\link[raster]{c("crop", "crop")}}
#' @export
#' @importFrom raster mask crop
extract_condem <- function(
  condem = raster("~/Dropbox/datasets/GIS/hydrosheds/sa_con_3s_hydrosheds.grd"),
  poly_station = poly_posto,
  dis.buf = 0
){

  if(class(poly_station) == "Extent"){
    return(raster::crop(condem, poly_station))
  }

  poly_posto_buf <- prep_poly_posto(
    poly_station,
    ref_crs = projection(condem),
    dis.buf
  )
 condem_cm <- raster::mask(raster::crop(condem, poly_posto_buf), poly_posto_buf)
 #plot(condem_c)
 #plot(st_geometry(poly_posto), add = TRUE, border = "black", col = "transparent")
condem_cm
}
