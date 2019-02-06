library(leaflet)
library(lubridate)
library(shinyBS)
library(shinydashboard)
# library(dashboardthemes)
library(shinyjs)

dashboardPage(
  dashboardHeader(),
  dashboardSidebar(disable = T),
  dashboardBody(
    
    useShinyjs(),
    
    # shinyDashboardThemes(
    #   theme = "grey_dark"
    # ),
    
    fluidRow(
      
      includeCSS("styles.css"),

             box(width = 3, height = 800,
                 
                 radioButtons("GeoJSON_type","Subject input type",
                              choices = c("Local file", "GeoJSON"),
                              selected = "Local file"),
                 conditionalPanel(
                   condition = "input.GeoJSON_type == 'Local file'",
                   fileInput("geo_file_input", "")
                 ),
                 conditionalPanel(
                   condition = "input.GeoJSON_type == 'GeoJSON'",
                   textInput("geo_text_input", label=NULL, value=NULL, placeholder = "GeoJSON string or URL")
                 ),
                 
                 textInput("parcel", "Parcel by", placeholder = "Comma separated URLs"),
                 
                 numericInput("buffer", 
                              "Choose buffer size (m)", 
                              min = 1,
                              max = 5000,
                              value = 250),
                 
                 
                 numericInput("Max_Size", 
                              "Choose max no. structures per cluster", 
                              min = 1,
                              #max = 100,
                              value = 50),
                 
                 selectInput("return_type", "Return type",
                             list("hull" = "hull",
                                  "subject" = "subject",
                                  "both" = "both")),
                
                actionButton("goClusterYourself", "Get clusters"),
              
                  downloadButton("downloadData", "Download table"),
                  downloadButton("downloadGeoData", "Download geojson")),
            
                             box(leafletOutput("pop_map", height = 800, width = "100%"), width = 9),
                             box(DT::DTOutput('pop_table'), width = 12))
             )
)


      

