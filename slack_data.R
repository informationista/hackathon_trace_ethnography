library(slackr)
library(httr)
library(jsonlite)
library(anytime)
library(reshape2)

#takes as inputs the team name and the workspace token  obtained from https://api.slack.com/custom-integrations/legacy-tokens

slack_history <- function(team_name, slack_token) {
  #first get the data!
  team_ids <- slackr_channels(api_token = slack_token) #first get the team names from the workspace
  team_ids <- fromJSON(toJSON(team_ids)) #create a data frame to be able to get a team ID if you have its name
  index <- which(team_ids$name == team_name) #find the row number of the desired team
  team_id <- team_ids$id[index] #get its id number
  url <- paste("https://slack.com/api/channels.history?token=", slack_token, "&channel=", team_id, "&count=1000", sep="") #create the post url
  message_JSON <- POST(url) #retrieve the data
  messages <- fromJSON(toJSON(content(message_JSON))) #extract the data
  messages <- messages$messages #create a df out of the desired data
  
  #clean up the data
  messages$user[sapply(messages$user, is.null)] <- NA #replace any null values with NA so it doesn't mess up in the next line of code
  messages$user <- as.factor(unlist(messages$user)) 
  messages$ts <- anytime(as.numeric(unlist(messages$ts))) #convert time stamp from UNIX epoch time to POSIXct item
  message_times <- colsplit(unlist(messages$ts), " ", names = c('day', 'time')) #split the time into day and time
  messages <- cbind(user = messages$user, message_times)
  
  #convert to POSIXct and fix time zones
  messages$day <- as.POSIXct(messages$day, format = "%Y-%m-%d")
  messages$time <- as.POSIXct(messages$time, format = "%H:%M:%S")
  #get the user names to pair up with the IDs 
  url <- paste("https://slack.com/api/users.list?token=", slack_token, sep="") #create the post url
  users_JSON <- POST(url) #retrieve the data
  users <- fromJSON(toJSON(content(users_JSON))) #extract the JSON
  users <- users$members #make the users data frame
  users$id <- unlist(users$id) #get out the ids
  users$real_name[sapply(users$real_name, is.null)] <- NA #replace any null values with NA so it doesn't mess up in the next line of code
  users$real_name <- unlist(users$real_name) #get out the names
  users <- data.frame(users$real_name, users$id)
  messages <- merge(messages, users, by.x = "user", by.y = "users.id")
  #format for consistency with other data sources
  messages <- data.frame(user = messages$users.real_name, day = messages$day, time = messages$time, data_source = as.character("Slack Channel Messages"))

  return(messages)
}