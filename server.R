library(raster)
library(sp)
library(leaflet)
library(RANN)
library(rgeos)
library(rjson)
library(httr)
library(wesanderson)
library(readr)
library(stringi)
library(DT)
library(ggplot2)
library(velox)
library(sf)
library(RColorBrewer)
library(geojsonio)
library(base64enc)


# Define map
map <- leaflet(max) %>%
  addTiles(
    "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}{r}.png"
  )



shinyServer(function(input, output) {
  map_data <- eventReactive(input$goClusterYourself, {
    geo_in <- input$geo_file_input
    
    
    # if (is.null(geo_in) | length(input$geo_text_input)==1)
    #   return(NULL)
    #
    # if (is.null(c(input$buffer, input$Max_Size, input$return_type)))
    #   return(NULL)
    #
    # if (length(input$parcel==1))
    #   return(NULL)
    
    # Might need other is.nulls for the other params here
    
    # Get data
    if (!is.null(geo_in)) {
      input_geo <- geojson_list(st_read(geo_in$datapath))
    } else{
      input_geo <- input$geo_text_input
    }
    
    parcel_by <- input$parcel
    
    # PAckage up
    request_list <- list(
      subject = input_geo,
      parcel_by = unlist(strsplit(parcel_by, ",")),
      max_num = input$Max_Size,
      max_dist_m = input$buffer,
      return_type = input$return_type
    )
    
    response <-
      httr::POST(url = "https://faas.srv.disarm.io/function/fn-dbscan-clusterer",
                 body = as.json(request_list),
                 content_type_json())
    return(response)
    
  })
  
  
  
  output$pop_map <- renderLeaflet({
    
    if (is.null(map_data())) {
      return(map %>% setView(0, 0, zoom = 2))
    }
    
    # Get response if there is one and define color palettes
    if (input$return_type == "subject" | input$return_type == "both") {
      subject_points <- st_read(as.json(from(JSON(
        map_data()$subject
      ))))
      cluster_pal <-
        colorNumeric(brewer.pal(10, "Set3"), subject_points$cluster_id)
    }
    
    if (input$return_type == "hull" | input$return_type == "both") {
      hull_polys <- st_read(as.json(from(JSON(
        map_data()$hull
      ))))
    }
    
    # Map results
    if (input$return_type == "subject") {
      map %>% addCircleMarkers(
        data = subject_points,
        radius = 1,
        color = cluster_pal(subject_points$cluster_id)
      )
    }
    
    if (input$return_type == "hull") {
      map %>% addPolygons(data = hull_polys,
                          weight = 3)
    }
    
    if (input$return_type == "both") {
      map %>% addCircleMarkers(
        data = subject_points,
        radius = 1,
        color = cluster_pal(subject_points$cluster_id)
      ) %>%
        addPolygons(data = hull_polys,
                    weight = 3)
    }
    
  })
  
  
  output$downloadGeoData <- downloadHandler(
    filename = function() {
      paste("extracted_population.geojson")
    },
    content = function(file) {
      st_write(map_data(), file)
    }
  )
  
})
