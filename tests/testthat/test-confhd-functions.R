<<<<<<< HEAD
context("confhd_data()")

test_that("Produces the correct output", {

  expect_identical(
    confhd_data("201811"),
    read_confhd(system.file("extdata", "CONFHD-201811.DAT", package = "HEgis"))
  )

  expect_is(confhd_data("201207"), "data.frame")

})

test_that("Produces the correct error", {
  # before 201207 there is no link to data
  expect_warning(expect_error(confhd_data("201206")))
  expect_error(confhd_data("aayy"))
})
=======
context("confhd_data()")

test_that("Produces the correct output", {

  expect_identical(
    confhd_data("201811"),
    read_confhd(system.file("extdata", "CONFHD-201811.DAT", package = "HEgis"))
  )

  expect_is(confhd_data("201207"), "data.frame")

})

test_that("Produces the correct error", {
  # before 201207 there is no link to data
  expect_warning(expect_error(confhd_data("201206")))
  expect_error(confhd_data("aayy"))
})
>>>>>>> f705d65fad4368582ee36cb23ec919f1892992cb
