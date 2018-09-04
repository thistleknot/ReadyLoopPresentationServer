#https://stackoverflow.com/questions/7411216/error-index-vectors-are-of-different-classes-numeric-date
library(XML)
library(RCurl)

url <- "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
sp500html <- getURL(url)
sp500 <- readHTMLTable(sp500html, stringsAsFactors = F)[[1]][,1]