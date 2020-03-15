# for scraping
library(rvest)
# blanket import for core tidyverse packages
library(tidyverse)
# tidy financial analysis 
library(tidyquant)
# tidy data cleaning functions
library(janitor)
library(rvest)

get_symbols = function(ticker = "CL"){
  df = tq_get(ticker, from = date) %>% mutate(symbol = rep(ticker, length(date)))
}

#https://towardsdatascience.com/exploring-the-sp500-with-r-part-1-scraping-data-acquisition-and-functional-programming-56c9498f38e8

# save current system date to a variable
today <- Sys.Date()
# subtract 3 months from the current date
date = today %m+% months(-25)
print(date)

# pass SP500 ticker ^GSPC to tq_get function

#ftp://ftp.nasdaqtrader.com/SymbolDirectory/
  
#one_ticker = tq_get("^GSPC", from = date)
#one_ticker %>% 
#  head()

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

tickers_df = map(symbols, get_symbols) %>% bind_rows()

#colnames(sp500tickers)
tickers_df = tickers_df %>% 
  # left join with wikipedia data
  left_join(sp500tickers, by = c('symbol' = 'Symbol')) %>% 
  # make names R compatible
  clean_names() %>% 
  #doesn't work
  # keep only the columns we need
  select(date:security, "gics_sector", "gics_sub_industry")

