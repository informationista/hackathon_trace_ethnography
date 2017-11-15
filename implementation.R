#read in the data
dat <- read.csv(file ="~/Desktop/test.csv") #a file containing team info for hackathons

dat$slack_token <- as.character(dat$slack_token) #fixes the slack token variable so the script works


#separate out the different dates and the productive vs non-productive projects  - I could prob do this programmatically but for now this is easier
august <- subset(dat, dates == "Aug 14-16" & prod != "P")
june <- subset(dat, dates == "June 19-21" & prod != "P")
september <- subset(dat, dates == "Sept 25-27" & prod != "P")
prod_june <- subset(dat, dates == "June 19-21" & prod == "P")
prod_august <- subset(dat, dates == "Aug 14-16" & prod == "P")
dat <- list(august, june, september)

#get the data for each month
august <- mapply(get_hack_data, august$slack.channel.name, august$slack_token, august$gdoc.id, august$repo.name, SIMPLIFY = FALSE) 

june <- mapply(get_hack_data, june$slack.channel.name, june$slack_token, june$gdoc.id, june$repo.name, SIMPLIFY = FALSE) 

september <- mapply(get_hack_data, september$slack.channel.name, september$slack_token, september$gdoc.id, september$repo.name, SIMPLIFY = FALSE) 

prod_june <- mapply(get_hack_data, prod_june$slack.channel.name, prod_june$slack_token, prod_june$gdoc.id, prod_june$repo.name, SIMPLIFY = FALSE) 

prod_aug <- mapply(get_hack_data, prod_august$slack.channel.name, prod_august$slack_token, prod_august$gdoc.id, prod_august$repo.name, SIMPLIFY = FALSE) 


#before making the plots, the names in each df need to be disambiguated and anonymized. I've done this in a separate script for privacy 

#make the plots, setting correct dates for each event. first the non-productive
lapply(august, make_trace_plots, start_date = "2017-08-14", end_date = "2017-08-16")
lapply(june, make_trace_plots, start_date = "2017-06-19", end_date = "2017-06-21")
lapply(september, make_trace_plots, start_date = "2017-09-25", end_date = "2017-09-27")


##next the productive
lapply(prod_june, make_trace_plots, start_date = "2017-06-19", end_date = "2017-06-21")
lapply(prod_aug, make_trace_plots, start_date = "2017-08-14", end_date = "2017-08-16")



##just the ones I'm interested in as examples and fixed the names
make_trace_plots(prod_aug[[2]], start_date = "2017-08-14", end_date = "2017-08-16")
make_trace_plots(august[[5]], start_date = "2017-08-14", end_date = "2017-08-16")


prod_table <- as.data.frame(table(prod_aug[[2]]$user, prod_aug[[2]]$data_source))
aug_table <- as.data.frame(table(august[[5]]$user, august[[5]]$data_source))

write.csv(file = "prod.csv", prod_table)
write.csv(file= "aug.csv", aug_table)
