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
#' \dontrun{
#' if (interactive()) {
#'   bhs_rar <- system.file(
#'     "extdata",
#'     "BaciasHidrograficasONS_JUNTOS.rar",
#'     package = "HEgis"
#'   )
#'   if (requireNamespace("lhmetools", quietly = TRUE)) {
#'     (shps <- unrar(bhs_rar))
#'     bhs_shp <- shps[grep("Bacias.*\\.shp$", fs::path_file(shps))]
#'     bhs_pols <- import_bhs_ons(bhs_shp)
#'   }
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
