library(jsonlite)
library(httpuv)
library(httr)
library(plyr)
library(ggplot2)
library(scales)


#This requires getting a token - I did this using the instructions at https://medium.com/towards-data-science/accessing-data-from-github-api-using-r-3633fb62cb08
#Get list of relevant repos from the NCBI-Hackathons organization
repos_list <- GET("https://api.github.com/orgs/NCBI-Hackathons/repos", gtoken)

# Extract the content and create a data frame from it
#right now this doesn't extract quite right. This will need to be fixed.
repo_df <- fromJSON(toJSON(content(repos_list)))

#this is a bad fix but it will work for now
repo_df1 <- data.frame(matrix(NA, nrow = 30))
repo_df1$id <- as.integer(repo_df$id)
repo_df1$tags_url <- as.character(repo_df$tags_url)
repo_df1$git_tags_url <- as.character(repo_df$git_tags_url)
repo_df1$commits_url <- as.character(repo_df$commits_url)


#Here is a function that will do all the getting of data and making of charts. But this only works if there are no more than 100 commits
github_retriever <- function(repo_name){
  url <- paste("https://api.github.com/repos/NCBI-Hackathons/", repo_name, "/commits?page=1&per_page=100", sep="") #creates the url to retrieve the data
  commit_history <- GET(url, gtoken) #gets the data
  commit_times <- fromJSON(toJSON(content(commit_history))) #convert from JSON 
  commit_df <- commit_times$commit$author #get the relevant data frame out
  commit_df$name <- unlist(commit_df$name) #unlist the names for making the charts
  commit_dates <- strsplit(unlist(commit_df$date), "T") #create separate columns for day and time
  commit_dates <- as.data.frame(matrix(unlist(commit_dates), ncol=2, byrow=TRUE)) #clean up the dates
  commit_df <- cbind(commit_df, commit_dates) #put the dates back with the rest of the data
  commit_df <- rename(commit_df, c(V1 = "day", V2 = "time")) #rename columns
  commit_df$time <- gsub("Z", "", commit_df$time) #get rid of the time zone indicator
  commit_df$time <- as.POSIXct(commit_df$time, format="%H:%M", tz="Etc/GMT") #convert times to POSIX
  commit_df$time <- as.POSIXct(format(commit_df$time, tz = "America/New_York", usetz=TRUE)) #convert to correct time zone
  commit_df$day <- as.POSIXct(commit_df$day,format="%Y-%m-%d") #convert dates to POSIX
  
  #make the chart
  ggplot(commit_df, aes(day, time, color = name)) + geom_point() + scale_x_datetime("", breaks = date_breaks("1 day"), labels = date_format("%b%d")) + scale_y_datetime("", breaks= date_breaks("2 hours"), labels = date_format("%I:%M%p", tz = "America/New_York"))
  
  commit_df <- data.frame(user = commit_df$name, day= commit_df$day, time = commit_df$time, data_source = as.character("Github Repo Commits"))
  
  return(commit_df)
}
