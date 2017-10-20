#this script makes one chart with all three data source charts on it.  It takes as input a data frame with the slack channel name, slack workspace token, github repo name, and google doc for each team.

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


#once the data are all set the names need to be disambiguated and de-identified.  At this point I really see no way of doing this except manually. Then it can be charted.

##this is a function that will draw the plots. It takes as input the data frame, plus the start and end date of the hackathon in yyyy-mm-dd format.  This assumes you are charting the data on the same day you downloaded it - things won't look right otherwise.
make_trace_plots <- function(df, start_date, end_date) {
  lims <- as.POSIXct(strptime(c(paste(Sys.Date()-1, "20:00"),(paste(Sys.Date(), "24:00"))), format = "%Y-%m-%d %H:%M"))
  
  p <- ggplot(df, aes(day, time, color = user))  + geom_point(size = 1) + scale_x_datetime(breaks = date_breaks("3 days"), labels=date_format("%b %d")) + scale_y_datetime(limits = lims, breaks = date_breaks("3 hours"), labels = date_format("%H:%M")) + theme(axis.text.x=element_text(angle=90, margin = margin(t = 5, r = 0, b = 0, l = 0)), panel.background = element_rect(fill = "white")) + annotate("rect", ymin = as.POSIXct(paste(Sys.Date()-1, "20:00")), ymax = as.POSIXct(paste(Sys.Date(), "24:00")), xmax = as.POSIXct(paste(start_date, "00:00:00")), xmin = as.POSIXct(paste(end_date, "04:00:00")), fill = "grey", alpha = 0.3) + facet_wrap(~data_source, nrow = 3) 
  return(p)

}
