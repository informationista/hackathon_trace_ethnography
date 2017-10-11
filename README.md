# Hackathon Trace Ethnography

Research on hackathons using "traces" or artifacts of the development and documentation process.  

## What is this thing?
I am, among other things, a PhD student in information science, and I research scientific hackathons.  This repo contains code used to create visual representations of hackathon communication in the form of Slack channels, Github Repos, and Google Docs.  In this project, I am looking at different patterns of communication among teams and whether these have an impact on outcomes and outputs of the hackathon.

## Why should I use it?
Probably you shouldn't.  I can't imagine this has any usefulness for any one other than me, but I've been learning about pipelines and Github and Git at hackathons so I thought it would be fun and interesting to put my code here.  Also, working on this was a lot more interesting than working on my lit review.

## Parts of this repo
Essentially this repo contains a pipeline consisting of several parts:

### Data-getting parts
* get_github_data.R: takes as input names of Github repos and a Github API token, gets back and parses data on commit history
* download_google_doc_data.R: using the Google auth functionality from the googlesheets package, this takes as input document IDs for google docs and gets back and parses data on revision history
* slack_data.R: takes as input a Slack API token and Slack channel names and gets back and parses data on Slack channel chat history


