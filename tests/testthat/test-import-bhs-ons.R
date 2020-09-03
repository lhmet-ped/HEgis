
context("import bhs ons")

test_that("test for a inexistent shape file", {
  expect_error(
    import_bhs_ons(shape_file = "somefile.shp")
  )
})



# TO DO:
.shape_from_zip_version_of_rar <- function(){
  # clean-up tmp dirs before tests

  # unlink(
  #   list.files(dirname(tempdir()),
  #              pattern = "^R.*",
  #              full.names = TRUE
  #   ),
  #   recursive = TRUE
  # )

  dest_file <- tempfile(fileext = ".zip")
  #load("R/sysdata.rda")
  download.file(zip_url, dest_file, mode = 'wb')
  # file.exists(dest_file)
  dir2extract <- file.path(dirname(dest_file), "bacias-ons")
  #dir2extract <- dirname(dest_file)
  unzip(dest_file, exdir = dir2extract, overwrite = TRUE)
  #list.files(dirname(dir2extract))
  shp <- list.files(dir2extract,
                    pattern = "Bacias.*\\.shp$",
                    full.names = TRUE,
                    recursive = TRUE)
  return(shp)
}

test_that("test import shape file from a architeture different from linux", {

  # test with a zip version of original rar file (for tests)
  bhs_shape <- .shape_from_zip_version_of_rar()
  bhs_pols <- import_bhs_ons(bhs_shape, quiet = TRUE)

  expect_is(bhs_pols, class = c("sf", "data.frame"))
})

test_that("test import shape file in linux  and unrar", {

  bhs_rar <- system.file(
    "extdata",
    "BaciasHidrograficasONS_JUNTOS.rar",
    package = "HEgis"
  )

  if (requireNamespace("lhmetools", quietly = TRUE) &
    lhmetools:::.check_unrar(TRUE)) {
    library(lhmetools)
    temp_d <- tempdir()
    shps <- unrar(bhs_rar, dest_dir = temp_d, overwrite = TRUE)
    #bhs_shape_file <- shps[grep("Bacias.*\\.shp$", fs::path_file(shps))]
    bhs_shape_file <- shps[grep("Bacias.*\\.shp$", basename(shps))]
    bhs_pols <- import_bhs_ons(bhs_shape_file, quiet = FALSE)
    expect_is(bhs_pols, class = c("sf", "data.frame"))
    return(NULL)
  }

  expect_error(bhs_pols)

})



