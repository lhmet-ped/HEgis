

#' Get basic info of ONS station
#'
#' @param name_regex a string or regex to search for the name of the ONS station
#'
#' @return  a \code{\link[tibble]{tibble}}
#' @export
#' @example
#' info_station("MUNHOZ")
info_station <- function(name_regex = "MUNHOZ"){

  info_uhes <- HEgis::confhd_data(format.Date(Sys.Date(), "%Y%m"))

  # UHE Governador Bento Munhoz da Rocha Neto
  nome_posto <- dplyr::filter(
    info_uhes,
    str_detect(nome, name_regex)
  )[["nome"]]

  stopifnot(length(nome_posto) == 1)

  info <- info_posto_sel(info_uhes, nome_posto)
  info
}

info_posto_sel <- function(info, nome_posto){
  info %>%
    dplyr::filter(nome == nome_posto)
}


#-----------------------------------------------------------------------------
# Save data from a ONS station in a RDS file
.save_data <- function(data_posto = qnat_posto,
                      .prefix = "qnat-obs-posto-",
                      .posto_id = info_posto$posto[1],
                      .dest_dir = "output"){

  data_posto_file <- paste0(.prefix, .posto_id, ".RDS")
  data_posto_file <- file.path(.dest_dir, data_posto_file)

  saveRDS(data_posto, file = data_posto_file)
  checkmate::assert_file_exists(data_posto_file)
  data_posto_file
}

# Função para gerar arquivo RDS com poligono do posto --------------------------
extract_poly <- function(
  info = info_station(),
  save = FALSE,
  prefix = "poligono-posto-",
  dest_dir = "output") {

  #checkmate::assert_true(exists("info"))
  # Obter poligonos das UHEs
  # HEgis should be installed to have acces to gis data
  checkmate::assert_true(requireNamespace("HEgis", quietly = TRUE))
  checkmate::assert_true(requireNamespace("lhmetools", quietly = TRUE))

  bhs_rar <- system.file(
    "extdata",
    "BaciasHidrograficasONS_JUNTOS.rar",
    package = "HEgis"
  )

  # if folder already exists just read shape
  path2extractedfiles <- fs::path_ext_remove(bhs_rar)
  if(dir.exists(path_shp)){
    path_shp <- fs::dir_ls(path2extractedfiles, regexp = "UHEsONS\\.shp$")
    bhs_pols <- HEgis::import_bhs_ons(path_shp)
  } else {
    # lhmetools to unrar
    shps <- unrar(bhs_rar, overwrite = TRUE)
    bhs_shp <- shps[grep("Bacias.*\\.shp$", fs::path_file(shps))]
    bhs_pols <- HEgis::import_bhs_ons(bhs_shp, quiet = TRUE)
  }

  # G.B. MUNHOZ é FOZ DO AREIA !!!
  # filter(bhs_pols, nomeOri == "UHE Governador Bento Munhoz da Rocha Neto")

  poly_posto <- dplyr::filter(bhs_pols, codONS == info$posto)
  message("The data is not projected. We are taking CRS as SIRGAS 2000 (EPSG: 4674), the same as that of BHO-ANA on which the provider was based.")
  poly_posto <- sf::st_set_crs(poly_posto, 4674)

  if (save) {
    .save_data(
      data_posto = poly_posto,
      .prefix = prefix,
      .posto_id = info$posto[1],
      .dest_dir = dest_dir
    )
  }

  poly_posto
}
