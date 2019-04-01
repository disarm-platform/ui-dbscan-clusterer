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

rm(list=ls())

shinyServer(function(input, output) {
  

  
  map_data <- eventReactive(input$goClusterYourself, {
    
    geo_in <- input$geo_file_input
    
    withProgress(message = 'Clustering points..',{
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
      parcel_by = unlist(strsplit(stri_replace_all_regex(str=parcel_by, pattern=" ", repl=""), ",")),
      max_num = input$Max_Size,
      max_dist_m = input$buffer,
      return_type = input$return_type
    )

    if(nchar(parcel_by)==0){
      request_list$parcel_by <- NULL
    }

    response <-
      httr::POST(url = "https://faas.srv.disarm.io/function/fn-dbscan-clusterer",
                 body = as.json(request_list),
                 content_type_json())

    # Check status
    if (response$status_code != 200) {
      stop('Sorry, there was a problem with your request - check your inputs and try again')
    }

    response_content <- content(response)
    return(response_content$result)
    })
    
  })
  
  

  output$pop_map <- renderLeaflet({

    if(input$goClusterYourself[1]==0){
      return(leaflet() %>%
                   addProviderTiles(
                     "CartoDB.Positron"
                   ) %>% setView(0,0,zoom=2))
    }

    # Get output
    map_data <- map_data()
    print("here 1")

    # Get response if there is one and define color palettes
    if (input$return_type == "subject" | input$return_type == "both") {
      subject_points <<- st_read(as.json(
        map_data$result$subject
      ))
      cluster_pal <-
        colorNumeric(brewer.pal(10, "Set3"), as.numeric(subject_points$cluster_id))
    }
    print("here 2")

    if (input$return_type == "hull" | input$return_type == "both") {
      hull_polys <<- st_read(as.json(
        map_data$result$hull
      ))
    }
    
    print("here 3")
    
    # Map results
    # Define map
    map <- leaflet() %>%
      addProviderTiles(
        "CartoDB.Positron"
      )
    if (input$return_type == "subject") {
      return(map %>% addCircleMarkers(
        data = subject_points,
        radius = 1,
        color = cluster_pal(as.numeric(subject_points$cluster_id))
      ))
    }
    print("here 4")
    if (input$return_type == "hull") {
      return(map %>% addPolygons(data = hull_polys,
                          weight = 3)
      )
    }
    print("here 5")
    if (input$return_type == "both") {
      return(map %>% addCircleMarkers(
        data = subject_points,
        radius = 1,
        color = cluster_pal(as.numeric(subject_points$cluster_id))
      ) %>%
        addPolygons(data = hull_polys,
                    weight = 3)
      )
    }
    
  })


  
  output$downloadGeoData <- downloadHandler(
    filename = function() {
      paste0("output.zip")
    },
    content = function(fname) {
      fs <- c()
  
      output_data <- list()
      if(input$return_type=="both"){
        which_layer_exists <- c("hull_polys", "subject_points")
                for(i in 1:2){
                  output_data[[i]] <- get0(c("hull_polys", "subject_points")[i])
                }
      }
      
        if(input$return_type=="hull"){
          which_layer_exists <- "hull_polys"
            output_data[[1]] <- hull_polys
        }
      
      if(input$return_type=="subject"){
          which_layer_exists <- "subject"
          output_data[[1]] <- subject_points
          }

      tmpdir <- tempdir()
      setwd(tempdir())
      for (i in 1:length(output_data)) {
        path <- paste0(which_layer_exists[i], ".geojson")
        fs <- c(fs, path)
        st_write(output_data[[i]], path, delete_dsn=TRUE)
      }
      zip(zipfile=fname, files=fs)
    },
    contentType = "application/zip"
  )


  
})
