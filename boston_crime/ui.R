#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

offense_group_filename <- './data/offense_group.csv'
offense_group <- read_csv(offense_group_filename)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Boston Police Incident Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("offense_group",
                   "Offense Group Name:",
                  append('ALL', offense_group$OFFENSE_CODE_GROUP), 
                  selected = "Drug Violation"),
      selectInput("year",
                  "Year:",
                  c('ALL', '2015', '2016', '2017'),
                  selected = "ALL")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("yearPlot"),
       leafletOutput("map"),
       plotOutput("locationPlot")
    )
  )
))
