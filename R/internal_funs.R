
#' Fix var types (to be used in import_bhs_ons())
.fix_nas <- function(x) dplyr::if_else(x < 0, NA_real_, x )

#' Set 'negative strings' as NA_character (to be used in import_bhs_ons())
.fix_nas_char <- function(x) {
  dplyr::if_else(stringr::str_detect(x, "-[9]{1,}"), NA_character_, x)
}
