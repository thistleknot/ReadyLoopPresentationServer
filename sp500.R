#called from getSymbols3.R

# for scraping
library(rvest)
# blanket import for core tidyverse packages
if (!require(alphavantager)) install.packages('alphavantager')
if (!require(timetk)) install.packages('timetk')
if (!require(timeDate)) install.packages('timeDate')
if (!require(dbplyr)) install.packages('dbplyr')
if (!require(reprex)) install.packages('reprex')
if (!require(tidyverse)) install.packages('tidyverse')

if (!require(parallel)) install.packages('parallel')

if (!require(tidyquant)) install.packages('tidyquant')

# tidy financial analysis 
if (!require(janitor)) install.packages('janitor')

# tidy data cleaning functions
library(tidyverse)
library(janitor)
library(rvest)
library(tidyquant)
library(parallel)
library(BatchGetSymbols)

#bind_list
library(dplyr)
#RETRY
library(httr)

#rbindlist
library(data.table)

get_symbols = function(ticker){
  #df = tq_get(ticker, from = first.date) %>% mutate(symbol = rep(ticker, length(first.date)))
  getSymbols(ticker, from=first.date, to=last.date, src="yahoo")
}

#https://towardsdatascience.com/exploring-the-sp500-with-r-part-1-scraping-data-acquisition-and-functional-programming-56c9498f38e8

# get the URL for the wikipedia page with all SP500 symbols
url <- "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
# use that URL to scrape the SP500 table using rvest
tickers <- url %>%
  # read the HTML from the webpage
  read_html() %>%
  # one way to get table
  #html_nodes(xpath='//*[@id="mw-content-text"]/div/table[1]') %>%
  # easier way to get table
  html_nodes(xpath = '//*[@id="constituents"]') %>% 
  html_table()
#create a vector of tickers
sp500tickers <- tickers[[1]]

sp500tickers = sp500tickers %>% mutate(Symbol = case_when(Symbol == "BRK.B" ~ "BRK-B",
                                                          Symbol == "BF.B" ~ "BF-B",
                                                          TRUE ~ as.character(Symbol)))
#betaTest
#symbols <- sample(sp500tickers$Symbol,20)
symbols <- sp500tickers$Symbol

names(symbols) <- symbols

future::plan(future::multisession, workers = 4)
first.date <- Sys.Date() - 821
last.date <- Sys.Date()
#last.date <- Sys.Date() - 805

symbol_env <- new.env()

#too fast and errors out on many index's
#data <- mclapply(symbols, function (x) {
#no need for XTS
#getSymbols(x, src="yahoo",from=first.date, to=last.date, env = NULL)
#})

#too slow
#data_env <- new.env()
#data <- getSymbols(symbols, src="yahoo",from=first.date, to=last.date, auto.assign = TRUE, env = data_env)
#data_list <- eapply(data_env, print)

sp500_Sample_200 <- 
  BatchGetSymbols(tickers = sample(symbols,220),
                  do.parallel = TRUE,
                  first.date = first.date,
                  last.date = last.date, 
                  be.quiet = TRUE,
                  #cache results in "can only subtract from "Date" objects"
                  #probably due to parallel
                  do.cache=TRUE)

#View(sp500_Sample_200$df.tickers)

list_sp500_Sample_200 <- group_split(sp500_Sample_200$df.tickers, sp500_Sample_200$df.tickers$ticker)
list_sp500_Sample_200_names <- sort(unique(sp500_Sample_200$df.tickers$ticker))

names(list_sp500_Sample_200) <- list_sp500_Sample_200_names
names(list_sp500_Sample_200_names) <- list_sp500_Sample_200_names

#xts(data.frame(data[1]),order.by=as.Date(rownames(data.frame(data[1])), format = "%Y-%m-%d"))

#one liner doesn't work
#adjusted.list <- mclapply(symbols, function(x) {try(adjustOHLC(getSymbols(x,src="yahoo", return.class = "xts",from=first.date, env = NULL),adjust=c("split","dividend"),symbol.name=x))})
#adjustOHLC(getSymbols("AAPL",src="yahoo", return.class = "xts",from=first.date, env = NULL),adjust=c("split","dividend"),symbol.name="AAPL")

#column rename
#View(list_sp500_Sample_200[[1]][,])
colNames= c("Open", "High", "Low", "Close", "Volume", "Adjusted", "Date", "Ticker", "Return.Adjusted", "Return.Closing", "sp500_Sample_200$df.tickers$ticker")
list_sp500_Sample_200 <- mclapply(list_sp500_Sample_200_names, function (x) {
  setNames(list_sp500_Sample_200[[x]][,], colNames)
})

#testing
#x=list_sp500_Sample_200_names[1]

#has to be dataframe vs default xts for rbindlist.
adjusted_list_sp500_Sample_200 <- mclapply(list_sp500_Sample_200_names, function(x) {
  as.data.frame(adjustOHLC(xts(as.data.frame(list_sp500_Sample_200[[x]][,])[,c("Open","High","Low","Close","Volume","Adjusted")],order.by=as.POSIXct(list_sp500_Sample_200[[x]][,]$Date)), adjust=c("split","dividend"), symbol.name=list_sp500_Sample_200_names[x], use.Adjusted=TRUE))
})

#add back in dates

#cbind("Date"=list_sp500_Sample_200[[x]][,]$Date,adjusted_list_sp500_Sample_200[[x]][,])

adjusted_list_sp500_Sample_200_wDates <- mclapply(list_sp500_Sample_200_names,function (x) {
  cbind("Date"=list_sp500_Sample_200[[x]][,]$Date,adjusted_list_sp500_Sample_200[[x]][,])
})

adjusted_DF_sp500_Sample_200 <- rbindlist(adjusted_list_sp500_Sample_200_wDates, use.names=TRUE, fill=TRUE, idcol="Symbol")

View(adjusted_DF_sp500_Sample_200)


