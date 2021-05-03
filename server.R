
library(shiny)
library(shinydashboard)
library(readr)
library(dplyr)
library(lubridate)
library(tsibble)
library(slider)
library(ggplot2)
library(plotly)

library(shiny)

data1 <- read_rds("~/Documents/DataViz_2021/ShinyApps/Homelessness/data/point_data.rds") 
data2 <- read_rds("~/Documents/DataViz_2021/ShinyApps/Homelessness/data/housing_data.rds")

statelabels <- unique(data1$State)
yearlabels <- c("2019","2018", "2017", "2016", "2015", "2014", "2013", 
                "2012", "2011", "2010", "2009", "2008", "2007")



shinyServer(function(input, output, session) {
    
    updateSelectInput(session, "state", choices = statelabels, selected = "Total")
    
    updateSelectInput(session, "year", choices = yearlabels, selected = "2019")
    
    output$myplot1 <- renderPlotly({
        
        plotdata <- merge(data1, data2, by = c("year", "State")) %>%
            filter(State == input$state)
        
        ay <- list(
            overlaying = "y",
            side = "right",
            title = "Available Shelter Beds"
            )
        fig <- plot_ly(data = plotdata,
                       type="scatter",
                       mode="lines+markers",
                       x=~year,
                       y=~`Overall Homeless`,
                       text = paste0("Year: ", plotdata$year, "<br>",
                                     "Homeless people: ", plotdata$`Overall Homeless`, "<br>"),
                       hoverinfo="text",
                       name = "Homeless people") %>% 
                add_trace(type="scatter",
                          mode="lines+markers",
                          x = ~year, 
                          y = ~`Total Year-Round Beds (ES, TH, SH)`,
                          text = paste0("Year: ", plotdata$year, "<br>",
                                        "Shelter Beds: ", plotdata$`Total Year-Round Beds (ES, TH, SH)`, "<br>"),
                          hoverinfo="text",
                          name = "Shelter Beds", yaxis = "y2") %>% 
                layout(
                        title = "", yaxis2 = ay,
                        xaxis = list(title="Year"),
                        yaxis = list(title="Homeless population")
                      )
        fig <- fig %>% config(displayModeBar = FALSE)
        
    })
    
    output$myplot2 <- renderPlotly({
        
       plotdata <- merge(data1, data2, by = c("year", "State")) %>%
           filter(year == input$year) %>%
           filter(State != "Total") %>%
           mutate(percent = 100*`Unsheltered Homeless` / `Overall Homeless`) 
       
       fig <- plot_ly(data = plotdata,
                      type="bar",
                      marker = list(color = "#bcbddc", 
                                    line = list(color="#8856a7", width = 2)),
                      x=~State,
                      y=~percent,
                      text = paste0("State: ", plotdata$State, "<br>",
                                    "Unsheltered Homeless Individuals: ",
                                    paste0(round(plotdata$percent) , "%"), "<br>"),
                      hoverinfo="text") %>% 
           layout(
               xaxis = list(title="State"),
               yaxis = list(title="", ticksuffix = "%")
           )
       fig <- fig %>% config(displayModeBar = FALSE)
    })
    
    output$mytable1 <- DT::renderDataTable({
        
        tabledata <- merge(data1, data2, by = c("year", "State")) %>%
                     filter(State == input$state)
        
        tabledata1 <- tabledata %>% 
                      select(year, `Overall Homeless`,
                             `Sheltered Total Homeless`,
                             `Unsheltered Homeless`,
                             `Total Year-Round Beds (ES, TH, SH)`)
        
        DT::datatable(tabledata1[, c(1,2,3,4,5), drop = FALSE], 
                      colnames = c('Year', 'Overall Homeless', 'Sheltered', 'Unsheltered', 
                                   'Available Shelter Beds'),
                      options = list(searching = FALSE, paging = FALSE),
                      caption = input$state)
    })

})
