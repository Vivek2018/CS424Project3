#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(mapview)
library(shinydashboard)
library(leaflet)

data <- read.csv('energy-usage-2010.csv')


ui <- dashboardPage(
    
    #create dashboard and elements
    dashboardHeader(title = "CS 424 Project 2"),
    
    dashboardSidebar(disable = FALSE, collapsed = FALSE,
                     #menu bar with all 3 panels and about page
                     sidebarMenu(
                         menuItem("Near West Side Community", tabName = "west_side", icon = NULL),
                         menuItem("Community Comparison", tabName = "community_compare", icon = NULL),
                         menuItem("Chicago", tabName = "chicago", icon = NULL),
                         menuItem("About Page", tabName = "about", icon = NULL)
                     )
    ),
    
    dashboardBody(
        tabItems(
            #west side data tab for west side only
            tabItem(tabName="west_side",
                fluidRow(
                    column(2, 
                       selectizeInput(
                           'west_loop_view', 'Select a View: ', choices = c("Electricity", "Gas", "Building Type", "Building Age", "Building Height", "Total Population"), selected = "Electricity", multiple = FALSE
                       ),
                       
                       selectizeInput(
                           'west_loop_months', 'Select a Time Frame: ', choices = c("Year", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), selected = "Year", multiple = TRUE
                       ),
                       
                       selectizeInput(
                           'west_loop_building', 'Select a Building Type: ', choices = c("All", "Commercial", "Residential", "Industrial"), selected = "All", multiple = FALSE
                       ),
                       
                       actionButton("reset_button_first_page", "Reset View")
                           
                   ),
                   
                   column(5, 
                        leafletOutput("west_loop_map", height = 630)
                  )
                )
            ),
            
            tabItem(
                tabName="community_compare",
                column(6, 
                       fluidRow(
                            column(4,
                                    
                                   selectizeInput(
                                       'com1_view', 'Select a View: ', choices = c("Electricity", "Gas", "Building Type", "Building Age", "Building Height", "Total Population"), selected = "Electricity", multiple = FALSE
                                   ),
                                   
                                   selectizeInput(
                                       'com1_months', 'Select a Time Frame: ', choices = c("Year", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), selected = "Year", multiple = TRUE
                                   ),
                                   
                                   selectizeInput(
                                       'com1_building', 'Select a Building Type: ', choices = c("All", "Commercial", "Residential", "Industrial"), selected = "All", multiple = FALSE
                                   ),
                                   
                                   actionButton("reset_com1", "Reset View")       
                                   
                           ), 
                           
                           column(8, 
                                  
                                  leafletOutput("com1_map", height = 630)
                                  
                                  )
                       )
               ),
            
            
            column(6, 
                   fluidRow(
                       column(4,
                              
                              selectizeInput(
                                  'com2_view', 'Select a View: ', choices = c("Electricity", "Gas", "Building Type", "Building Age", "Building Height", "Total Population"), selected = "Electricity", multiple = FALSE
                              ),
                              
                              selectizeInput(
                                  'com2_months', 'Select a Time Frame: ', choices = c("Year", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), selected = "Year", multiple = TRUE
                              ),
                              
                              selectizeInput(
                                  'com2_building', 'Select a Building Type: ', choices = c("All", "Commercial", "Residential", "Industrial"), selected = "All", multiple = FALSE
                              ),
                              
                              actionButton("reset_com2", "Reset View")       
                              
                       ), 
                       
                       column(8, 
                              
                              leafletOutput("com2_map", height = 630)
                              
                       )
                   )
                )
            
            ),
            
            tabItem(
                tabName = "chicago",
                column(2, 
                       
                       selectizeInput(
                           'chicago_view', 'Select a View: ', choices = c("Electricity", "10% Most Electricity", "Gas", "10% Most Gas", "Building Type", "Building Age", "10% Most Oldest Buildings", "10% Most Oldest Buildings", "Building Height", "10% Most Building Height", "10% Most Gas", "Total Population", "10% Most Populated", "10% Most Occupied", "10% Most Renters"), selected = "Electricity", multiple = FALSE
                       ),
                       
                       leafletOutput("chicago_map", height = 630)
                )
            ),
            
            tabItem(
                tabName = "about"
            )
        )
    )
)
    
    
    
# Define server logic required to draw a histogram
server <- function(input, output) {
    #First Map - West Side Loop
    
    # observe({
    #     view <- input$west_loop_view
    #     west_side_data <- 
    # })
    
    m <- leaflet() %>%
        addTiles() %>%  # Add default OpenStreetMap map tiles
        addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R")
    m  # Print the map
    
    output$west_loop_map <- renderLeaflet({
        m
    })
    
    output$com1_map <- renderLeaflet({
        m
    })
    
    output$com2_map <- renderLeaflet({
        m
    })
    
    output$chicago_map <- renderLeaflet({
        m
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
