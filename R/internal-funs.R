utils::globalVariables(
  c("fim_hist",
    "inic_hist",
    "jus", "modif",
    "num",
    "posto",
    "ree",
    "ssis",
    "unzip",
    "v_inic",
    "qnat_posto",
    "info_posto",
    "codONS",
    "info",
    "nome",
    "area_frac",
    "band",
    "count",
    "head",
    "hist",
    "inf",
    "mean_elev",
    "prec_frac",
    "sup",
    "zone",
    ".",
    "degree"
    )
  )

# Fix var types (to be used in import_bhs_ons())
#' @importFrom dplyr if_else
.fix_nas_num <- function(x) dplyr::if_else(x < 0, NA_real_, x )

# Set 'negative strings' as NA_character (to be used in import_bhs_ons())
#' @importFrom stringr str_detect
.fix_nas_char <- function(x) {
  dplyr::if_else(stringr::str_detect(x, "-[9]{1,}"), NA_character_, x)
}

extract_numeric <-function(x)as.numeric(gsub("[^0-9.-]+", "", as.character(x)))
