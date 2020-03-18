if (!require(BatchGetSymbols)) install.packages('BatchGetSymbols')

library(HelpersMG)
library(BatchGetSymbols)
library(future)
library(anytime)

# set dates
first.date <- Sys.Date() - 821
last.date <- Sys.Date() - 814
freq.data <- 'daily'
# set tickers
wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqtraded.txt")
nasdaqTraded <- head(read.csv("nasdaqtraded.txt",sep="|")$Symbol,-2)

wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/bondslist.txt")
bonds <- head(read.csv("bondslist.txt",sep="|")$Symbol,-2)

fil <- c()
fil <- tempfile()
first.date <- Sys.Date() - 821
last.date <- Sys.Date() - 814
future::plan(future::multisession, workers = floor(parallel::detectCores()/2))
dput(BatchGetSymbols(tickers = nasdaqTraded,
                     do.parallel = TRUE,
                     first.date = first.date,
                     last.date = last.date, 
                     be.quiet = TRUE,
                     #cache results in "can only subtract from "Date" objects"
                     #probably due to parallel
                     do.cache=FALSE),
     fil)


filtered <- unique(dget(fil, keep.source = TRUE)$df.tickers$ticker)

#25%
len(filtered)

first.date <- Sys.Date() - 821
last.date <- Sys.Date()

fil <- c()
fil <- tempfile()

dput(BatchGetSymbols(tickers = sample(filtered,200), first.date = first.date,last.date = last.date, do.parallel = TRUE, do.cache=FALSE),fil ) # cache in tempdir(), fil)

fwrite(dget(fil, keep.source = TRUE)$df.tickers, "200Symbols2Years.csv")          


