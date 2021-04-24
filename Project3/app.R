
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
library(hash)
library(tigris)

data <- read.csv('energy-usage-2010.csv')
names(data)[names(data) == "TERM.APRIL.2010"] <- "THERM.APRIL.2010"

chicago_blocks <- blocks(state = "IL", count = "COOK", year = 2010)
data$GEOID10 <- data$CENSUS.BLOCK
communities <- unique(data$COMMUNITY.AREA.NAME)

views <- hash() 
views[["Electricity"]] <- "KWH"
views[["Gas"]] <- "THERM"
views[["Building Type"]] <- "BUILDING.TYPE"
views[["Building Age"]] <- "AVERAGE.BUILDING.AGE"
views[["Building Height"]] <- "AVERAGE.STORIES"
views[["Total Population"]] <- "TOTAL.POPULATION"


timeframes <- hash()
timeframes[["Year"]] <- "TOTAL"
timeframes[["January"]] <- "JANUARY"
timeframes[["February"]] <- "FEBRUARY"
timeframes[["March"]] <- "MARCH"
timeframes[["April"]] <- "APRIL"
timeframes[["June"]] <- "JUNE"
timeframes[["July"]] <- "JULY"
timeframes[["August"]] <- "AUGUST"
timeframes[["September"]] <- "SEPTEMBER"
timeframes[["October"]] <- "OCTOBER"
timeframes[["November"]] <- "NOVEMBER"
timeframes[["December"]] <- "DECEMBER"

months <- c("JANUARY", "FEBRUARY", "MARCH", "APRIL", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER")

generateChoice <- function(view, timeframe) {
    if (view == 'Gas' || view == "Electricity") {
        if (timeframe != 'Year') {
            choice <- paste(views[[view]], timeframes[[timeframe]], '2010', sep=".")
        } else {
            if (view == 'Gas') {
                choice <- paste(timeframes[[timeframe]], "THERMS", sep=".")
            } else {
                choice <- paste(timeframes[[timeframe]], views[[view]], sep=".")  
            }
            
        }
    } else {
        choice <- views[[view]]
    }
    
    return(choice)
}


getBlock <- function(energy_data, community, building) {
    building_choice <- c()
    
    if (building == "All") {
        building_choice <- c("Commercial", "Residential", "Industrial")
    } else {
        building_choice <- c(building)
    }
    
    subset_df <- energy_data[energy_data$COMMUNITY.AREA.NAME == community & energy_data$BUILDING.TYPE %in% building_choice, ]
    
    return (subset_df)
}

createCommunityDataset <- function(energy_data, chicago_data, community, view, timeframe, building, choice) {
    
    subset_df <- getBlock(energy_data, community, building)
        
    sub_chicago <- subset(chicago_data, GEOID10 %in% subset_df$GEOID10)
    
    community_df <- merge(sub_chicago, subset_df[c(choice, "GEOID10")], by = "GEOID10")
    
    return (community_df)
    
}


getMonthlyElec <- function(sub_data) {
    elec_monthly = c()
    
    for (month in months) {
        elec_monthly <- c(elec_monthly, sum(sub_data[paste('KWH', month, '2010', sep='.')]))
    }
    
    return (elec_monthly)
}

getMonthlyGas <- function(sub_data) {
    gas_monthly = c()
    
    for (month in months) {
        gas_monthly <- c(gas_monthly, sum(sub_data[paste('THERM', month, '2010', sep='.')]))
    }
    
    return (gas_monthly)
}

getMonthlyDf <- function(energy_data, community, building) {
    
    sub_data <- getBlock(energy_data, community, building)
        
    sub_data[is.na(sub_data)] = 0
    
    elec <- getMonthlyElec(sub_data)
    gas <- getMonthlyGas(sub_data)
    
    monthly_df <- data.frame(months, elec, gas)
    
    return(monthly_df)
}

ui <- dashboardPage(
    
    #create dashboard and elements
    dashboardHeader(title = "CS 424 Project 3"),
    
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
                           'west_loop_view', 'Select a View: ', choices = c("Electricity", "Gas", "Building Type", "Building Age", "Building Height", "Total Population"), selected = "Electricity", multiple = FALSE, 
                       ),
                       
                       selectizeInput(
                           'west_loop_months', 'Select a Time Frame: ', choices = c("Year", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), selected = "Year", multiple = FALSE
                       ),
                       
                       selectizeInput(
                           'west_loop_building', 'Select a Building Type: ', choices = c("All", "Commercial", "Residential", "Industrial"), selected = "All", multiple = FALSE
                       ),
                       
                       actionButton("reset_button_first_page", "Reset View")
                       
                       
                           
                   ),
                   
                   column(5, 
                        leafletOutput("west_loop_map", height = 630)
                  ),
                   
                   column(5,
                          plotOutput("west_loop_plot", height = 300),
                          dataTableOutput("west_loop_data")
                    ),
                )
            ),
            
            tabItem(
                tabName="community_compare",
                column(6, 
                       fluidRow(
                            column(4,
                                    
                                   selectizeInput(
                                       'com1', 'Select a Community: ', choices = communities, multiple = FALSE, selected = "Near West Side"
                                   ),

                                   selectizeInput(
                                       'com1_view', 'Select a View: ', choices = c("Electricity", "Gas", "Building Type", "Building Age", "Building Height", "Total Population"), selected = "Electricity", multiple = FALSE
                                   ),

                                   selectizeInput(
                                       'com1_months', 'Select a Time Frame: ', choices = c("Year", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), selected = "Year", multiple = FALSE
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
                                  'com2', 'Select a Community: ', choices = communities, multiple = FALSE, selected = "Loop"
                              ),

                              selectizeInput(
                                  'com2_view', 'Select a View: ', choices = c("Electricity", "Gas", "Building Type", "Building Age", "Building Height", "Total Population"), selected = "Electricity", multiple = FALSE
                              ),

                              selectizeInput(
                                  'com2_months', 'Select a Time Frame: ', choices = c("Year", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), selected = "Year", multiple = FALSE
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
    
    actionsPage1 <- reactive({list(input$reset_button_first_page, input$west_loop_view, input$west_loop_months, input$west_loop_building)})
    observeEvent(actionsPage1(), {
        
        choice <- generateChoice(input$west_loop_view, input$west_loop_months)
        dataset <- createCommunityDataset(data, chicago_blocks, "Near West Side", input$west_loop_view, input$west_loop_months, input$west_loop_building, choice)
        
        output$west_loop_map <- renderLeaflet({
            mapview(dataset, zcol = choice)@map
        })
        
        monthly_totals <- getMonthlyDf(data, "Near West Side", input$west_loop_building)
            
        
        output$west_loop_plot <- renderPlot({
            
        }) 
        
        output$west_loop_data <- renderDataTable(
            monthly_totals
        )
    })
    
    
    
    
    
   
    
    
    #Community 1 - Page 2 
    
    actionsCom1 <- reactive({list(input$reset_com1, input$com1, input$com1_view, input$com1_months, input$com1_building)})
    observeEvent(actionsCom1(), {
        
        choice <- generateChoice(input$com1_view, input$com1_months)
        dataset <- createCommunityDataset(data, chicago_blocks, input$com1, input$com1_view, input$com1_months, input$com1_building, choice)
        
        output$com1_map <- renderLeaflet({
            mapview(dataset, zcol = choice)@map
        })
    
    })

    actionsCom2 <- reactive({list(input$reset_com2, input$com2, input$com2_view, input$com2_months, input$com2_building)})
    observeEvent(actionsCom2(), {
        
        choice <- generateChoice(input$com2_view, input$com2_months)
        dataset <- createCommunityDataset(data, chicago_blocks, input$com2, input$com2_view, input$com2_months, input$com2_building, choice)
        
        output$com2_map <- renderLeaflet({
            mapview(dataset, zcol = choice)@map
        })
        
    })

    output$chicago_map <- renderLeaflet({
        # m
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)