#' Build the link to the monthly file of NEWAVE model CCEE deck of prices.
#'
#' @param YYYYMM character vector with year (YYYY) and month (MM). Accepted
#' formats are for example "201809", "2018", "2018.02", "2018-03",
#' "2018-04-01", "2018/05".
#'
#' @return A character string naming the URL of the zip file to be downloaded.
#' @examples
#' yyyymm = c("201809", "2018", "2018.02", "2018-03", "2018-04-01", "2018/05")
#' nw_urls(yyyymm)
nw_urls <- function(YYYYMM = "201809"){

  YYYYMM <- as.character(YYYYMM)
  checkmate::assert_character(
    YYYYMM,
    min.chars = 4,
    pattern = "[0-9]{4,}",
    all.missing = FALSE,
    min.len = 1
  )

  dates <- lubridate::ymd(YYYYMM, truncated = 2)
  YYYYMM <- format.Date(dates, "%Y%m")

  nw_zip_urls <- glue::glue(
    "https://www.ccee.org.br/ccee/documentos/NW{YYYYMM}"
  )
  nw_zip_urls
}

#' Get the file path to CONFHD.DAT
path_confhd_file <- function(path) {
  grep("CONFHD.DAT",
       fs::dir_ls(path),
       value = TRUE,
       ignore.case = TRUE
  )
}

#' Download zip file from link provided by `nw_urls()`
#'
#' @param link url to download data
#' @param confhd_path logical. Default: TRUE, will return the path
#' to `CONFHD.DAT` file, otherwise the path to the temporary directory of
#' extracted data.
#'
#'@return Default is the path to `CONFHD.DAT` file, otherwise the
#'temporary directory of extracted data.
nw_down <- function(link, confhd_path = TRUE){
  #link = "https://www.ccee.org.br/ccee/documentos/NW201809"
  checkmate::assert_true(curl::has_internet())
  #checkmate::assert_true(RCurl::url.exists(link))
  zip_dest <- fs::file_temp(ext = "zip")
  download.file(link, destfile = zip_dest)
  #unzip(zip_dest, list = TRUE)
  dir_ext <- fs::path_ext_remove(zip_dest)
  unzip(zip_dest, exdir = dir_ext)
  checkmate::assert_directory_exists(dir_ext)

  if(confhd_path) {
    confhd_file <- path_confhd_file(dir_ext)
    checkmate::assert_file_exists(confhd_file)
    return(confhd_file)
  }

  dir_ext
}



#' Read data from text file `CONFHD.DAT`
#'
#' Read data file that contains the names from Hydro Power plants and ID from
#' the streamflow gauge ('posto').
#'
#' @param confhd_file character, file path.
#'
#' @return
#' @export
#'
read_confhd <- function(confhd_file) {

  confhd_header <- readr::read_fwf(
    file = confhd_file,
    col_positions = readr::fwf_empty(confhd_file, n = 1),
    col_types = readr::cols(),
    n_max = 1
  ) %>%
    t() %>%
    c() %>%
    janitor::make_clean_names()
    #rattle::normVarNames()

  confhd_data <- readr::read_fwf(
    file = confhd_file,
    col_positions = readr::fwf_empty(
      confhd_file,
      skip = 2,
      col_names = confhd_header),
    col_types = readr::cols(),
    #locate = locale(encoding = "latin1"),
    skip = 2
  )

  confhd_data <- dplyr::mutate(confhd_data,
                               num = as.integer(num),
                               posto = as.integer(posto),
                               jus = as.integer(jus),
                               #ree = as.integer(ree),
                               v_inic = as.numeric(v_inic),
                               modif = as.integer(modif),
                               inic_hist = as.integer(inic_hist),
                               fim_hist = as.integer(fim_hist)
                               )
  # some times "REE" is not present in the data
  if("ree" %in% names(confhd_data)){
    confhd_data <- dplyr::mutate(confhd_data, ree = as.integer(ree))
  }
  confhd_data
}

#' Get data from `CONFHD.DAT` file for the a given year and month
#'
#' @inheritParams nw_urls
#' @inheritParams nw_down
#'
#' @return
#' @export
#'
#' @examples
#' uhes_info <- confhd_data(format.Date(Sys.Date(), "%Y%m"))
confhd_data <- function(YYYYMM, confhd_path = TRUE){
  read_confhd(nw_down(nw_urls(YYYYMM), confhd_path))
}
# PAREI AQUI
#data_confhd <- read_confhd(confhd_file)




