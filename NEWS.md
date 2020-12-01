News
================

<!-- NEWS.md is generated from NEWS.Rmd. Please edit that file -->



  - [ ] add function to buffer a polygon based on a fraction of the
    diagonal of extent (to be used in use in `prep_poly_station`).

# HEgis 0.1.0

  - [x] adapt `import_bhs_ons()` to internally extract the rar file, select the shapefile and import it (enhancement #3).

# HEgis 0.0.6

  - [x] fix examples and default values of `conf_hdata(YYYMM =
    format.Date(Sys.Date(), "%Y%m"))` to avoid error when data are not
    available yet (issue \#2).

# HEgis 0.0.5

  - [x] move elev\_bands() to \*\*`{fuse.prep}` and add a reproducible
    example in `extract_condem()`

# HEgis 0.0.4

  - [x] Add a `NEWS.md` file to track changes to the package.

  - [x] Add a `extract_condem()` function to crop and mask a geographic
    subset of the hydrologically conditioned elevation model from
    Hydrosheds.
