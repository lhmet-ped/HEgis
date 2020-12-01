

find_shapefile <- function(folder, regex = "Bacias.*UHEsONS\\.shp$"){
  checkmate::assert_directory_exists(folder)
  fs::dir_ls(
    folder,
    type = "file",
    regexp = regex
  )
}


read_shapefile <- function(shape_file, quiet){
  if(!quiet) message("reading file from: \n ", shape_file)
  checkmate::assert_file(shape_file)
  pols <- sf::st_read(
    shape_file,
    options = "ENCODING=WINDOWS-1252",
    quiet = TRUE
  )
  # pols_geom <- sf::st_geometry(pols)
  # plot(st_geometry(pols))
  # glimpse(pols)

  pols <- dplyr::mutate(
    pols,
    dplyr::across(
      tidyselect::vars_select_helpers$where(is.character),
      readr::parse_guess
    )
  ) %>% # glimpse()
    dplyr::mutate(
      dplyr::across(
        tidyselect::vars_select_helpers$where(is.numeric),
        .fix_nas_num
      ),
      dplyr::across(
        dplyr::starts_with("co"),
        as.character
      ),
      dplyr::across(
        tidyselect::vars_select_helpers$where(is.character), .fix_nas_char
      )
    )
  sf::st_crs(pols) <- 4674
  pols
}




# -----------------------------------------------------------------------------
#' Import shape file with watersheds polygons from ONS Hydro Power plants
#'
#' @param quiet Logical. Hide printed output data structure or display them as
#' they occur? Default FALSE.
#'
#' @importFrom readr parse_guess
#' @importFrom dplyr %>%
#' @importFrom checkmate assert_file_exists
#' @importFrom sf st_read
#' @importFrom dplyr mutate starts_with glimpse
#' @importFrom tidyselect vars_select_helpers
#'
#' @details This function look at the extdata folder of HEgis to extract the
#' file `BaciasHidrograficasONS_JUNTOS.rar` and import the shapefile of same
#' name in it.
#'
#' @source The data were kindly provided by Saulo Aires
#' (Water Resources Specialist from ANA) through Prof.
#' Carlos Lima (UnB, e-mail in 2020-03-17).
#'
#' @author Jônatan Tatsch
#'
#' @return object of class \code{\link[sf]{sf}} when a layer was successfully
#' read; in case argument layer is missing and data source name (`dsn`) does not
#' contain a single layer, an object of class sf_layers is returned with the
#'  layer names, each with their geometry type(s). Note that the number of
#'  layers may also be zero.
#' @export
#'
#' @examples
#' if (FALSE) {
#'     bhs_pols <- import_bhs_ons()
#' }
import_bhs_ons <- function(quiet = FALSE) {

  bhs_rar <- system.file(
    "extdata",
    "BaciasHidrograficasONS_JUNTOS.rar",
    package = "HEgis"
  )
  checkmate::assert_file(bhs_rar)
  path2extract <- system.file(
    "extdata",
    package = "HEgis"
  )
  checkmate::assert_directory(path2extract)
  bhs_folder <- bhs_rar %>%
    fs::path_file() %>%
    fs::path_ext_remove() %>%
    fs::path(path2extract, .)

  check_prev_extract <- checkmate::test_directory_exists(bhs_folder)

  if(check_prev_extract){
    bhs_shp <- find_shapefile(bhs_folder)
    if(!quiet) message("Using previously extracted data.")
    pols <- read_shapefile(shape_file = bhs_shp, quiet)
    if (!quiet) print(pols)
    return(pols)
  }

  shps <- lhmetools::unrar(bhs_rar, path2extract, overwrite = TRUE)
  pols <- read_shapefile(shape_file = find_shapefile(bhs_folder), quiet)

  if (!quiet) print(pols)
  pols
}

#


