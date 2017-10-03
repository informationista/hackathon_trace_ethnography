#this script makes one chart with all three data source charts on it

library(ggplot2)
library(scales)

#get and combine relevant data
slack <- slack_history() #insert slack team name
gdocs <- google_data() #insert a document id
github <- github_retriever() #insert a github repo name
combo_data <- rbind(gdocs, slack, github)


#set up the y axis limits. I don't love how this looks.  Needs some work.
lims <- as.POSIXct(strptime(c("2017-10-03 00:00","2017-10-03 24:00"), format = "%Y-%m-%d %H:%M"))    

ggplot(combo_data, aes(day, time, color = user))  + geom_point() + scale_x_datetime(breaks = date_breaks("2 days"), labels=date_format("%b %d")) + scale_y_datetime(limits = lims, breaks = date_breaks("3 hours"), labels = date_format("%H:%M")) + theme(axis.text.x=element_text(angle=45), panel.background = element_rect(fill = "white")) + annotate("rect", ymin = as.POSIXct("2017-10-03 00:00:00"), ymax = as.POSIXct("2017-10-03 24:00:00"), xmax = as.POSIXct("2017-08-14 00:00:00"), xmin = as.POSIXct("2017-08-16 04:00:00"), fill = "grey", alpha = 0.3) + facet_wrap(~data_source, nrow = 3)
