context("extract rar file")


test_that("test extraction of rar file in the folder of compressed file", {

  rar_file <- system.file(
    "extdata",
    "BaciasHidrograficasONS_JUNTOS.rar",
    package = "HEgis"
  )
  # delete dir resulting from previous extraction of rar file
  rar_dir <- fs::path_ext_remove(rar_file)
  if(fs::dir_exists(rar_dir)){
    fs::dir_delete(rar_dir)
  }

  output <- extract_rar(
    rar_file,
    dest_dir = NULL
  )

  if(!checkmate::test_os("linux")){
    expect_error(basename(output))
  }

  output <- length(grep("\\.shp", basename(output)))
  # cleanup
  fs::dir_delete(rar_dir)

  expect_equal(output, 2L)
})

test_that("test extraction of rar file in a arbitraty folder", {
  # rm -rf /tmp/R*
  tmpd <- tempdir()
  output <- extract_rar(
    rar_file = system.file(
      "extdata",
      "BaciasHidrograficasONS_JUNTOS.rar",
      package = "HEgis"
    ),
    dest_dir = tmpd
  )
  if(!checkmate::test_os("linux")){
    expect_error(basename(output))
  }
  output <- length(grep("\\.shp", basename(output)))
  if(checkmate::test_os("windows")){

  }
  expect_equal(output, 2L)
})


test_that("test try overwriting a pre-existent non empty folder", {
  tmpd <- tempdir()

  extract_rar(
    rar_file = system.file(
      "extdata",
      "BaciasHidrograficasONS_JUNTOS.rar",
      package = "HEgis"
    ),
    dest_dir = tmpd,
    overwrite = TRUE
  )

  expect_error(
    extract_rar(
      rar_file = system.file(
        "extdata",
        "BaciasHidrograficasONS_JUNTOS.rar",
        package = "HEgis"
      ),
      dest_dir = tmpd
    )
  )
})


test_that("test wrong output folder", {
  expect_error(
    extract_rar(
      rar_file = system.file(
        "extdata",
        "BaciasHidrograficasONS_JUNTOS.rar",
        package = "HEgis"
      ),
      dest_dir = "/someplace"
    )
  )
})

test_that("test folder instead of file", {
  expect_error(
    extract_rar(
      rar_file = system.file(
        "extdata",
        package = "HEgis"
      ),
      dest_dir = NULL
    )
  )
})


test_that("test for a inexistent file", {
  expect_error(
    extract_rar(rar_file = "")
  )
})








