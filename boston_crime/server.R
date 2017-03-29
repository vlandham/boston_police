#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(ggthemes)
library(forcats)

# https://github.com/ramnathv/htmlwidgets
# seems to be the accepted way to extend
# base Shiny with new visualizations / tools
# leaflet is one such widget
library(leaflet)

incident_data <- read_csv("./data/crime.csv")
offense_group_filename <- './data/offense_group.csv'
offense_group <- read_csv(offense_group_filename)

incident_data <- incident_data %>% rename(lng = Long, lat = Lat)
incident_data <- incident_data %>% 
  mutate(date = ymd_hms(OCCURRED_ON_DATE)) %>% 
  mutate(month = month(date, abbr = TRUE, label = TRUE), hour = hour(date))

byGroup <- incident_data %>% group_by(OFFENSE_CODE_GROUP) %>% summarise(count = n()) %>% arrange(-count)
topGroups <- byGroup %>% head(n = 20)

byHour <- incident_data %>% group_by(OFFENSE_CODE_GROUP) %>% 
  mutate(group_total = n()) %>% 
  group_by(OFFENSE_CODE_GROUP, hour) %>% 
  summarise(count = n(), per = count / group_total[1])

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  # reactive() function allows you to use reactive input values to create a new variable 
  # that is correctly updated each time those input values change.
  filtered_incidents <- reactive({
    groups <- offense_group$OFFENSE_CODE_GROUP
    if(input$offense_group != 'ALL') {
      groups <- c(input$offense_group)
    }
    years <- unique(as.character(incident_data$YEAR))
    if(input$year != 'ALL') {
      years <- c(input$year)
    }
    
    incident_data %>% filter(OFFENSE_CODE_GROUP %in% groups) %>% filter(YEAR %in% years)
  })
  
  output$out <- renderText({
    groups = ifelse(input$offense_group == 'ALL', offense_group$OFFENSE_CODE_GROUP, c(input$offense_group))
    groups
  })
  
   
  output$yearPlot <- renderPlot({
    # draw year plot
    # NOTE: reactive() function returns a function. so we need to call filtered_incidents() to get the actual data. 
    if (input$year == 'ALL') {
      filtered_incidents() %>%
        ggplot(aes(x = as.factor(YEAR))) +
        geom_bar(stat = 'count') +
        theme_bw() +
        labs(title = "")
    } else {
      filtered_incidents() %>%
        group_by(month) %>% summarise(count = n()) %>%
        ggplot(aes(x = month, y = count, group = 1)) + 
        geom_line() +
        theme_bw() +
        labs(title = "")
    }
    
  })
  
  output$timeTitle <- renderText({
    if (input$year == 'ALL') {
      paste("Incident Reports by Year for ", input$offense_group, sep = "")
    } else {
      paste("Incident Reports in ", input$year, " for ", input$offense_group, sep = "")
    }
  })
  
 # output$locationPlot <- renderPlot({
 #   filtered_incidents() %>% filter(lng < -60) %>%
 #     ggplot(aes(x = lng, y = lat, color = OFFENSE_CODE_GROUP)) +
 #     geom_point(size = 0.4, alpha = 1 / 10) + 
 #     theme_map() + 
 #     coord_map("mercator") +
 #     labs(title = paste("Location of Incident Reports for ", input$offense_group, sep = ""))
 # })
  
  output$hourPlot <- renderPlot({
    filtered_incidents() %>% 
      ggplot(aes(x = hour)) + 
      geom_bar() +
      theme_bw() +
      labs(title = "")
    
  })
  
  output$hourTitle <- renderText({
    paste(input$offense_group, " Counts by Hour", sep = "")
  })
  
  
  # see http://rstudio.github.io/leaflet/shiny.html for 
  # recommendations of shiny integration
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet() %>% 
      setView(lng = -71.0589, lat = 42.3601, zoom = 12) %>% 
      addProviderTiles(providers$Stamen.Toner)
  })
  
  
  # Incremental changes to the map 
  # should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    leafletProxy("map", data = filtered_incidents()) %>%
      clearShapes() %>%
      addCircles()
  })
  
  output$hourSmallMult <- renderPlot({
    byHour %>% filter(OFFENSE_CODE_GROUP %in% topGroups$OFFENSE_CODE_GROUP) %>%
      ggplot(aes(x = hour, y = per)) + 
      geom_bar(stat = "identity") + 
      theme_bw() +
      facet_wrap(~ OFFENSE_CODE_GROUP) +
      labs(title = "", x = "", y = "Percent")
  })
  
  output$topGroups <- renderPlot({
    topGroups %>% 
      ggplot(aes(x = fct_rev(fct_inorder(OFFENSE_CODE_GROUP)), y = count)) +
      geom_bar(stat = "identity") +
      coord_flip() + 
      theme_bw() 
      labs(title = "", x = "", y = "Count")
  })
  
})
