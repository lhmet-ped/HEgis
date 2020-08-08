#' Import shape files with watersheds polygons from ONS hydropower plants
#'
#' @param shape_file A character scalar. Path to shape file.
#' @param verbose A logical scalar. If TRUE prints data structure.
#'
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
#'  if(interactive()){
#'   ## data path
#'   dp <- "~/Dropbox/datasets/GIS/BaciaHidrograficaoONS_EnviadosProfAssis/"
#'   # dir_ls(dp)
#'   ## shape bhs juntas
#'   bhons <- fs::dir_ls(dp, regexp = "JUNTOS*.rar$", type = "file")
#'   shapes <- extract_rar(bhons)
#'   #shapes
#'   shape_file <- shapes[grep("Bacias", path_file(shapes))]
#'   pols_uhes <- import_bhs_ons(shape_file)
#'   glimpse(pols_uhes)
#'  }
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
      parse_guess
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
