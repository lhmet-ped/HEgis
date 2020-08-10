context("extract rar file")

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

# TO DO:
# teste de descompactar arquivos em diretório arbitrário

