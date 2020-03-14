#oil
#metals
#crypto

nasdaq <- read.csv("https://old.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download")$Symbol

amex <- read.csv("https://old.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download")$Symbol

nyse <- read.csv("https://old.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download")$Symbol

mfunds <- head(read.csv("ftp://ftp.nasdaqtrader.com/SymbolDirectory/mfundslist.txt",sep="|")$Symbol,-2)

bonds <- head(read.csv("ftp://ftp.nasdaqtrader.com/SymbolDirectory/bondslist.txt",sep="|")$Symbol,-2)
