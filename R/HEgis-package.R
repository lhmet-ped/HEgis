#' HEgis: Functions To Import GIS Data Needed For The HYDROENGIE Project
#'
#'The goal of \pkg{HEgis} is to prepare GIS data for use in HydroEngie R&D
#' project.
#'
#'@section HEgis functions:
#'
#' \itemize{
#'    \code{\link{import_bhs_ons}}: a convenience function to import the
#'    shapefile with basins of major hydroelectric power dams.
#'
#'    \code{\link{info_station}}: it is useful to get basic
#'    information from a ONS station.
#'
#'    \code{\link{extract_poly}}: to extract a specific watershed polygon from
#'    the data set with all watersheds.
#'
#'    \code{\link{extract_condem}}: to crop and mask a geographic subset of
#'    the hydrologically conditioned elevation model from Hydrosheds.
#' }
#'
#'
#'@docType package
#'@name HEgis
#'
# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL
