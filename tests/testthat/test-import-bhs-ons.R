
context("import bhs ons")

test_that("test for a inexistent shape file", {
  expect_error(
    import_bhs_ons(shape_file = "somefile.shp")
  )
})

# TO DO:
.shape_from_zip_version_of_rar <- function(){
  dest_file <- tempfile(fileext = ".zip")
  #load("R/sysdata.rda")
  download.file(zip_url, dest_file, mode = 'wb')
  dir2extract <- file.path(dirname(dest_file), "BaciasHidrograficasONS_JUNTOS")
  unzip(dest_file, exdir = dir2extract)
  #list.files(dirname(dir2extract))
  shp <- list.files(dir2extract, pattern = "Bacias.*\\.shp$", full.names = TRUE)
  return(shp)
}

test_that("test with expected shape file", {

  bhs_rar <- system.file(
    "extdata",
    "BaciasHidrograficasONS_JUNTOS.rar",
    package = "HEgis"
  )

  if (requireNamespace("lhmetools", quietly = TRUE) &
    lhmetools:::.check_unrar(TRUE)) {
    library(lhmetools)
    temp_d <- tempdir()
    shps <- unrar(bhs_rar, dest_dir = temp_d)
    #bhs_shape_file <- shps[grep("Bacias.*\\.shp$", fs::path_file(shps))]
    bhs_shape_file <- shps[grep("Bacias.*\\.shp$", basename(shps))]
    bhs_pols <- import_bhs_ons(bhs_shape_file, quiet = FALSE)
  } else {
    # test with a zip version of original rar file (for tests)
    bhs_shape_file <- .shape_from_zip_version_of_rar()
    bhs_pols <- import_bhs_ons(bhs_shape_file, quiet = TRUE)
  }
  expect_is(bhs_pols, class = c("sf", "data.frame"))
})



