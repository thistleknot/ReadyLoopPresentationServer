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

if (!require(tidyquant)) install.packages('tidyquant')

# tidy financial analysis 
if (!require(janitor)) install.packages('janitor')

# tidy data cleaning functions
library(tidyverse)
library(janitor)
library(rvest)
library(tidyquant)

get_symbols = function(ticker = "CL"){
  df = tq_get(ticker, from = first.date) %>% mutate(symbol = rep(ticker, length(first.date)))
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
symbols <- sp500tickers$Symbol

sp500Symbols <- BatchGetSymbols(tickers = symbols,
                                do.parallel = TRUE,
                                first.date = first.date,
                                last.date = last.date, 
                                be.quiet = TRUE,
                                #cache results in "can only subtract from "Date" objects"
                                #probably due to parallel
                                do.cache=FALSE)

sp500Symbols$df.tickers

list_SP500 <- group_split(sp500Symbols$df.tickers %>% group_by(ticker))

xts(list_SP500[[1]], order.by=as.Date(list_SP500[[1]][, 7]$ref.date))

#getSymbols("AAPL", from="1990-01-01", src="yahoo")

#adjustOHLC(AAPL)
adjustOHLC(xts(list_SP500[[1]], order.by=as.Date(list_SP500[[1]][, 7]$ref.date)))
#adjustOHLC(list_SP500[[1]])
