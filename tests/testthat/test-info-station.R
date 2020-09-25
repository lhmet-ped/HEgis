context("Get basic info from a ONS station")

test_that("Produces expected output", {
  expect_is(info_station("MUNHOZ"), c('data.frame', 'tbl'))
})

test_that("Produces error", {
  expect_error(info_station("MUNHOS"))
  expect_error(info_station("74"))
  expect_error(info_station(74))
})
