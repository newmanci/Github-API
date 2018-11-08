
install.packages("jsonlite")
library(jsonlite)
install.packages("httpuv")
library(httpuv)
install.packages("httr")
library(httr)

# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what you 
myapp <- oauth_app(appname = "Interrogate API",
                   key = "a403c7bb073a784b3c14",
                   secret = "a2871f1813e8a1344995950edc3429f0046da287")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)

# Use API
gtoken <- config(token = github_token)
req <- GET("https://api.github.com/users/jtleek/repos", gtoken)

# Take action on http error
stop_for_status(req)

# Extract content from a request
json1 = content(req)

# Convert to a data.frame
gitDF = jsonlite::fromJSON(jsonlite::toJSON(json1))

# Subset data.frame
#gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"] 



chrislgarryData <- fromJSON("https://api.github.com/users/chrislgarry")
chrislgarryData$following #Number of users chris is following 
chrislgarryData$followers #Number of users following chris page 
chrislgarryData$public_repos #Number of public repositories chris has 

FollowersData <- fromJSON("https://api.github.com/users/newmanci/followers")
FollowersData$login
length <- length(FollowersData$login) #the amount of people who follow me
length

FollowingData  <- fromJSON("https://api.github.com/users/newmanci/following")
FollowingData$login
length <- length(FollowingData$login) #the amount of people who follow me
length

