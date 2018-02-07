library(ggplot2)
library(shinythemes)
library(readr)
library(tm)
library(SnowballC)
library(wordcloud)
library(plotly)


function(input, output, session) {
  
  data2 <- reactive({
    file2<- input$file1
    
    df <- read.csv(input$file1$datapath,
                   header = TRUE,
                   sep = ','
    )
  })
  
  
  
  pkgStream <- packageStream(session)
  
  maxAgeSecs <- 60 * 5
  
  pkgData <- packageData(pkgStream, maxAgeSecs)
  
  dlCount <- downloadCount(pkgStream)
  
  usrCount <- userCount(pkgStream)
  
  startTime <- as.numeric(Sys.time())
  
  output$rate <- renderValueBox({
    elapsed <- as.numeric(Sys.time()) - startTime
    downloadRate <- nrow(pkgData()) / min(maxAgeSecs, elapsed)
    
    valueBox(
      value = formatC(downloadRate, digits = 1, format = "f"),
      subtitle = "Transactions per sec (last 5 min)",
      icon = icon("area-chart"),
      color = if (downloadRate >= input$rateThreshold) "yellow" else "aqua"
    )
  })
  
  output$count <- renderValueBox({
    valueBox(
      value = dlCount()*2,
      subtitle = "Total Sale Amount",
      icon = icon("money")
    )
  })
  
  output$users <- renderValueBox({
    valueBox(
      usrCount(),
      "Total Transcations",
      icon = icon("credit-card")
    )
  })
  
  
  output$packageTable <- renderTable({
    pkgData() %>%
      group_by(package) %>%
      tally() %>%
      arrange(desc(n), tolower(package)) %>%
      mutate(percentage = n / nrow(pkgData()) * 100) %>%
      select("Package name" = package, "% of downloads" = percentage) %>%
      as.data.frame() %>%
      head(15)
  }, digits = 1)
  
  output$downloadCsv <- downloadHandler(
    filename = "cranlog.csv",
    content = function(file) {
      write.csv(pkgData(), file)
    },
    contentType = "text/csv"
  )
  
  output$rawtable <- renderPrint({
    orig <- options(width = 1000)
    print(tail(pkgData(), input$maxrows))
    options(orig)
  })
  
  output$summary <- renderPrint({
        summary(data2())
  })
  
  output$contents <- renderTable({
    
    if(input$disp == "head") {
      head(data2())
    }
    else {
      data2()
    }
  })
  
  output$chart1 <- renderPlotly({
    sample <- read_csv("F:/Course/Project 5/cran/www/Sample Data_Data Portal.csv")
    
    sample$state_name <- as.factor(sample$state_name)
    sample$district_name<- as.factor(sample$district_name)
    sample$transcnt <- as.factor(sample$transcnt)
    sample$saleamount <- as.factor(sample$saleamount)
    sample$merchant_name <- as.factor(sample$merchant_name)
    
    
    q <- ggplot(sample, aes(x = state_name, fill = transcnt))+ geom_histogram(binwidth = 3, stat = "count")+ theme_bw()+
      labs(y = "Transactions")  
    q + theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p = ggplot2::last_plot())
  })
  
  output$plot <- renderPlot({
    
    jeopQ <- read.csv('data.csv', stringsAsFactors = FALSE)
    
    jeopCorpus <- Corpus(VectorSource(jeopQ))
    jeopCorpus <- tm_map(jeopCorpus, content_transformer(tolower))
    
    wordcloud(jeopCorpus,min.freq = 1 ,max.words = 100, random.order = FALSE, colors = brewer.pal(6, "Dark2"))
    
  })
  
  output$plot1 <- renderPlot({
    
    jeopQ <- read.csv('data3.csv', stringsAsFactors = FALSE)
    
    jeopCorpus <- Corpus(VectorSource(jeopQ))
    jeopCorpus <- tm_map(jeopCorpus, content_transformer(tolower))
    
    wordcloud(jeopCorpus,min.freq = 1 ,max.words = 100, random.order = FALSE, colors = brewer.pal(6, "Dark2"))
    
  })
  
  output$plot4 <- renderPlotly({
    
    sample <- read_csv("F:/Course/Project 5/cran/www/Sample Data_Data Portal.csv")
    
    plot_ly(sample, x = ~state_name, y = ~saleamount, z = ~transcnt)
  
    })
  
  output$plot5 <- renderPlotly({
    
    sample <- read_csv("F:/Course/Project 5/cran/www/Sample Data_Data Portal.csv")
    
    plot_ly(sample, x = ~merchant_name, y = ~saleamount, type = "scatter", color = "#a1ef5d")
    
  })
  
  output$pie <- renderPlotly({
    
    sample <- read_csv("F:/Course/Project 5/cran/www/Sample Data_Data Portal.csv")
    
    plot_ly(sample, x = ~merchant_name, y = ~transcnt, type = "box", color = I("#73ef3e"))
    
  })
  
    
}

