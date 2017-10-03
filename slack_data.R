library(httr)
library(jsonlite)
library(googlesheets)
library(reshape2)
library(scales)

token <- gs_auth() #create the token to authorize Google drive

google_data <- function(file_id) {
  url <- paste("https://www.googleapis.com/drive/v2/files/", file_id, "/revisions", sep = "") #create the url
  api_data <- GET(url, config(token = token))  #get the data
  revisions <- content(api_data)
  revisions <- fromJSON(toJSON(revisions$items))
  revisions <- revisions[, c(6, 9)] #get the relevant columns date and author
  revisions$lastModifyingUserName <- gsub("NULL", "anonymous", revisions$lastModifyingUserName)
  revisions$lastModifyingUserName <- as.factor(unlist(revisions$lastModifyingUserName))
  
  
  #clean up the date formatting
  revisions_times <- colsplit(unlist(revisions$modifiedDate), "T", names = c('day', 'time'))
  revisions <- cbind(revisions, revisions_times)
  revisions$time <- gsub("Z", "", revisions$time)
  
  #convert to POSIXct and fix time zones
  revisions$day <- as.POSIXct(revisions$day, format = "%Y-%m-%d")
  revisions$time <- as.POSIXct(revisions$time, format = "%H:%M:%S", tz = "GMT")
  revisions$time <- as.POSIXct(format(revisions$time, tz = "America/New_York", usetz = TRUE))
  
  #remove the outlier where the hackathon organizer created the document
  revisions <- revisions[-1, ]
  
  revisions$data_source <- as.character("Google Doc Revisions")
  
  #format for consistency with other data sources
  revisions <- revisions[, 2:5]
  names(revisions)[1] <- "user"
  
  
  return(revisions)
}
