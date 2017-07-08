#
# This is the user-interface definition of a Shiny web application. 
# If you are viewing this in RStudio, you can run the 
# application by clicking 'Run App' above.
#

library(shiny)
library(tidyverse)
library(leaflet)

offense_group_filename <- './data/offense_group.csv'
offense_group <- read_csv(offense_group_filename)

# content for tab1
tab1UI <- function(id, label = "Incidents") {
  # Create a namespace function using the provided id
  # see: https://shiny.rstudio.com/articles/modules.html
  ns <- NS(id)
  # Sidebar with a slider input for number of bins 
  verticalLayout(
    br(),
    column(6, 
           wellPanel(
             selectInput("offense_group",
                         "Offense Group Name:",
                         append('ALL', offense_group$OFFENSE_CODE_GROUP), 
                         selected = "Drug Violation"),
             selectInput("year",
                         "Year:",
                         c('ALL', '2015', '2016', '2017'),
                         selected = "ALL")
           )
    ),
    
    # Show a plot of the generated distribution
      htmlOutput("timeTitle", container = tags$h2),
      plotOutput("yearPlot"),
      htmlOutput("hourTitle", container = tags$h2),
      plotOutput("hourPlot"),
      htmlOutput("mapTitle", container = tags$h2),
      leafletOutput("map"),
      br()
  )
}

tab2UI <- function(id, label = "Incident by Hour") {
  ns <- NS(id)
  verticalLayout(
    br(),
    tags$h2("Top Overall Incident Groups"),
    plotOutput("topGroups"),
    tags$h2("Top Incident Groups by Hour"),
    plotOutput("hourSmallMult"),
    br()
  )
}

tab3UI <- function(id, label = "Incident by Location") {
  ns <- NS(id)
  verticalLayout(
    br(),
    tags$h2("Top Incident Groups by Location"),
    plotOutput("locSmallMult", height = "4200px"),
    br()
  )
}

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Boston Police Incident Data"),
  tabsetPanel(id = "tabs",
              tabPanel(title = "Incidents", value="panel1",
                       tab1UI()
                       
                       
              ),
              tabPanel(title = "Incidents by Hour", value="panel2",
                       tab2UI()
              ),
              tabPanel(title = "Incidents by Location", value="panel3",
                       tab3UI()
              )
  )
))
