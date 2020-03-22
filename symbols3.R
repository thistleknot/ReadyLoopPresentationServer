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

#rbindlist
library(data.table)

library(quantmod)
#library(anytime)
#library(RCurl)

#mclapply
library(parallel)

#group_split
library(dplyr)

wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqtraded.txt")
wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/mfundslist.txt")
#9 quarters is 5479/8897 61% (60%)
nasdaqTraded <- as.character(head(read.csv("nasdaqtraded.txt",sep="|")$Symbol,-2))
mfunds <- as.character(head(read.csv("nasdaqtraded.txt",sep="|")$Symbol,-2))

#wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/bondslist.txt")
#bonds <- head(read.csv("bondslist.txt",sep="|")$Symbol,-2)

#begin function definitions

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

put_adjusted_into_file <- function(files)
{
  
}

adjusted_list <- function(fil)
{
  #takes list
  #fil <- filteredSymbolsList[[1]][[1]]
  
  source_data <- dget(fil[[1]][[1]], keep.source = TRUE)
  #symbols <- unique(source_data$df.tickers$ticker)
  
  list_source <- group_split(source_data$df.tickers, source_data$df.tickers$ticker)
  symbols <- sort(unique(source_data$df.tickers$ticker))
  
  names(list_source) <- symbols
  names(symbols) <- symbols
  
  colNames= c("Open", "High", "Low", "Close", "Volume", "Adjusted", "Date", "Ticker", "Return.Adjusted", "Return.Closing","Ticker2")
  
  colnames(list_source[[1]][,])
  #x=1
  
  list_source_data <- mclapply(symbols, function (x) {
    setNames(list_source[[x]][,], colNames)
  })
  
  mclapply(symbols, function(x) {
    as.data.frame(adjustOHLC(xts(as.data.frame(list_source_data[[x]][,])[,c("Open","High","Low","Close","Volume","Adjusted")],order.by=as.POSIXct(list_source_data[[x]][,]$Date)), adjust=c("split","dividend"), symbol.name=symbols[x], use.Adjusted=TRUE))
  }) 
  
}

#end function definitions

#how to create objects of these and create functions for them?
marketNames <- c("Nasdaq","Mutual")

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

#each subsequent process is parallel, no need to use mclapply here.
lapply(mylists, FUN=function(x) put_symbols_into_file(fil=x$fil, data=x$data, size=x$size))

#https://stackoverflow.com/questions/20428742/select-first-element-of-nested-list

files <- mclapply(mylists, `[[`, 1)
#using 3 sigma
#nasdaq 61% success rate @8897
#mfunds 76% success rate @250

first.date <- Sys.Date() - 821
last.date <- Sys.Date()

filNasdaq <- c()
filNasdaq <- tempfile()
filmfunds <- c()
filmfunds <- tempfile()

filList <- list(filNasdaq,filmfunds)
numLists <- 1:length(filList)
#Used with filterSymbolsList / join_file_symbols
filteredSymbols <- mclapply(files,filtered_symbols)

#list(filList[[1]],filteredSymbols[[1]])
#pair fil with symbol list
filteredSymbolsList <- mclapply(numLists,join_file_symbols)

#Calls BatchGetSymbols which is parallel, no need to use mclapply
lapply(filteredSymbolsList, FUN=function(x) put_symbols_into_file(fil=x[[1]], data=x[[2]], size=220))

#get's adjusted prices and stores them into a single list, which deviates from the dput separate fil method I was using earlier.
#I need them separate for writing to file

fil_Adjusted_Nasdaq <- c()
fil_Adjusted_Nasdaq <- tempfile()
fil_Adjusted_mfunds <- c()
fil_Adjusted_mfunds <- tempfile()

#nested list
#https://stackoverflow.com/questions/16602173/building-nested-lists-in-r
iter1 <- list(fil_n=fil_Adjusted_Nasdaq,filNasdaq)
iter2 <- list(fil_m=fil_Adjusted_mfunds, filmfunds)
All = c(list(iter1), list(iter2))

num_Adjusted_List <- 1:length(fil_Adjusted_List)

lapply(All, FUN=function(x) put_adjusted_into_file(files=x))

stock_split_adjusted <- mclapply(filteredSymbolsList, FUN=function(x) adjusted_list(fil=x[[1]]))

names(stock_split_adjusted) = marketNames

x=marketNames[1]
stock_split_adjusted_Sample_200_wDates <- mclapply(marketNames,function (x) {
  #Markets
  cbind("Date"=stock_split_adjusted[[x]][,]$Date,stock_split_adjusted[[x]][,])
})

csvNames=list("200NasdaqSymbols2Years.csv","200MFundsSymbols2Years.csv")
csv_list <- mclapply(numLists,join_file_csvNames)
mclapply(csv_list, FUN=function(x) write_subset_csv(fil=x[[1]], name=x[[2]]))

source("sp500.R")