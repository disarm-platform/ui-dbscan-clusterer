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
                  
                  box(
                    width = 3,
                    height = 800,
                    
                    radioButtons(
                      "GeoJSON_type",
                      "Subject input type",
                      choices = c("Local file", "GeoJSON or URL to GeoJSON"),
                      selected = "Local file"
                    ),
                    conditionalPanel(condition = "input.GeoJSON_type == 'Local file'",
                                     fileInput("geo_file_input", "")),
                    conditionalPanel(
                      condition = "input.GeoJSON_type == 'GeoJSON or URL to GeoJSON'",
                      textInput(
                        "geo_text_input",
                        label = NULL,
                        value = NULL,
                        placeholder = "GeoJSON string or URL"
                      )
                    ),
                    
                    textInput("parcel", "Parcel by", placeholder = "Comma separated URLs"),
                    
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
                    leafletOutput("pop_map", height = 750, width = "100%"),
                    height = 800,
                    width = 9
                  )
                ))
  
)
