
#install.packages("jsonlite")
library(jsonlite)
#install.packages("httpuv")
library(httpuv)
#install.packages("httr")
library(httr)


# Can be github, linkedin etc depending on application
oauth_endpoints("github")

# Change based on what your github is
myapp <- oauth_app(appname = "Interrogate API",
                   key = "a403c7bb073a784b3c14",
                   secret = "a2871f1813e8a1344995950edc3429f0046da287")

# Get OAuth credentials
github_token <- oauth2.0_token(oauth_endpoints("github"), myapp)
1
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
gitDF[gitDF$full_name == "jtleek/datasharing", "created_at"] 


#-------------------Social Graph 1-------------------------------
#install.packages("plotly")
require(devtools)
library(plotly)


myFollowing = GET("https://api.github.com/users/newmanci/following", gtoken)
myFollowingDetails = content(myFollowing) #users I am  following


myFollowing.DF = jsonlite::fromJSON(jsonlite::toJSON(myFollowingDetails))


id = myFollowing.DF$login
usernames = c(id) #save following in a vector


allusers = c() 
allusers.DF = data.frame(
  Username = integer(),
  Following = integer(),
  Followers = integer(),
  Repositories = integer(),
  DateCreated = integer()
)#empty vectors created


for (i in 1:length(usernames)) #for loop to add users I am following
{
  #user I am following - who they are following 
  followingurl = paste("https://api.github.com/users/", usernames[i], "/following", sep = "")
  following = GET(followingurl, gtoken)
  followingDetails = content(following)
  
  
  if (length(followingDetails) == 0) #dont include people who dont follow anyone
  {
    next
  }
  
  
  following.DF = jsonlite::fromJSON(jsonlite::toJSON(followingDetails))
  followingLogin = following.DF$login
  
  
  for (j in 1:length(followingLogin)) #loop throwing following's following users
  {
    
    if (is.element(followingLogin[j], allusers) == FALSE) #check user not in twice
    {
      
      allusers[length(allusers) + 1] = followingLogin[j]
      
      
      followingurl2 = paste("https://api.github.com/users/", followingLogin[j], sep = "")
      following2 = GET(followingurl2, gtoken)
      followingDetails2 = content(following2) #get details of people I am following - who they are following
      following.DF2 = jsonlite::fromJSON(jsonlite::toJSON(followingDetails2))
      
      
          
        followingno = following.DF2$following #who they following
        reposno = following.DF2$public_repos #number of repositories
        followersno = following.DF2$followers #their followers
        yearcreated = substr(following.DF2$created_at, start = 1, stop = 4) #when they joined
      
      allusers.DF[nrow(allusers.DF) + 1, ] = c(followingLogin[j], followingno , followersno, reposno, yearcreated)
      
    }
    next
  }
  # stop when there are 150 users so it doesnt take ages to run
  if(length(allusers) > 150)
  {
    break
  }
  next
}



#link to my plotly account
Sys.setenv("plotly_username" = "newmanci")
Sys.setenv("plotly_api_key" = "GMoBYljvAJTc3GLBnm92")


# Visual 1: Scatter plot of Followers vs. Repositories, colour coded by year they created Github account
firstplot = plot_ly(data = allusers.DF, x = ~Repositories, y = ~Followers,  text = ~paste("Followers: ", Followers, "<br>Repositories: ", 
                                                                                          Repositories, "<br>Date Created:", DateCreated), color = ~DateCreated)

firstplot
api_create(firstplot, filename = "Number of Followers vs. Number of Repositories")

# <- -------------------Second Social Graph---------------------------------
#second graph takes alot longer to run

langs = c() #empty language vector


for (i in 1:length(allusers)) #go through all users
{

  RepositoriesUrl = paste("https://api.github.com/users/", allusers[i], "/repos", sep = "")
  Repositories = GET(RepositoriesUrl, gtoken)
  RepositoriesDetails = content(Repositories)
  RepositoriesDF = jsonlite::fromJSON(jsonlite::toJSON(RepositoriesDetails)) #find users repositories
  

  RepositoriesNames = RepositoriesDF$name #repositories names
  
 
  for (j in 1: length(RepositoriesNames)) #loop through repos of a user
  {
   
    RepositoriesUrl2 = paste("https://api.github.com/repos/", allusers[i], "/", RepositoriesNames[j], sep = "")
    Repositories2 = GET(RepositoriesUrl2, gtoken)
    RepositoriesDetails2 = content(Repositories2)
    RepositoriesDF2 = jsonlite::fromJSON(jsonlite::toJSON(RepositoriesDetails2))
    

    lang = RepositoriesDF2$language #find language each repo was written in
    
   
    if (length(lang) != 0 && lang != "<NA>") #skip empty repository with no language
    {

      langs[length(langs)+1] = lang #increment languages
    }
    next
  }
  next
}


Sys.setenv("plotly_username" = "newmanci")
Sys.setenv("plotly_api_key" = "GMoBYljvAJTc3GLBnm92")

langTable= sort(table(langs), increasing=TRUE) #save top 20 languages in table
LangTableTop20 = langTable[(length(langTable)-19):length(langTable)]


LanguageDF = as.data.frame(LangTableTop20)


secondplot = plot_ly(data = LanguageDF, x = LanguageDF$Languages, y = LanguageDF$Freq, type = "bar")
secondplot


api_create(secondplot, filename = "Barchart of Languages")

