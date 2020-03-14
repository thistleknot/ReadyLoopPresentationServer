# for scraping
library(rvest)
# blanket import for core tidyverse packages
library(tidyverse)
# tidy financial analysis 
library(tidyquant)
# tidy data cleaning functions
library(janitor)
library(rvest)

letters=LETTERS[seq( from = 1, to = 26 )]

# get the URL for the wikipedia page with all SP500 symbols

#functional programming

append_url <- function(x) {
  print(paste0("http://www.findata.co.nz/markets/AMEX/symbols/",x,".htm"))
  #x
}
urls <- lapply(letters, append_url)

tickers <- function(x) {
  # use that URL to scrape AMEX page 
  tickers <- x %>%
    # read the HTML from the webpage
    read_html() %>%
    # one way to get table
    #html_nodes(xpath='//*[@id="mw-content-text"]/div/table[1]') %>%
    # easier way to get table
    html_nodes(xpath = '//*[@id="cph1_bsa1_divSymbols"]/table/') %>% 
    html_table()
}

tickerList <- lapply(urls,tickers)

extractSymbols <- function(x) {
  tickerList[[x]][[1]][1]
}

lettersNumbers <- 1:26

symbols <- unlist(lapply(lettersNumbers,extractSymbols))
View(symbols)
