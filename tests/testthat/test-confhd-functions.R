context("confhd_data()")

test_that("Produces the correct output", {
  expect_identical(
    confhd_data("201811"),
    read_confhd(system.file("extdata", "CONFHD-201811.DAT", package = "HEgis"))
  )
})

test_that("Produces the correct error", {
  expect_error(confhd_data("aayy"))
})
