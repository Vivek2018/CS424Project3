
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#libraries
library(ggplot2)
library(shiny)
library(mapview)
library(shinydashboard)
library(leaflet)
library(hash)
library(tigris)
library(dplyr)

#data prep for the project, read and then edit columns
data <- read.csv('energy-usage-2010.csv')
names(data)[names(data) == "TERM.APRIL.2010"] <- "THERM.APRIL.2010"

chicago_blocks <- blocks(state = "IL", count = "COOK", year = 2010)
chicago_tracts <- tracts(state = "IL", count = "COOK", year = 2010)

data$GEOID10 <- data$CENSUS.BLOCK

communities <- unique(data$COMMUNITY.AREA.NAME)


#create hash maps for easy look up 
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

Months <- c("JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER")


#utility functions for making data calc easy
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

#gets block info
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
    
    for (month in Months) {
        elec_monthly <- c(elec_monthly, sum(sub_data[paste('KWH', month, '2010', sep='.')]))
    }
    
    return (elec_monthly)
}

getMonthlyGas <- function(sub_data) {
    gas_monthly = c()
    
    for (month in Months) {
        gas_monthly <- c(gas_monthly, sum(sub_data[paste('THERM', month, '2010', sep='.')]))
    }
    
    return (gas_monthly)
}

getMonthlyDf <- function(energy_data, community, building) {
    
    sub_data <- getBlock(energy_data, community, building)
    
    sub_data[is.na(sub_data)] = 0
    
    Electricity <- as.numeric(getMonthlyElec(sub_data))
    Gas <- as.numeric(getMonthlyGas(sub_data))
    
    monthly_df <- data.frame(Months, Electricity, Gas)
    
    return(monthly_df)
}




chicago_Views = hash()

chicago_Views[['Electricity']] = 'TOTAL.KWH'
chicago_Views[['Gas']] = 'TOTAL.THERMS'
chicago_Views[["Building Type"]] <- "BUILDING.TYPE"
chicago_Views[["Building Age"]] <- "AVERAGE.BUILDING.AGE"
chicago_Views[["Building Height"]] <- "AVERAGE.STORIES"
chicago_Views[["Total Population"]] <- "TOTAL.POPULATION"

chicago_Views[['Oldest Buildings']] = 'AVERAGE.BUILDING.AGE'
chicago_Views[['Newest Buildings']] = 'AVERAGE.BUILDING.AGE'
chicago_Views[['Tallest Buildings']] = 'AVERAGE.STORIES'
chicago_Views[['Electricity Most Used']] = 'TOTAL.KWH'
chicago_Views[['Gas Most Used']] = 'TOTAL.THERMS'
chicago_Views[['Most Populated']] = 'TOTAL.POPULATION'
chicago_Views[['Most Occupied']] = 'OCCUPIED.UNITS'
chicago_Views[['Most Rented']] = 'RENTER.OCCUPIED.HOUSING.UNITS'


getTract <- function(energy_data, view, building) {
    
    energy_data$GEOID10 <- gsub('.{4}$', '', data$GEOID10)
    
    building_choice <- c()
    
    if (building == "All") {
        building_choice <- c("Commercial", "Residential", "Industrial")
    } else {
        building_choice <- c(building)
    }
    
    subset_df <- energy_data[energy_data$BUILDING.TYPE %in% building_choice, ]
    
    if (view %in% c("Electricity Most Used", "Gas Most Used", "Oldest Buildings", "Tallest Buildings", "Most Population", "Most Occupied", "Most Rented")) {
        subset_df <- subset_df %>% top_frac(0.1, chicago_Views[[view]])
    } else if (view == "Newest Buildings") {
        subset_df <- subset_df %>% top_frac(-0.1, chicago_Views[[view]])
    }
    
    newset <- data.frame(subset_df['GEOID10'], subset_df[chicago_Views[[view]]])
    return_set <- aggregate(newset[chicago_Views[[view]]], by=list(newset$GEOID10), FUN=sum, keep.names = TRUE, na.rm=TRUE, na.action=NULL)
    return_set$GEOID10 <- result$Group.1
    return(return_set)
}

getTractData <- function(energydata, chicago_data, view, building) {
    
    
    subset_df <- getTract(energydata, view, building)
    sub_chicago <- subset(chicago_data, GEOID10 %in% subset_df$GEOID10)
    tract_df <- merge(sub_chicago, subset_df[c(chicago_Views[[view]], "GEOID10")], by = "GEOID10")
    
    return(tract_df)
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
                                   'west_loop_Months', 'Select a Time Frame: ', choices = c("Year", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), selected = "Year", multiple = FALSE
                               ),
                               
                               selectizeInput(
                                   'west_loop_building', 'Select a Building Type: ', choices = c("All", "Commercial", "Residential", "Industrial"), selected = "All", multiple = FALSE
                               ),
                               
                               actionButton("reset_button_first_page", "Reset View"),
                               
                               plotOutput("west_loop_plot", height = 350)
                               
                               
                               
                        ),
                        
                        column(5, 
                               leafletOutput("west_loop_map", height = 630)
                        ),
                        
                        column(5,
                               box(title = "West Loop Info", solidHeader = TRUE, status = "primary", width = 100,
                                   dataTableOutput("west_loop_data")
                               )
                               
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
                                      'com1_Months', 'Select a Time Frame: ', choices = c("Year", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), selected = "Year", multiple = FALSE
                                  ),
                                  
                                  selectizeInput(
                                      'com1_building', 'Select a Building Type: ', choices = c("All", "Commercial", "Residential", "Industrial"), selected = "All", multiple = FALSE
                                  ),
                                  
                                  actionButton("reset_com1", "Reset View"),
                                  
                                  plotOutput("com1_plot", height = 350)
                                  
                                  
                           ), 
                           
                           column(8, 
                                  
                                  leafletOutput("com1_map", height = 630)
                                  
                           )
                       ),
                       fluidRow(
                           box(title = "Community 1 Info", solidHeader = TRUE, status = "primary", width = 100,
                               dataTableOutput("com1_data")
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
                                      'com2_Months', 'Select a Time Frame: ', choices = c("Year", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"), selected = "Year", multiple = FALSE
                                  ),
                                  
                                  selectizeInput(
                                      'com2_building', 'Select a Building Type: ', choices = c("All", "Commercial", "Residential", "Industrial"), selected = "All", multiple = FALSE
                                  ),
                                  
                                  actionButton("reset_com2", "Reset View"),
                                  
                                  plotOutput("com2_plot", height = 300)
                                  
                           ), 
                           
                           column(8, 
                                  
                                  leafletOutput("com2_map", height = 630)
                           )
                       ),
                                 
                    fluidRow(
                        box(title = "Community 2 Info", solidHeader = TRUE, status = "primary", width = 100,
                            dataTableOutput("com2_data")
                        )
                   
                       )
                )
                
            ),
            
            tabItem(
                tabName = "chicago",
                column(2, 
                       
                       selectizeInput(
                           'chicago_view', 'Select a View: ', choices = c("Electricity Most Used", "Gas Most Used", "Oldest Buildings", "Newest Buildings", "Tallest Buildings", "Most Population", "Most Occupied", "Most Rented", "Electricity", "Gas", "Building Type", "Building Age", "Building Height", "Total Population"), selected = "Electricity Most Used", multiple = FALSE
                       ),
                       
                       selectizeInput(
                           'chicago_building', 'Select a Building Type: ', choices = c("All", "Commercial", "Residential", "Industrial"), selected = "All", multiple = FALSE
                       ),
                       
                       actionButton("reset_chicago", "Reset View")),
                
                       
                      column(8, 
                        leafletOutput("chicago_map", height = 630)
                      
                    )
            ),
            
            tabItem(
                tabName = "about",
                h2("About Page"),
                verbatimTextOutput("AboutOut")
                
            )
        )
    )
)



# Define server logic required to draw a histogram
server <- function(input, output) {
    
    #First Map - West Side Loop
    
    
    actionsPage1 <- reactive({list(input$reset_button_first_page, input$west_loop_view, input$west_loop_Months, input$west_loop_building)})
    observeEvent(actionsPage1(), {
        
        choice <- generateChoice(input$west_loop_view, input$west_loop_Months)
        dataset <- createCommunityDataset(data, chicago_blocks, "Near West Side", input$west_loop_view, input$west_loop_Months, input$west_loop_building, choice)
        
        output$west_loop_map <- renderLeaflet({
            mapview(dataset, zcol = choice)@map
        })
        
        monthly_totals <- getMonthlyDf(data, "Near West Side", input$west_loop_building)
        
        
        output$west_loop_plot <- renderPlot({
            
            monthly_totals$Month <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
            
            ggplot(monthly_totals, aes(x=Month)) +
                geom_line(aes(y = Electricity, color = "darkred")) +
                geom_line(aes(y = Gas, color = "steelblue")) +
                ylab("Usage") + 
                xlab("Month") + 
                scale_color_identity(name = "Energy Sources",
                                     breaks = c("darkred", "steelblue"),
                                     labels = c("Electricity", "Gas"),
                                     guide = "legend")
        }) 
        
        output$west_loop_data <- renderDataTable(
            monthly_totals
        )
    })
    

    
    
    #Community 2 - Page 2 
    
    
   
    
    actionsCom2 <- reactive({list(input$reset_com2, input$com2, input$com2_view, input$com2_Months, input$com2_building)})
    observeEvent(actionsCom2(), {
        
        choice <- generateChoice(input$com2_view, input$com2_Months)
        dataset <- createCommunityDataset(data, chicago_blocks, input$com2, input$com2_view, input$com2_Months, input$com2_building, choice)
        
        output$com2_map <- renderLeaflet({
            mapview(dataset, zcol = choice)@map
        })
        
        
        monthly_totals <- getMonthlyDf(data, input$com2, input$com2_building)
        
        
        output$com2_plot <- renderPlot({
            
            monthly_totals$Month <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
            
            ggplot(monthly_totals, aes(x=Month)) +
                geom_line(aes(y = Electricity, color = "darkred")) +
                geom_line(aes(y = Gas, color = "steelblue")) +
                ylab("Usage") + 
                xlab("Month") + 
                scale_color_identity(name = "Energy Sources",
                                     breaks = c("darkred", "steelblue"),
                                     labels = c("Electricity", "Gas"),
                                     guide = "legend")
        }) 
        
        output$com2_data <- renderDataTable(
            monthly_totals
        )
        
    })
    
   # community 1 
    
    actionsCom1 <- reactive({list(input$reset_com1, input$com1, input$com1_view, input$com1_Months, input$com1_building)})
    observeEvent(actionsCom1(), {
        
        choice <- generateChoice(input$com1_view, input$com1_Months)
        dataset <- createCommunityDataset(data, chicago_blocks, input$com1, input$com1_view, input$com1_Months, input$com1_building, choice)
        
        output$com1_map <- renderLeaflet({
            mapview(dataset, zcol = choice)@map
        })
        
        
        monthly_totals <- getMonthlyDf(data, input$com1, input$com1_building)
        
        
        output$com1_plot <- renderPlot({
            
            monthly_totals$Month <- c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)
            
            ggplot(monthly_totals, aes(x=Month)) +
                geom_line(aes(y = Electricity, color = "darkred")) +
                geom_line(aes(y = Gas, color = "steelblue")) +
                ylab("Usage") + 
                xlab("Month") + 
                scale_color_identity(name = "Energy Sources",
                                     breaks = c("darkred", "steelblue"),
                                     labels = c("Electricity", "Gas"),
                                     guide = "legend")
        }) 
        
        output$com1_data <- renderDataTable(
            monthly_totals
        )
        
    })
    
    
    #chicago
    
    actionsChicago <- reactive({list(input$reset_chicago, input$chicago_view, input$chicago_building)})
    observeEvent(actionsChicago(), {
        
        dataset <- getTractData(data, chicago_tracts, input$chicago_view, input$chicago_building)
        output$chicago_map <- renderLeaflet({
            mapview(dataset, zcol = chicago_Views[[input$chicago_view]])@map
        })

    })

    #output for about page
    output$AboutOut <- renderText({
        "Created by: Vivek Bhatt\n
         Created: 4/24/2021\n
         Data Source: https://data.cityofchicago.org/Environment-Sustainable-Development/Energy-Usage-2010/8yq3-m6wp\n
         Intended for visualizing the contribution of energy sources in Chicago and other demographics."   
    })

    
}

# Run the application 
shinyApp(ui = ui, server = server)