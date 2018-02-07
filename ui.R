library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Data Portal",
                  dropdownMenu(type = "messages",
                               messageItem(
                                 from = "Sales Dept",
                                 message = "Sales forecating for you"
                               ),
                               messageItem(
                                 from = "New User",
                                 message = "Welcome to dashboard",
                                 icon = icon("question"),
                                 time = "13.45"
                               )
                  ),
                  
                  dropdownMenu(type = "notification",
                               notificationItem(
                                 text = "5 items delivered",
                                 icon = icon("users")
                               ),
                               notificationItem(
                                 text = "12 items delivered",
                                 icon("truck"),
                                 status = "success"
                               ),
                               notificationItem(
                                 text = "Fuction overload 86%",
                                 icon("warning"),
                                 status = "warning"
                               )
                  ),
                  
                  dropdownMenu(type = "tasks", badgeStatus = "success",
                               taskItem(
                                 value = 85, color = "green", "Sales done by Merchant"
                               ),
                               taskItem(
                                 value = 65, color = "red", "Data Analysis"
                               )
                  )
                  ),
  dashboardSidebar(
    h5("Powered by"),
    tags$img(src="download.png",align = "center", height=70, width = 230),
    
    sliderInput("rateThreshold", "Warn when rate exceeds",
                min = 0, max = 50, value = 3, step = 0.1
    ),
    sidebarMenu(
      
    fileInput("file1", "Choose CSV File",
                multiple = TRUE,
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
    radioButtons("disp", "Display", 
                 choices = c(Head = "head",
                             All = "all"),
                 selected = "head"),
      
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Charts", tabName = "barchart", icon = icon("bar-chart")),
      menuItem("Data", icon = icon("database"),
        menuSubItem("Raw data", tabName = "rawdata", icon = icon("archive")),
        menuSubItem("Data summary", tabName = "datasummary", icon = icon("book"))
      )
      
              
    )
  ),
  dashboardBody(
    tabItems(
      tabItem("dashboard",
              fluidRow( 
                valueBoxOutput("rate"),
                valueBoxOutput("count"),
                valueBoxOutput("users")
              ),
              fluidRow(
                box(
                   status = "info", solidHeader = TRUE,
                  title = "Merchant Name",collapsible = TRUE,
                  plotOutput("plot")
                ),
                
              fluidRow(
                  box(
                    status = "warning", solidHeader = TRUE,
                    title = "Product Name", collapsible = TRUE,
                    plotOutput("plot1")
                  )
                )
                
              )
      ),
      tabItem("rawdata",
              numericInput("maxrows", "Rows to show", 25),
              verbatimTextOutput("rawtable"),
              downloadButton("downloadCsv", "Download as CSV")
      ),
      tabItem("datasummary",
              h4("Summary"),
              verbatimTextOutput("summary"),
              
              h3("Data"),
              tableOutput("contents")),
      tabItem("barchart",
             
              
              fluidRow(
                box(status = "primary",
                    solidHeader = TRUE, 
                    title = "Transactions per States", collapsible = TRUE, 
                    plotlyOutput("chart1")),
                
                box(status = "warning",
                    solidHeader = TRUE,
                    title = "Transaction and Sale Amount by States", collapsible = TRUE,
                    plotlyOutput("plot4"))
              ),
              
              fluidRow(
                box(status = "primary", solidHeader = TRUE,
                    title = "Saleamount per merchant", collapsible = TRUE,
                    plotlyOutput("plot5")),
              
                box(status = "warning", solidHeader = TRUE,
                    title = "Transactions per merchant", collapsible = TRUE,
                    plotlyOutput("pie")
                  
                )
              )
              )
                
      
    )
  )
)
