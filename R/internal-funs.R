
# Fix var types (to be used in import_bhs_ons())
#' @importFrom dplyr if_else
.fix_nas_num <- function(x) dplyr::if_else(x < 0, NA_real_, x )

# Set 'negative strings' as NA_character (to be used in import_bhs_ons())
#' @importFrom stringr str_detect
.fix_nas_char <- function(x) {
  dplyr::if_else(stringr::str_detect(x, "-[9]{1,}"), NA_character_, x)
}
