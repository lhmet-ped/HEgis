
context("import bhs ons")

test_that("test for a inexistent shape file", {
  expect_error(
    import_bhs_ons(shape_file = "somefile.shp", verbose = TRUE)
  )
})

#
#   bhs_rar_file <- system.file(
#     "extdata",
#     "BaciasHidrograficasONS_JUNTOS.rar",
#     package = "HEgis"
#   )
#   temp_d <- tempdir()
#   shapes <- extract_rar(bhs_rar_file, dest_dir = temp_d)
#
#   tmp <- tempfile(fileext = ".shp")
#   file.exists(tmp)
#
#   bhs_shape_file <- shapes[grep("Bacias", fs::path_file(shapes), invert = TRUE)]
#    import_bhs_ons(tempfile(fileext = ".shp"), verbose = TRUE)
#




