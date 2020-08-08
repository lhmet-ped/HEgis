

#' Extract files from a rar file (linux)
#'
#' This function extract files from a rar file
#'
#' @param rar_file a file path to a 'filename.rar'
#' @return character vector with shape files path
#' @details This function has the side effect of generating a
#' directory with the uncompressed files in the HEgis
#' package directory ('iextdata').
#' @export
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   bhs_rar_file <- system.file(
#'     "extdata",
#'     "BaciasHidrograficasONS_JUNTOS.rar",
#'     package = "HEgis"
#'   )
#'   shapes <- extract_rar(bhs_rar_file)
#'   shapes
#' }
#' }
#' @importFrom checkmate assert_file_exists test_path_for_output assert_os
#' @importFrom assertthat assert_that has_extension
#' @importFrom fs path_ext_remove dir_ls

extract_rar <- function(
                        rar_file,
                        dest_dir = NULL) {

  # check file

  checkmate::assert_file_exists(rar_file)
  assertthat::assert_that(
    assertthat::has_extension(rar_file, "rar")
  )

  # dir to extract shape files (based on file name)
  dir_extract_rar <- ifelse(
    is.null(dest_dir),
    fs::path_ext_remove(rar_file),
    dest_dir
  )

  # Check if data path can be used safely to unrar the file and write to it.
  if (checkmate::test_path_for_output(dir_extract_rar)) {
    fs::dir_create(dir_extract_rar)
    # checkmate::test_os("linux")

    # linux-only
    checkmate::assert_os("linux")
    system(paste("unrar e", rar_file, dir_extract_rar), intern = FALSE)

    # list shape files
    shapes <- fs::dir_ls(dir_extract_rar, type = "file", glob = "*.shp")
    return(shapes)
  }

  shapes <- fs::dir_ls(dir_extract_rar, type = "file", glob = "*.shp")
  shapes
}



# -----------------------------------------------------------------------------

#' Import shape files with watersheds polygons from ONS hydropower plants
#'
#' @param shape_file A character scalar. Path to shape file.
#' @param verbose A logical scalar. If TRUE prints data structure.
#'
#' @importFrom readr parse_guess
#' @importFrom dplyr %>%
#' @importFrom checkmate assert_file_exists
#' @importFrom sf st_read
#' @importFrom dplyr mutate starts_with glimpse
#' @importFrom tidyselect vars_select_helpers
#'
#' @details This function was made to import a specific
#' file (e.g. 'BaciasHidrograficasONS_JUNTOS.shp'). It will be extended to
#' the files in 'BaciasHidrograficasONS_SEPARADO.rar'.
#'
#' @source The data were kindly provided by Saulo Aires
#' (Water Resources Specialist from ANA) through Prof.
#' Carlos Lima (UnB, e-mail in 2020-03-17).
#'
#' @author Jonatan Tatsch
#'
#' @return tibble
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   bhs_rar_file <- system.file(
#'     "extdata",
#'     "BaciasHidrograficasONS_JUNTOS.rar",
#'     package = "HEgis"
#'   )
#'   shapes <- extract_rar(bhs_rar_file)
#'   shapes
#'   bhs_shape_file <- shapes[grep("Bacias", fs::path_file(shapes))]
#'   pols_bhs <- import_bhs_ons(bhs_shape_file, verbose = TRUE)
#' }
#' }
import_bhs_ons <- function(shape_file, verbose = FALSE) {

  # shape_file <- shapes[grep("Bacias", path_file(shapes))]

  checkmate::assert_file_exists(shape_file)

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
      tidyselect:::where(is.character),
      readr::parse_guess
    )
  ) %>% # glimpse()
    dplyr::mutate(
      .,
      dplyr::across(tidyselect:::where(is.numeric), .fix_nas),
      dplyr::across(dplyr::starts_with("co"), as.character),
      dplyr::across(
        tidyselect::vars_select_helpers$where(is.character), .fix_nas_char
      )
    )

  if (verbose) print(dplyr::glimpse(pols))

  pols
}
