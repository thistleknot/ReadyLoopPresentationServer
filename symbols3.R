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

betaTestCoefficient = .25

#options("download.file.method"="wget")

library(HelpersMG)
library(BatchGetSymbols)
library(future)
library(data.table)
#library(anytime)
#library(RCurl)

wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqtraded.txt")
#9 quarters is 5479/8897 61% (60%)
nasdaqTraded <- head(read.csv("nasdaqtraded.txt",sep="|")$Symbol,-2)

#wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/bondslist.txt")
#bonds <- head(read.csv("bondslist.txt",sep="|")$Symbol,-2)

fil <- c()
fil <- tempfile()
first.date <- Sys.Date() - 821
last.date <- Sys.Date() - 814
future::plan(future::multisession, workers = 4)
#using six sigma
dput(BatchGetSymbols(tickers = sample(nasdaqTraded,770*betaTestCoefficient),
                     do.parallel = TRUE,
                     first.date = first.date,
                     last.date = last.date, 
                     be.quiet = TRUE,
                     #cache results in "can only subtract from "Date" objects"
                     #probably due to parallel
                     do.cache=FALSE),
     fil)

filteredNasdaq <- unique(dget(fil, keep.source = TRUE)$df.tickers$ticker)

first.date <- Sys.Date() - 821
last.date <- Sys.Date()

fil <- c()
fil <- tempfile()

dput(BatchGetSymbols(tickers = sample(filteredNasdaq,220*betaTestCoefficient), first.date = first.date,last.date = last.date, do.parallel = TRUE, do.cache=FALSE),fil ) # cache in tempdir(), fil)

dget(fil, keep.source = TRUE)$df.tickers
fwrite(dget(fil, keep.source = TRUE)$df.tickers, "200NasdaqSymbols2Years.csv")          


