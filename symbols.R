library(HelpersMG)
library(BatchGetSymbols)

wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/mfundslist.txt")

mfunds <- head(read.csv(file="mfundslist.txt",sep="|"),-2)$Fund.Symbol

#67
bonds <- head(read.csv("ftp://ftp.nasdaqtrader.com/SymbolDirectory/bondslist.txt",sep="|")$Symbol,-2)

nasdaqtraded <- head(read.csv("ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqtraded.txt",sep="|")$Symbol,-2)
#8895 -> nasdaqtraded

first.date <- Sys.Date() - 60
last.date <- Sys.Date()
freq.data <- 'daily'

l.out <- BatchGetSymbols(tickers = bonds, 
                         first.date = first.date,
                         last.date = last.date, 
                         #freq.data = freq.data,
                         cache.folder = file.path(tempdir(), 
                                                  'BGS_Cache') ) # cache in tempdir()