## code to prepare `DATASET` dataset goes here
easypackages::libraries(c("HEgis", "lhmetools", "sf", "dplyr"))

#-------------------------------------------------------------------------------
# montar bacias anihadas de exemplo par determinar topologia

# BHs ONS
bhs_rar <- system.file(
  "extdata",
  "BaciasHidrograficasONS_JUNTOS.rar",
  package = "HEgis"
)
shps <- unrar(bhs_rar, dest_dir = tempdir(), overwrite = TRUE)
(bhs_shp <- shps[grep("Bacias.*\\.shp$", fs::path_file(shps))])

bhs_pols <- import_bhs_ons(bhs_shp, quiet = TRUE)
st_crs(bhs_pols) <- "+proj=longlat +datum=WGS84"

# bacias do paraná para exemplo simplificado(ordenadas de jusante p/ montante)
ord_names <- c("ITAIPU", "P_PRIMAVERA",
               "JUPIA", "A_VERMELHA",
               "BARRA_BONITA", "FURNAS"
)
bhs_pr <- filter(bhs_pols, nome %in% ord_names)
bhs_pr
#usethis::use_data(DATASET, overwrite = TRUE)

# Visualização
ord_areas <- order(bhs_pr$adkm2, decreasing = TRUE)
cols <- sample(colors(), size = nrow(bhs_pr))
plot(st_as_sfc(st_bbox(bhs_pr)))
for (i in ord_areas) {
  # i = "JUPIA"
  plot(st_geometry(bhs_pr)[i],
       add = TRUE,
       col = cols[i],
       border = 1,
       lwd = 0.7
  )
}




#------------------------------------------------------------------------------
# Como obter bacia incremental
# poligonos das duas bacias que se sobrepõe
#nms_bhs_sel <- c("ITAIPU", "BARRA_BONITA")
#nms_bhs_sel <- c("JUPIA", "A_VERMELHA")
nms_bhs_sel <- c("BARRA_BONITA", "FURNAS")
#pols2 <- filter(bhs_pr, nome %in% nms_bhs_sel)
pols2 <- filter(bhs_pr, nome %in% nms_bhs_sel)
#class(pols2)
#st_geometry(pols2)
#st_is_valid(pols2)
# fazendo a união convertemos 2 bacias para apenas 1 cobrindo a área das duas
pols2_u <- st_union(pols2)
# bacia montante
bm <- slice(pols2, which.min(adkm2))
st_bbox(bm)
# bacia jusante
bj <- bhs_pr[bhs_pr$nome == "ITAIPU", ]
st_bbox(bj)


# bacia incremental
# sf
plot(pols2_u, border = NA, col = "gray")

inc_sf <- st_sym_difference(pols2_u, bm)
inc_sf_inv <- st_sym_difference(bm, pols2_u)
st_is_valid(inc_sf)

plot(inc_sf[1], add = TRUE, border = "black", lwd = 3)
plot(inc_sf_inv[1], add = TRUE, border = "red", col = "transparent", lwd = 1)


#------------------------------------------------------------------------------
# gSymdifference: Returns the regions of spgeom1 and spgeom2 that do not
#                 intersect. If the geometries do not intersect then spgeom1
#                 and spgeom2 will be returned as separate subgeometries.
#incremental <- rgeos::gSymdifference(
incremental <- rgeos::gDifference(
  spgeom1 = as(pols2_u, "Spatial"), # convertido para sp
  spgeom2 = as(bm, "Spatial")
) # %>% sp::disaggregate()

plot(as(pols2_u,'Spatial'))
plot(incremental, add = TRUE, col = 3)

st_bbox(pols2_u)
st_bbox(incremental)










