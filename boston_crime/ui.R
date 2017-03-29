#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(leaflet)

offense_group_filename <- './data/offense_group.csv'
offense_group <- read_csv(offense_group_filename)

# content for tab1
tab1UI <- function(id, label = "Tab 1") {
  # Create a namespace function using the provided id
  # see: https://shiny.rstudio.com/articles/modules.html
  ns <- NS(id)
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
      htmlOutput("timeTitle", container = tags$h2),
      plotOutput("yearPlot"),
      htmlOutput("hourTitle", container = tags$h2),
      plotOutput("hourPlot"),
      leafletOutput("map")
    )
  )
}

tab2UI <- function(id, label = "Tab 2") {
  ns <- NS(id)
  mainPanel(
    tags$h2("Top Overall Incident Groups"),
    plotOutput("topGroups"),
    tags$h2("Top Incident Groups by Hour"),
    plotOutput("hourSmallMult")
  )
}

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Boston Police Incident Data"),
  tabsetPanel(id = "tabs",
              tabPanel(title = "Panel 1", value="panel1",
                       tab1UI()
                       
                       
              ),
              tabPanel(title = "Panel 2", value="panel2",
                       tab2UI()
              )
  )
))
