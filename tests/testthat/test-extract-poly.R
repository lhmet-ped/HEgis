context("extract polygon from a watershed")

test_that("Produces expected output", {
  expect_is(extract_poly(74), c("sf", "data.frame"))
  expect_message(extract_poly(74))
  expect_equal(nrow(extract_poly(c(266, 291))), 2)
})

test_that("Produces a error for a station id not present in the dataset", {
  expect_error(
    extract_poly(1000)
  )
  expect_error(
    extract_poly("aaa")
  )
})


