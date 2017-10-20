#read in the data
dat <- read.csv(file ="Desktop/test.csv") #a file containing team info for hackathons

dat$slack_token <- as.character(dat$slack_token) #fixes the slack token variable so the script works


#separate out the different dates - I could prob do this programmatically but for now this is easier
august <- subset(dat, dates == "Aug 14-16")
june <- subset(dat, dates == "June 19-21")
september <- subset(dat, dates == "Sept 25-27")
dat <- list(august, june, september)

#get the data for each month
august <- mapply(get_hack_data, august$slack.channel.name, august$slack_token, august$gdoc.id, august$repo.name, SIMPLIFY = FALSE) 

june <- mapply(get_hack_data, june$slack.channel.name, june$slack_token, june$gdoc.id, june$repo.name, SIMPLIFY = FALSE) 

september <- mapply(get_hack_data, september$slack.channel.name, september$slack_token, september$gdoc.id, september$repo.name, SIMPLIFY = FALSE) 


#before making the plots, the names in each df need to be disambiguated and anonymized. I've done this in a separate script for privacy 

#make the plots, setting correct dates for each event
lapply(august, make_trace_plots, start_date = "2017-08-14", end_date = "2017-08-16")
lapply(june, make_trace_plots, start_date = "2017-06-19", end_date = "2017-06-21")
lapply(september, make_trace_plots, start_date = "2017-09-25", end_date = "2017-09-27")
