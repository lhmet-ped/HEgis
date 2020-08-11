
<!-- README.md is generated from README.Rmd. Please edit that file -->

# HEgis

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of HEgis is to prepare GIS data for use in HydroEngie R\&D
project.

## Installation

You can install HEgis from [github](https://github.com/lhmet/HEgis)
with:

``` r
library(devtools)
install_github("lhmet/HEgis")
```

<!-- BEFORE RUN (RE)INSTALL THE PACKAGE -->

## Example

So far there are functions for:

  - extract shapefiles from compressed file (`.rar`)

  - import shape file contained in the `.rar` file

This is a basic example which shows how to extract shape files from the
rar file (`BaciasHidrograficasONS_JUNTOS.rar`) available with `HEgis`
package.

``` r
library(HEgis)

## rar file included in the package
bhs_rar_file <- system.file(
   "extdata",
   "BaciasHidrograficasONS_JUNTOS.rar",
    package = "HEgis"
)
# extracted shapefiles
shapes <- extract_rar(bhs_rar_file, overwrite = TRUE)
shapes
#> /home/hidrometeorologista/.R/libs/HEgis/extdata/BaciasHidrograficasONS_JUNTOS/BaciasHidrograifcasUHEsONS.shp
#> /home/hidrometeorologista/.R/libs/HEgis/extdata/BaciasHidrograficasONS_JUNTOS/LagoBarragemONS.shp
```

Now we select the shape of interest and then import it.

``` r
shape_bhs <- shapes[grep("Bacias", fs::path_file(shapes))]
pols_bhs <- import_bhs_ons(shape_bhs)
#> Rows: 87
#> Columns: 10
#> $ codONS   <chr> "266", "291", "211", "134", "245", "197", "295", "296", "240…
#> $ codANA   <chr> "11735", "62833", "3581", "3875", "8124", "3626", "14588", "…
#> $ nome     <chr> "ITAIPU", "DARDANELOS", "FUNIL-GRANDE", "SALTO GRANDE", "JUP…
#> $ nomeOri  <chr> "UHE Itaipu", NA, "UHE Funil", "UHE Salto Grande", "UHE Jupi…
#> $ adkm2    <dbl> 822904.3332, 15332.6072, 15720.0056, 2476.7163, 476527.7329,…
#> $ volhm3   <dbl> 29403.91, NA, 268.93, 78.00, 3354.00, 7.09, 17.15, 21.00, 74…
#> $ rio      <chr> "Rio Paraná", "Rio Aripuanã", "Rio Grande", "Rio Guanhães", …
#> $ cobacia  <chr> "8631311", "46293331", "86895773", "7766211", "865775", "778…
#> $ tpopera  <chr> "Fio d'água", NA, "Fio d'água", "Fio d'água", "Fio d'água", …
#> $ geometry <POLYGON> POLYGON ((-43.60082 -21.168..., POLYGON ((-59.35952 -11.…
#> Simple feature collection with 87 features and 9 fields
#> geometry type:  POLYGON
#> dimension:      XY
#> bbox:           xmin: -72.41788 ymin: -29.41284 xmax: -38.93867 ymax: -2.495375
#> CRS:            NA
#> First 10 features:
#>    codONS codANA         nome          nomeOri      adkm2   volhm3          rio
#> 1     266  11735       ITAIPU       UHE Itaipu 822904.333 29403.91   Rio Paraná
#> 2     291  62833   DARDANELOS             <NA>  15332.607       NA Rio Aripuanã
#> 3     211   3581 FUNIL-GRANDE        UHE Funil  15720.006   268.93   Rio Grande
#> 4     134   3875 SALTO GRANDE UHE Salto Grande   2476.716    78.00 Rio Guanhães
#> 5     245   8124        JUPIA        UHE Jupiá 476527.733  3354.00   Rio Paraná
#> 6     197   3626       PICADA       UHE Picada   1725.833     7.09 Rio do Peixe
#> 7     295  14588        JAURU        UHE Jauru   2245.733    17.15         <NA>
#> 8     296  14589      GUAPORE      UHE Guaporé   1344.294    21.00  Rio Guaporé
#> 9     240   8013    PROMISSAO    UHE Promissão  57841.510  7408.00    Rio Tietê
#> 10    216   7607 CAMPOS NOVOS UHE Campos Novos  14445.832  1477.00   Rio Canoas
#>     cobacia        tpopera                       geometry
#> 1   8631311     Fio d'água POLYGON ((-43.60082 -21.168...
#> 2  46293331           <NA> POLYGON ((-59.35952 -11.975...
#> 3  86895773     Fio d'água POLYGON ((-44.50861 -22.224...
#> 4   7766211     Fio d'água POLYGON ((-43.04034 -18.603...
#> 5    865775     Fio d'água POLYGON ((-46.35946 -23.273...
#> 6   7788753     Fio d'água POLYGON ((-43.89604 -21.974...
#> 7  89969715     Fio d'água POLYGON ((-58.76821 -14.676...
#> 8   4699693     Fio d'água POLYGON ((-58.90869 -14.595...
#> 9   8661373 Regulariza_ONS POLYGON ((-46.10237 -22.999...
#> 10   829173 Regulariza_ONS POLYGON ((-49.44034 -28.132...
sf::st_crs(pols_bhs) <- "+proj=longlat +datum=WGS84"
class(pols_bhs)
#> [1] "sf"         "data.frame"
sf::st_geometry_type(pols_bhs, FALSE)
#> [1] POLYGON
#> 18 Levels: GEOMETRY POINT LINESTRING POLYGON MULTIPOINT ... TRIANGLE
```

``` r
library(sf)
#> Linking to GEOS 3.8.0, GDAL 3.0.4, PROJ 6.3.1
library(spData)
#> To access larger datasets in this package, install the spDataLarge
#> package with: `install.packages('spDataLarge',
#> repos='https://nowosad.github.io/drat/', type='source')`
#sa <- world[world$continent == "South America", ]
sa <- world[world$name_long == "Brazil", ]
plot(st_geometry(sa), axes = TRUE, border = 'grey')
plot(st_geometry(pols_bhs),
     col = sf.colors(nrow(pols_bhs), categorical = TRUE), 
     border = 'grey20', 
     add = TRUE
     )
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" style="display: block; margin: auto;" />

``` r
#plotrix::spread.labels(x = cs[, 1], y = cs[, 2], labels = pols_bhs$nome, )
```

``` r
library(leaflet)
library(leaflet.extras)
library(htmltools)

# cs <- tibble::as_tibble(st_coordinates(st_centroid(st_geometry(pols_bhs))))
# cs$nome <- pols_bhs$nome
# names(cs)[1:2] <- c("longitude", "latitude")

pal <- colorFactor(
       palette = "Paired",
       levels = pols_bhs$nome[order(pols_bhs$adkm2, decreasing = TRUE)]
       )

p <- leaflet() %>%
  addProviderTiles("Esri.NatGeoWorldMap") %>%
  addPolygons(
    data = pols_bhs,
    group = ~codONS,
    color = "#444444",
    weight = 1,
    smoothFactor = 0.5,
    opacity = 1.0,
    fillOpacity = 0.5,
    # fillColor = ~colorQuantile("YlOrRd", ALAND)(ALAND),
     #fillColor = ~colorFactor("Paired", nome)(nome),
    fillColor = ~pal(nome),
     #fillColor = ~colorQuantile("YlOrRd", adkm2)(adkm2),
    highlightOptions = highlightOptions(
      color = "white",
      weight = 2,
      bringToFront = TRUE, 
    )
  )
p
```

``` r
o <- order(pols_bhs$adkm2)

for(i in o){
  # i <- o[1]
plot(sf::st_geometry(sa),
     axes = TRUE,
     border = 'grey', 
     main = paste0(
       pols_bhs$nome[i], 
       " (", pols_bhs$codONS[i], ") ",
       "Área: ",
       round(pols_bhs$adkm2[i]), 
       " km²"
       )
     )
plot(sf::st_geometry(pols_bhs),
     col = NA, 
     border = 'red', lwd = 2,
     add = TRUE
     )
plot(st_geometry(pols_bhs)[i], 
     add = TRUE, 
     col = 1
     )  
}
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-2.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-3.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-4.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-5.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-6.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-7.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-8.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-9.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-10.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-11.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-12.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-13.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-14.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-15.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-16.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-17.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-18.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-19.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-20.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-21.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-22.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-23.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-24.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-25.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-26.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-27.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-28.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-29.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-30.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-31.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-32.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-33.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-34.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-35.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-36.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-37.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-38.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-39.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-40.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-41.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-42.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-43.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-44.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-45.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-46.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-47.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-48.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-49.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-50.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-51.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-52.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-53.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-54.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-55.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-56.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-57.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-58.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-59.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-60.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-61.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-62.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-63.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-64.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-65.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-66.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-67.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-68.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-69.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-70.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-71.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-72.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-73.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-74.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-75.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-76.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-77.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-78.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-79.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-80.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-81.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-82.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-83.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-84.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-85.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-86.png" width="100%" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-87.png" width="100%" style="display: block; margin: auto;" />
