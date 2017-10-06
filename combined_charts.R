#this script makes one chart with all three data source charts on it

library(ggplot2)
library(scales)
library(plyr)

#get and combine relevant data
get_hack_data <- function(slack_name, slack_token, gdoc_id, gh_repo) {
  slack <- slack_history(slack_name, slack_token) #insert slack team name
  gdocs <- google_data(gdoc_id) #insert a document id
  github <- github_retriever(gh_repo) #insert a github repo name
  combo_data <- rbind(gdocs, slack, github)
  #return(combo_data)
}

dat <- read.csv(file ="Desktop/test.csv")
three_hacks_dat <- mapply(get_hack_data, dat$slack.channel.name, dat$gdoc.id, dat$repo.name, SIMPLIFY = FALSE) #this returns a list of ggplot items

new_dat[[1]]$data$user #this contains the user names so theoretically could be edited to fix the names


#once the data are all set the names need to be disambiguated and de-identified

#set up the y axis limits. I don't love how this looks.  Needs some work.



#for now let's do the charting separately so the data can be cleaned up

p <- ggplot(combo_data, aes(day, time, color = user))  + geom_point(size = 1) + scale_x_datetime(breaks = date_breaks("2 days"), labels=date_format("%b %d")) + scale_y_datetime(limits = lims, breaks = date_breaks("3 hours"), labels = date_format("%H:%M")) + theme(axis.text.x=element_text(angle=45), panel.background = element_rect(fill = "white")) + annotate("rect", ymin = as.POSIXct("2017-10-04 00:00:00"), ymax = as.POSIXct("2017-10-04 24:00:00"), xmax = as.POSIXct("2017-08-14 00:00:00"), xmin = as.POSIXct("2017-08-16 04:00:00"), fill = "grey", alpha = 0.3) + facet_wrap(~data_source, nrow = 3) + ggtitle(gh_repo)
return(p)
lims <- as.POSIXct(strptime(c("2017-10-04 00:00","2017-10-04 24:00"), format = "%Y-%m-%d %H:%M")) 