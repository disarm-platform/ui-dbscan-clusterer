library(leaflet)
library(lubridate)
library(shinyBS)
library(shinydashboard)
# library(dashboardthemes)
library(shinyjs)

dashboardPage(
  dashboardHeader(),
  dashboardSidebar(disable = T),
  dashboardBody(useShinyjs(),
                
                # shinyDashboardThemes(
                #   theme = "grey_dark"
                # ),
                
                fluidRow(
                  includeCSS("styles.css"),
                  
                  box(p("This app allows you to cluster points/polygons into groups
                  using", a("this", href = "https://github.com/disarm-platform/fn-dbscan-clusterer/blob/master/SPECS.md"),
                        " algorithm. Clusters can be split by lines/polygons using the 'Parcel by' input.
                      You can run with your own data using the input boxes below, 
                        or using the prepopulated demo inputs:"),
                      
                      br(#tags$ol(
                        tags$li(strong("subject"), "- Sample of OSM building centroids (Swaziland)"),
                        tags$li(strong("parcel_by"), "- OSM roads (Swaziland)")
                      ),
                      
                      actionButton("useDemo", "USE DEMO DATA"),
                      
                    width = 3,
                    height = 900,
                    
                    br(""),
                    
                    radioButtons(
                      "GeoJSON_type",
                      "Subject input type",
                      choices = c("Local file", "GeoJSON or URL to GeoJSON"),
                      selected = "GeoJSON or URL to GeoJSON"
                    ),
                    conditionalPanel(condition = "input.GeoJSON_type == 'Local file'",
                                     fileInput("geo_file_input", "")),
                    conditionalPanel(
                      condition = "input.GeoJSON_type == 'GeoJSON or URL to GeoJSON' & 
                      input.useDemo ==0",
                      textInput(
                        "geo_text_input",
                        label = NULL
                      )
                    ),
                    conditionalPanel(
                      condition = "input.useDemo > 0",
                      textInput(
                        "geo_demo_input",
                        label = NULL,
                        value = "https://ds-faas.storage.googleapis.com/algo_test_data/general/build_crop.geojson"
                      )
                    ),
                    
                    conditionalPanel(
                      condition = "input.useDemo == 0",
                    textInput("parcel", "Parcel by", 
                              placeholder = "URL to GeoJSON")),
                    
                    conditionalPanel(
                      condition = "input.useDemo > 0",
                      textInput("parcel_demo", "Parcel by", 
                                value = "https://ds-faas.storage.googleapis.com/algo_test_data/general/osm_roads_swz.geojson")),

                    numericInput(
                      "buffer",
                      "Choose buffer size (m)",
                      min = 1,
                      max = 5000,
                      value = 250
                    ),
                    
                    
                    numericInput(
                      "Max_Size",
                      "Choose max no. structures per cluster",
                      min = 1,
                      value = 50
                    ),
                    
                    selectInput(
                      "return_type",
                      "Return type",
                      list(
                        "hull" = "hull",
                        "subject" = "subject",
                        "both" = "both"
                      )
                    ),
                    
                    actionButton("goClusterYourself", "Get clusters"),
                    
                    conditionalPanel(
                      condition = "input.goClusterYourself > 0",
                      br(h4("Download results")),
                      downloadButton("downloadGeoData", "Download geojson")
                    )
                  ),
                  
                  box(
                    leafletOutput("pop_map", height = 850, width = "100%"),
                    height = 900,
                    width = 9
                  )
                ))
  
)
