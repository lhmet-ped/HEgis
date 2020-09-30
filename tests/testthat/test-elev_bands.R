context("elev-bands()")

test_that("Produces the correct output.", {
  expect_equal(nrow(elev_bands(condem74, dz = 100)), 10)
  expect_equal(dim(elev_bands(condem74, precclim74, dz = 300)), c(4, 7))
  expect_equal(sum(elev_bands(condem74, dz = 200)[["area_frac"]]), 1)
  # nbands
  expect_equal(nrow(elev_bands(con_dem = condem74, nbands = 5)), 5)
  # class
  checkmate::expect_class(elev_bands(con_dem = condem74, nbands = 5),
                          c("tbl_df", "tbl", "data.frame"))
})

test_that("Produces the correct errors.", {
  expect_error(elev_bands(condem74, precclim74, dz = 1000))
  expect_error(elev_bands(rep(NA, ncell(condem74)), precclim74, dz = 100))
  expect_error(elev_bands(condem74, precclim74, nbands = NA))
  expect_error(elev_bands(condem74, precclim74, dz = NULL, nbands = NULL))
})
