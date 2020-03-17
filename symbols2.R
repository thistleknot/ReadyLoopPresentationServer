library(HelpersMG)
#library(BatchGetSymbols)
library(quantmod)
options("download.file.method"="curl")

batch_get_symbols <- function(x) {
  getSymbols(x, src=("FRED"), return.class = "xts",from = first.date, to = last.date,auto.assign = TRUE)
}
s
View(getSymbols("GOOG", src=("yahoo"),from = first.date, to = last.date))
#wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/mfundslist.txt")

#mfunds <- head(read.csv(file="mfundslist.txt",sep="|"),-2)$Fund.Symbol

#due to way read.csv uses libcurl.so.3 that is not present in libcurl.so.4 calls... and libcurl4.  I have to use wget (2 commands) vs supplying the ftp directly
#throws "internet routines cannot be loaded"
#67
wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/bondslist.txt")
bonds <- head(read.csv("bondslist.txt",sep="|")$Symbol,-2)

wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqtraded.txt")
nasdaqtraded <- head(read.csv("nasdaqtraded.txt",sep="|")$Symbol,-2)
#8895 -> nasdaqtraded

first.date <- Sys.Date() - 60
last.date <- Sys.Date()
freq.data <- 'daily'

fil <- tempfile()
tickers <- c('FB','MMM','PETR4.SA','abcdef')

#View(tickers)
#View(nasdaqtraded)
#lapply(tickers,batch_get_symbols)
dput(lapply(tickers,batch_get_symbols),fil)
#dput(BatchGetSymbols(tickers = nasdaqtraded, first.date = first.date,last.date = last.date, cache.folder = file.path(tempdir(), 'BGS_Cache') ) # cache in tempdir(), fil)
