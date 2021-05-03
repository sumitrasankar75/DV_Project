library(shiny)
library(shinydashboard)
library(lubridate)
library(plotly)

dashboardPage(
    dashboardHeader(title = "Homelessness in US"),
    dashboardSidebar(
        
        selectInput("state", "Select state to see Homeless people & Shelter Beds:",
                    choices = "Total"),
        
        selectInput("year", "Select year to see % of unsheltered homeless people:", 
                     choices = c("2019","2018", "2017", "2016", "2015", "2014", "2013", 
                                 "2012", "2011", "2010", "2009", "2008", "2007"),
                     selected = "2019")
        
        
    ),
    dashboardBody(
        fluidRow(
            
            box(width=12, 
                status="info", 
                title="Homeless people & Shelter beds from 2007-2019",
                solidHeader = TRUE,
                plotlyOutput("myplot1")
            ),
            
            box(width=12,
                status="info",
                title="Percentage of unsheltered homeless individuals",
                solidHeader = TRUE,
                plotlyOutput("myplot2")
            ),
            
            box(width=12, 
                status="info", 
                title=("Summary 2007-2019"),
                solidHeader = TRUE,
                DT::dataTableOutput("mytable1")
            )
            
        )
    )
)



