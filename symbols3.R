if (!require(HelpersMG)) install.packages('HelpersMG')
#required for BatchGetSymbols
#requires apt-get install libxml2-dev
if (!require(rvest)) install.packages('rvest')
if (!require(XML)) install.packages('XML')
if (!require(BatchGetSymbols)) install.packages('BatchGetSymbols')
if (!require(future)) install.packages('future')
if (!require(anytime)) install.packages('anytime')
if (!require(RCurl)) install.packages('RCurl')
if (!require(data.table)) install.packages('data.table')
if (!require(quantmod)) install.packages('quantmod')

betaTestCoefficient = .25

#options("download.file.method"="wget")

library(HelpersMG)
library(BatchGetSymbols)
library(future)
library(data.table)
library(quantmod)
#library(anytime)
#library(RCurl)

wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqtraded.txt")
wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/mfundslist.txt")
#9 quarters is 5479/8897 61% (60%)
nasdaqTraded <- as.character(head(read.csv("nasdaqtraded.txt",sep="|")$Symbol,-2))
mfunds <- as.character(head(read.csv("nasdaqtraded.txt",sep="|")$Symbol,-2))

#wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/bondslist.txt")
#bonds <- head(read.csv("bondslist.txt",sep="|")$Symbol,-2)

#nested function not working
get_Symbols <- function (x)
{
  getSymbols(x, from=first.date, src="yahoo")
}

adjust_OHLC <- function (x)
{
  adjustOHLC(x)
}

put_symbols_into_file <- function(fil,data,size) {
  dput(batch_get_symbols(data,size),fil)
}

batch_get_symbols <- function(data,size) {
  BatchGetSymbols(tickers = sample(data,size*betaTestCoefficient),
                  do.parallel = TRUE,
                  first.date = first.date,
                  last.date = last.date, 
                  be.quiet = TRUE,
                  #cache results in "can only subtract from "Date" objects"
                  #probably due to parallel
                  do.cache=FALSE)
}

filtered_symbols <- function(fil)
{
  dget(fil, keep.source = TRUE)$df.control$ticker
}

join_file_symbols <- function(x)
{
  list(filList[[x]],filteredSymbols[[x]])
}

join_file_csvNames <- function(x)
{
  list(filList[[x]],csvNames[[x]])
}

write_subset_csv <- function(fil,name)
{
  fwrite(dget(fil[[1]][[1]], keep.source = TRUE)$df.tickers, name) 
}

#how to create objects of these and create functions for them?
fil_Nasdaq <- c()
fil_Nasdaq <- tempfile()
#mfunds
fil_mfunds <- c()
fil_mfunds <- tempfile()

first.date <- Sys.Date() - 821
last.date <- Sys.Date() - 814
future::plan(future::multisession, workers = 4)

#https://stackoverflow.com/questions/10776742/how-can-i-make-a-list-of-lists-in-r
#https://stackoverflow.com/questions/60766832/nested-r-function-with-lapply
list_nasdaq <- list(fil=fil_Nasdaq, data=nasdaqTraded, size=770)
list_mfunds <- list(fil=fil_mfunds, data=mfunds, size=324)

mylists <- list(list_nasdaq, list_mfunds)

lapply(mylists, FUN=function(x) put_symbols_into_file(fil=x$fil, data=x$data, size=x$size))

#https://stackoverflow.com/questions/20428742/select-first-element-of-nested-list
files <- lapply(mylists, `[[`, 1)
#using 3 sigma
#nasdaq 61% success rate @8897
#mfunds 76% success rate @250

first.date <- Sys.Date() - 821
last.date <- Sys.Date()

filNasdaq <- c()
filNasdaq <- tempfile()
filmfunds <- c()
filmfunds <- tempfile()

#Used with filterSymbolsList / join_file_symbols
filteredSymbols <- lapply(files,filtered_symbols)
filList <- list(filNasdaq,filmfunds)
numLists <- 1:length(filList)

#list(filList[[1]],filteredSymbols[[1]])
filteredSymbolsList <- lapply(numLists,join_file_symbols)

lapply(filteredSymbolsList, FUN=function(x) put_symbols_into_file(fil=x[[1]], data=x[[2]], size=220))

#dget(filteredSymbolsList[[1]][[1]],keep.source=TRUE)$df.tickers

csvNames=list("200NasdaqSymbols2Years.csv","200MFundsSymbols2Years.csv")
csv_list <- lapply(numLists,join_file_csvNames)

#dget(csv_list[[1]][[1]],keep.source = TRUE)$df.tickers

lapply(csv_list, FUN=function(x) write_subset_csv(fil=x[[1]], name=x[[2]]))

source("sp500.R")

lapply(filteredNasdaq,get_symbols)

holder.a <- lapply(noquote(filteredNasdaq),adjust_OHLC)

adjustOHLC(holder)
head(AAPL)
head(AAPL.a <- adjustOHLC(AAPL))
head(AAPL.uA <- adjustOHLC(AAPL, use.Adjusted=TRUE))