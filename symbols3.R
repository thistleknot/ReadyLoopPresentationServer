if (!require(BatchGetSymbols)) install.packages('BatchGetSymbols')

library(HelpersMG)
library(BatchGetSymbols)

# set dates
first.date <- Sys.Date() - 821
last.date <- Sys.Date() - 814
freq.data <- 'daily'
# set tickers
wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqtraded.txt")
nasdaqTraded <- head(read.csv("nasdaqtraded.txt",sep="|")$Symbol,-2)

wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/bondslist.txt")
bonds <- head(read.csv("bondslist.txt",sep="|")$Symbol,-2)

tickers <- c('FB','MMM','PETR4.SA','abcdef')
fil <- c()
fil <- tempfile()

dput(BatchGetSymbols(tickers = nasdaqTraded, first.date = first.date,last.date = last.date, cache.folder = file.path(tempdir()) ),fil ) # cache in tempdir(), fil)

#l.out <- BatchGetSymbols(tickers = tickers, 
#                         first.date = first.date,
#                         last.date = last.date, 
                         #freq.data = freq.data,
#                         cache.folder = file.path(tempdir(), 
#                                                  'BGS_Cache') ) # cache in tempdir()

filtered <- unique(dget(fil, keep.source = TRUE)$df.tickers$ticker)

#25%
len(filtered)

first.date <- Sys.Date() - 821
last.date <- Sys.Date()

fil <- c()
fil <- tempfile()

dput(BatchGetSymbols(tickers = filtered, first.date = first.date,last.date = last.date, cache.folder = file.path(tempdir()) ),fil ) # cache in tempdir(), fil)

