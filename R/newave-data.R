#' Check if a URL exists
#' @param x a single URL
#' @param non_2xx_return_value what to do if the site exists but the
#'        HTTP status code is not in the `2xx` range. Default is to return `FALSE`.
#' @param quiet if not `FALSE`, then every time the `non_2xx_return_value` condition
#'        arises a warning message will be displayed. Default is `FALSE`.
#' @param ... other params (`timeout()` would be a good one) passed directly
#'        to `httr::HEAD()` and/or `httr::GET()`
#' @keywords internal
#' @source \url{https://stackoverflow.com/questions/52911812/check-if-url-exists-in-r}
url_exists <- function(x, non_2xx_return_value = FALSE, quiet = FALSE,...) {

  # you don't need thse two functions if you're alread using `purrr`
  # but `purrr` is a heavyweight compiled pacakge that introduces
  # many other "tidyverse" dependencies and this doesnt.

  capture_error <- function(code, otherwise = NULL, quiet = TRUE) {
    tryCatch(
      list(result = code, error = NULL),
      error = function(e) {
        if (!quiet)
          message("Error: ", e$message)

        list(result = otherwise, error = e)
      },
      interrupt = function(e) {
        stop("Terminated by user", call. = FALSE)
      }
    )
  }

  safely <- function(.f, otherwise = NULL, quiet = TRUE) {
    function(...) capture_error(.f(...), otherwise, quiet)
  }

  sHEAD <- safely(httr::HEAD)
  sGET <- safely(httr::GET)

  # Try HEAD first since it's lightweight
  res <- sHEAD(x, ...)

  if (is.null(res$result) ||
      ((httr::status_code(res$result) %/% 200) != 1)) {

    res <- sGET(x, ...)

    if (is.null(res$result)) return(NA) # or whatever you want to return on "hard" errors

    if (((httr::status_code(res$result) %/% 200) != 1)) {
      if (!quiet) warning(sprintf("Requests for [%s] responded but without an HTTP status code in the 200-299 range", x))
      return(non_2xx_return_value)
    }

    return(TRUE)

  } else {
    return(TRUE)
  }

}



#' Build the link to the monthly file of NEWAVE model CCEE deck of prices.
#'
#' @param YYYYMM character vector with year (YYYY) and month (MM). Accepted
#' formats are for example "201809", "2018", "2018.02", "2018-03",
#' "2018-04-01", "2018/05".
#'
#' @return A character string naming the URL of the zip file to be downloaded.
#' @keywords internal
# examples
# yyyymm = c("201809", "2018", "2018.02", "2018-03", "2018-04-01", "2018/05")
# nw_urls(yyyymm)
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
#' @keywords internal
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
#' @keywords internal
#'
#'@return Default is the path to `CONFHD.DAT` file, otherwise the
#'temporary directory of extracted data.
nw_down <- function(link, confhd_path = TRUE, quiet = TRUE){
  #link = "https://www.ccee.org.br/ccee/documentos/NW201809" # 500 MB!?
  # link = "https://www.ccee.org.br/ccee/documentos/NW201208"
  checkmate::assert_character(link)
  checkmate::assert_true(curl::has_internet())
  #checkmate::assert_true(RCurl::url.exists(link))

  ## taking to much time
  #checkmate::assert_true(url_exists(link, quiet = quiet))

  zip_dest <- fs::file_temp(ext = "zip")

  utils::download.file(link, destfile = zip_dest, mode = "wb")
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
#' @return a [tibble][tibble::tibble-package].
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
  if("ssis" %in% names(confhd_data)){
    confhd_data <- dplyr::mutate(confhd_data, ssis = as.integer(ssis))
  }
  confhd_data
}

#' Get data from `CONFHD.DAT` file for the a given year and month
#'
#' @inheritParams nw_urls
#' @inheritParams nw_down
#' @details Data are available in \url{https://www.ccee.org.br/ccee/documentos}
#' since July/2012.
#' @return a [tibble][tibble::tibble-package] with tidy data.
#' @export
#'
#' @examples
#' if(FALSE){
#' uhes_info <- confhd_data(format.Date(Sys.Date(), "%Y%m"))
#' }
#'
confhd_data <- function(YYYYMM, confhd_path = TRUE){
  read_confhd(nw_down(nw_urls(YYYYMM), confhd_path))
}


