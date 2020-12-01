
context("import bhs ons")


test_that("Produces expected output.", {


  if (requireNamespace("lhmetools", quietly = TRUE) &&
      lhmetools:::.check_unrar(TRUE)) {

    bhs_rar <- system.file(
      "extdata",
      "BaciasHidrograficasONS_JUNTOS.rar",
      package = "HEgis"
    )
    checkmate::assert_file_exists(bhs_rar)


     bhs_pols <- import_bhs_ons(quiet = FALSE)
     expect_is(bhs_pols, class = c("sf", "data.frame"))

     if(checkmate::test_directory_exists(fs::path_ext_remove(bhs_rar))){
       fs::dir_delete(fs::path_ext_remove(bhs_rar))
       bhs_pols <- import_bhs_ons(quiet = FALSE)
       expect_is(bhs_pols, class = c("sf", "data.frame"))
     }

  }
})



