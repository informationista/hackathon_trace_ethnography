library(httr)
library(jsonlite)
library(googlesheets)
library(reshape2)
library(scales)

token <- gs_auth() #create the token to authorize Google drive

google_chart <- function(file_id) {
  url <- paste("https://www.googleapis.com/drive/v2/files/", file_id, "/revisions", sep = "") #create the url
  api_data <- GET(url, config(token = token))  #get the data
  revisions <- content(api_data) #cleanly render the JSON
  revisions <- fromJSON(toJSON(revisions$items)) #create a data frame from the JSON
  revisions <- revisions[, c(6, 9)] #get the relevant columns date and author
  revisions$lastModifyingUserName <- gsub("NULL", "anonymous", revisions$lastModifyingUserName) #replace "null" entries with anonymous
  revisions$lastModifyingUserName <- as.factor(unlist(revisions$lastModifyingUserName)) #convert to a factor variable to use with ggplot
  
  #clean up the date formatting
  revisions_times <- colsplit(unlist(revisions$modifiedDate), "T", names = c('Day', 'Time'))
  revisions <- cbind(revisions, revisions_times)
  revisions$Time <- gsub("Z", "", revisions$Time)
  
  #convert to POSIXct and fix time zones
  revisions$Day <- as.POSIXct(revisions$Day, format = "%Y-%m-%d")
  revisions$Time <- as.POSIXct(revisions$Time, format = "%H:%M:%S", tz = "GMT")
  revisions$Time <- as.POSIXct(format(revisions$Time, tz = "America/New_York", usetz = TRUE))
  
  #remove the outlier where the hackathon organizer created the document
  revisions <- revisions[-1, ]
  
  ggplot(revisions, aes(Day, Time, color = lastModifyingUserName)) + geom_point() + scale_x_datetime(breaks = date_breaks("1 day"), labels=date_format("%b %d")) + scale_y_datetime(breaks = date_breaks("2 hours"), labels = date_format("%H:%M")) + theme(axis.text.x=element_text(angle=45), panel.background = element_rect(fill = "white"))
}
