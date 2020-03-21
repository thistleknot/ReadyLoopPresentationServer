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

get_symbols = function(ticker){
  #df = tq_get(ticker, from = first.date) %>% mutate(symbol = rep(ticker, length(first.date)))
  getSymbols(ticker, from=first.date, src="yahoo")
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
#symbols <- sample(sp500tickers$Symbol,5)
symbols <- sample(sp500tickers$Symbol,5)

first.date <- Sys.Date() - 821
last.date <- Sys.Date() - 805

symbol_env <- new.env()
data <- mclapply(symbols, function (x) {
  
  getSymbols(x, src="yahoo", return.class = "xts",from=first.date, env = NULL)
  
})

c("Open","High","Low","Close","Volume","Adjusted")

#adjustOHLC(getSymbols("AAPL",src="yahoo", return.class = "xts",from=first.date, env = NULL),adjust=c("split","dividend"),symbol.name="AAPL")
#getSymbols("AAPL")
#adjustOHLC(AAPL)

#https://stackoverflow.com/questions/5577727/is-there-an-r-function-for-finding-the-index-of-an-element-in-a-vector
#which may be slightly expensive, alternative is to pass more than one value and pass in an omg iterator!
names(data) <- symbols

#xts(data.frame(data[1]),order.by=as.Date(rownames(data.frame(data[1])), format = "%Y-%m-%d"))

#one liner doesn't work
#adjusted.list <- mclapply(symbols, function(x) {try(adjustOHLC(getSymbols(x,src="yahoo", return.class = "xts",from=first.date, env = NULL),adjust=c("split","dividend"),symbol.name=x))})
#adjustOHLC(getSymbols("AAPL",src="yahoo", return.class = "xts",from=first.date, env = NULL),adjust=c("split","dividend"),symbol.name="AAPL")

adjusted.list <- mclapply(symbols, function(x) {
  try(adjustOHLC(data.frame(data[x]), adjust=c("split","dividend"), symbol.name=symbols[x], use.Adjusted=TRUE))
})

names(adjusted.list) <- symbols

adjusted.list.wdates <- mclapply(symbols,function (x) {
  xts(data.frame(adjusted.list[x]),order.by=as.Date(rownames(data.frame(data[x])), format = "%Y-%m-%d"))
})

names(adjusted.list.wdates) <- symbols

