library(shiny)
library(shinySignals)   
library(dplyr)
library(shinydashboard)
library(bubbles)        
source("bloomfilter.R")

prototype <- data.frame(date = character(), time = character(),
                        amount = numeric(), r_version = character(),
                        r_os = character(), mercahnt_name = character(), product = character(),
                        country = character(), ip_id = character(), received = numeric())


packageStream <- function(session) {
  
  sock <- socketConnection("cransim.rstudio.com", 6789, blocking = FALSE, open = "r")
  
  session$onSessionEnded(function() {
    close(sock)
  })
  
  
  newLines <- reactive({
    invalidateLater(1000, session)
    readLines(sock)
  })
  
  
  reactive({
    if (length(newLines()) == 0)
      return()
    read.csv(textConnection(newLines()), header=FALSE, stringsAsFactors=FALSE,
             col.names = names(prototype)
    ) %>% mutate(received = as.numeric(Sys.time()))
  })
}


packageData <- function(pkgStream, timeWindow) {
  shinySignals::reducePast(pkgStream, function(memo, value) {
    rbind(memo, value) %>%
      filter(received > as.numeric(Sys.time()) - timeWindow)
  }, prototype)
}


downloadCount <- function(pkgStream) {
  shinySignals::reducePast(pkgStream, function(memo, df) {
    if (is.null(df))
      return(memo)
    memo + nrow(df)
  }, 0)
}


userCount <- function(pkgStream) {
  
  bloomFilter <- BloomFilter$new(5000, 0.01)
  total <- 0
  reactive({
    df <- pkgStream()
    if (!is.null(df) && nrow(df) > 0) {
      
      ids <- paste(df$date, df$ip_id) %>% unique()
      
      newIds <- !sapply(ids, bloomFilter$has)
      total <<- total + length(newIds)
      sapply(ids[newIds], bloomFilter$set)
    }
    total
  })
}