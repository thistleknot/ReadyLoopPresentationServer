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
#list_nasdaq <- list(fil_Nasdaq,nasdaqTraded,770)
#list_mfunds <- list(fil_mfunds,mfunds,324)
#mylists <- list(list_nasdaq, list_mfunds)

#put_symbols_into_file(fil_Nasdaq,nasdaqTraded,770)
#https://stackoverflow.com/questions/31561238/lapply-function-loops-on-list-of-lists-r
#lapply(mylists, sapply, put_symbols_into_file)
#lapply(mylists,put_symbols_into_file)

#using 3 sigma
#61% success rate
#testing parent nested function
#put_symbols_into_file(fil_Nasdaq,nasdaqTraded,770)
#put_symbols_into_file(fil_mfunds,mfunds,324)
dput(batch_get_symbols(nasdaqTraded,770),fil_Nasdaq)
#76% success rate
dput(batch_get_symbols(mfunds,324),fil_mfunds)

filteredNasdaq <- dget(fil_Nasdaq, keep.source = TRUE)$df.control$ticker
filteredMFunds <- dget(fil_mfunds, keep.source = TRUE)$df.control$ticker

first.date <- Sys.Date() - 821
last.date <- Sys.Date()

fil_Nasdaq <- c()
fil_Nasdaq <- tempfile()
fil_mfunds <- c()
fil_mfunds <- tempfile()

dput(BatchGetSymbols(tickers = sample(filteredNasdaq,220*betaTestCoefficient), first.date = first.date,last.date = last.date, do.parallel = TRUE, do.cache=FALSE),fil_Nasdaq ) # cache in tempdir(), fil)
dput(BatchGetSymbols(tickers = sample(filteredMFunds,220*betaTestCoefficient), first.date = first.date,last.date = last.date, do.parallel = TRUE, do.cache=FALSE),fil_mfunds ) # cache in tempdir(), fil)

fwrite(dget(fil_Nasdaq, keep.source = TRUE)$df.tickers, "200NasdaqSymbols2Years.csv")
fwrite(dget(fil_mfunds, keep.source = TRUE)$df.tickers, "200MFundsSymbols2Years.csv")          

source("sp500.R")

lapply(filteredNasdaq,get_symbols)

holder.a <- lapply(noquote(filteredNasdaq),adjust_OHLC)

adjustOHLC(holder)
head(AAPL)
head(AAPL.a <- adjustOHLC(AAPL))
head(AAPL.uA <- adjustOHLC(AAPL, use.Adjusted=TRUE))