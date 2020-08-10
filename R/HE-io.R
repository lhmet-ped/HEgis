

#' Extract files from a rar file (only works on Linux)
#'
#' This function extract files from a rar file
#'
#' @param rar_file a file path to a 'filename.rar'
#' @param dest_dir path to extract shape files
#' @param overwrite logical, use overwrite = TRUE to overwrite
#' pre-existent files.
#' @param quiet Hide printed output, messages, warnings, and errors
#' (TRUE, the default), or display them as they occur?
#' @return character vector with shape files path
#' @details This function has the side effect of generating a
#' directory 'BaciasHidrograficasONS_JUNTOS' with the uncompressed files in the HEgis
#' package directory (\code{system.file("extdata",package = "HEgis")}).
#' File are extracted on \code{dest_dir} when it is not \code{NULL}.
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
                        dest_dir = NULL,
                        overwrite = FALSE,
                        quiet = TRUE) {

  rar_file <- fs::path_real(rar_file)

  # input checks
  checkmate::assert_file_exists(rar_file)
  assertthat::assert_that(
    assertthat::has_extension(rar_file, "rar")
  )

  # create dir to extract at base dir from rar file
  dir_extract_rar <- fs::path_ext_remove(rar_file)

  if (!is.null(dest_dir)) {
    dest_dir <- fs::path_real(dest_dir)
    checkmate::assert_directory_exists(dest_dir)
    dir_extract_rar <- fs::path(dest_dir, basename(dir_extract_rar))
    #checkmate::assert_path_for_output(dir_extract_rar)
  }

  # build appropriate call to unrar
  if (!fs::dir_exists(dir_extract_rar)) {

    fs::dir_create(dir_extract_rar)
    checkmate::assert_path_for_output(dir_extract_rar, overwrite = TRUE)
    cmd <- paste0("unrar e ", rar_file, " ", dir_extract_rar)

  } else {
    # check if exists files in pre-existent dir
    if(length(dir(dir_extract_rar, all.files = TRUE)) > 0 && overwrite){
      cmd <- paste0("unrar e -o+ ", rar_file, " ", dir_extract_rar)
    } else {
      stop("There are files in the folder. Use overwrite = TRUE to
           overwrite pre-existent files.")
    }
  }

  # decompress
  if(checkmate::test_os("linux")) {
    # capture.output(out_call_unrar <- system(cmd,intern = TRUE),file = "NUL")
    if(quiet){
      out_call_unrar <- system(cmd, intern = FALSE, ignore.stdout = quiet)

    } #else {
      #out_call_unrar <- system(cmd, intern = FALSE)
    #}

    if(out_call_unrar != 0) {
      # print output console
      system(cmd, intern = TRUE)
      stop("\n unrar process returned error \n")
    #sudo apt install unrar
    }
    # list of shape files
    shapes <- fs::dir_ls(dir_extract_rar, type = "file", glob = "*.shp")
    return(shapes)
  }

  message("This function works only on linux systems.")
  return(NULL)
}



# -----------------------------------------------------------------------------

#' Import shape files with watersheds polygons from ONS Hydro Power plants
#'
#' @param shape_file A character scalar. Path to shape file.
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
#' @details This function was made to import a specific
#' file (e.g. `BaciasHidrograficasONS_JUNTOS.shp`). It will be extended to
#' the files in `BaciasHidrograficasONS_SEPARADO.rar`.
#'
#' @source The data were kindly provided by Saulo Aires
#' (Water Resources Specialist from ANA) through Prof.
#' Carlos Lima (UnB, e-mail in 2020-03-17).
#'
#' @author Jonatan Tatsch
#'
#' @return a [tibble][tibble::tibble-package]
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
#'   pols_bhs <- import_bhs_ons(bhs_shape_file)
#' }
#' }
import_bhs_ons <- function(shape_file, quiet = FALSE) {

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
      tidyselect::vars_select_helpers$where(is.character),
      readr::parse_guess
    )
  ) %>% # glimpse()
    dplyr::mutate(
      dplyr::across(
        tidyselect::vars_select_helpers$where(is.numeric),
        .fix_nas
      ),
      dplyr::across(
        dplyr::starts_with("co"),
        as.character
      ),
      dplyr::across(
        tidyselect::vars_select_helpers$where(is.character), .fix_nas_char
      )
    )

  if (!quiet) print(dplyr::glimpse(pols))

  pols
}
