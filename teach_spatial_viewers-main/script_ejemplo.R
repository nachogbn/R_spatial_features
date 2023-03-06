library(here) # A Simpler Way to Find Your Files
library(tidyverse) # Easily Install and Load the 'Tidyverse'
library(leaflet) # Create Interactive Web Maps with the JavaScript 'Leaflet'
library(raster) # Geographic Data Analysis and Modeling
library(mapview) # Interactive Viewing of Spatial Data in R
library(leafem) # 'leaflet' Extensions for 'mapview'
library(sf) # Simple Features for R
library(leaflet.opacity) # Opacity Controls for Leaflet Maps
library(stars)

# Read data 
soc <- raster::raster(here::here("data/socsn.tif"))
sn <- st_read(here::here("data/sn_enp.shp"))
qp <- st_read(here::here("data/q_pyr_sn_4326.shp"))

# Rasterize 
# biodiv <- st_read(here::here("data/biodiversidad_sn_1x1.shp")) %>% 
#   dplyr::select(H) 
# aux_rast <- raster(biodiv, resolution=1000)
# hr <- rasterize(biodiv, aux_rast, "H")
# writeRaster(hr, here::here("data/shannon.tif"))

hr <- raster::raster(here::here("data/shannon.tif"))

# Transform coordinates
sn <- st_transform(sn, 4326)
h <- projectRaster(hr, crs = "+init=epsg:4326")

# Create popup for layer
popup_qp <- paste0("<strong>Population id:</strong> ", qp$POBLACION,
                   "<br><strong>Name:</strong> ", qp$LOCALIDAD,
                   "<br><strong>Valley:</strong> ", qp$VALLE)

# map 
m <- leaflet() %>% 
  addProviderTiles("Esri.WorldImagery") %>% 
  addMiniMap(tiles = providers$Esri.WorldTerrain, 
             toggleDisplay = TRUE) %>% 
  # http://leaflet-extras.github.io/leaflet-providers/preview/index.html
  # addRasterImage(soc, project = TRUE, 
  #                group = "soc", opacity = 0.6,
  #                layerId = "soc") %>% 
  addRasterImage(h, project = TRUE, 
                 group = "Shannon Diversity Index", opacity = 0.6,
                 layerId = "Shannon Diversity Index") %>% 
  addMouseCoordinates() %>% # View coordinates 
  addOpacitySlider(layerId = "Shannon Diversity Index") %>%
  leafem::addImageQuery(h, project = TRUE, 
                        type="mouse", 
                        layerId = "Shannon Diversity Index",
                        digits = 2, 
                        className = "hjola") %>% 
  addPolygons(data = sn,
              group= 'Natural Park',
              fillOpacity = 0, 
              color = "black",
              stroke = TRUE) %>% 
  addPolygons(data = qp,
              group= 'Quercus pyrenaica forests',
              fillColor = 'red', fillOpacity = 0.4, 
              stroke = FALSE, popup = popup_qp) %>% 
  addLayersControl(position = 'bottomright',
                   baseGroups = c("Satellite"),
                   overlayGroups = c('Natural Park',
                                     'Shannon Diversity Index',
                                     'Quercus pyrenaica forests'),
                   options = layersControlOptions(collapsed = TRUE)) 


library(htmlwidgets) # HTML Widgets for R
saveWidget(m, "index.html")