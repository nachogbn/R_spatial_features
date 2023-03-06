###CLASE 1 R SPATIAL FEATURES CON ANTONIO

#Instalamos el paquete leaflet que vamos a usar
install.packages('leaflet')
install.packages('sf')
install.packages('raster')
install.packages('htmlwidgets')

#Cargamos la libreria
library(leaflet)
library(sf)
library(tidyverse)
library(raster)
library(htmlwidgets)

#Creamos objeto leyendo la info geografico
sn <- st_read("data/sn_enp.shp")

#Miramos que poroyección tiene nuestra capa
raster::projection(sn)

#Trasnformamos a la proyección que nos interesa
sn <- st_transform(sn, 4326)

#Comprobamos que esté en la proyección que nos interesa
raster::projection(sn)

#Graficamos la info geografica
plot(st_geometry(sn))

#Forma clasica, de esta forma estamos creando demasiados archivos/objetos temporales que consumen memoria
mapita <- leaflet()
mapita1 <- addTiles(mapita)
mapita2 <- addMarkers(mapita1, lng=-3.311572, lat=37.053434, popup='Mulhacen')

mapita2

#Forma moderna, lo hacemos todo de una tirada usando 'pipe operador' y consumimos menos memoria. Ctrl+shift+M = Shortcut para pipe
mapita <- leaflet() %>%
  addTiles() %>%
  addMarkers(lng=-3.311572, lat=37.053434, popup='Mulhacen')

mapita %>% 
  addPolygons(data = sn,
              group = 'Natural Park',
              fillOpacity = 0,
              color = 'blue')

#Si el poligono lo añadimos en otra linea de codigo como hemos hecho no está dentro del objeto por asi decirlo
#Para que este dentro tenemos que meterlo en todo en la misma secuencia de pipe, seri asi:
#A veces nos interesa tener un mapa base y luego ir añadiendo cosas por separado

mapita <- leaflet() %>%
  addTiles() %>%
  addMarkers(lng=-3.311572, lat=37.053434, popup='Mulhacen') %>% 
  addPolygons(data = sn,
              group = 'Natural Park',
              fillOpacity = 0,
              color = 'blue')

mapita %>% 
  addLayersControl(position = 'bottomright',
                   baseGroups = c('Open Street Map'),
                   overlayGroups = c('Natural Park'))

mapita %>% 
  addProviderTiles("Esri.WorldImagery", 
                   group = "Satellite (ESRI)") %>% 
  addLayersControl(position = 'bottomright',
                   baseGroups = c('Open Street Map', 
                                  'Satellite (ESRI)'),
                   overlayGroups = c('Natural Park'))

mapita %>% 
  addProviderTiles("Esri.WorldImagery", 
                   group = "Satellite (ESRI)") %>% 
  addWMSTiles("http://www.ign.es/wms-inspire/pnoa-ma?",
              layers = 'OI.OrthoimageCoverage',
              options = WMSTileOptions(format = "image/png", transparent = TRUE),
              group = "PNOA") %>%
  addLayersControl(position = 'bottomright',
                   baseGroups = c('Open Street Map','Satellite (ESRI)','PNOA'),
                   overlayGroups = c('Natural Park'))

#Ahora todo junto para exportar
mapita <- leaflet() %>%
  addTiles() %>%
  addMarkers(lng=-3.311572, lat=37.053434, popup='Mulhacen') %>% 
  addPolygons(data = sn,
              group = 'Natural Park',
              fillOpacity = 0,
              color = 'blue')%>% 
  addProviderTiles("Esri.WorldImagery", 
                   group = "Satellite (ESRI)") %>% 
  addWMSTiles("http://www.ign.es/wms-inspire/pnoa-ma?",
              layers = 'OI.OrthoimageCoverage',
              options = WMSTileOptions(format = "image/png", transparent = TRUE),
              group = "PNOA") %>%
  addLayersControl(position = 'bottomright',
                   baseGroups = c('Open Street Map','Satellite (ESRI)','PNOA'),
                   overlayGroups = c('Natural Park'))

mapita

#Vamos a guardar el mapita

saveWidget(mapita, 'index.html')
