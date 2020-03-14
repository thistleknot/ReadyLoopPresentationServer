library(HelpersMG)

#oil
#metals
#gold GC=F

#crypto

#SYMBOL REPEATS, need to use unique, example IVLU was in both ftp nasdaq files (amex company)

#3618
nasdaq <- read.csv("https://old.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download")$Symbol

#in nasdaq traded
#297
amex <- read.csv("https://old.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download")$Symbol

#amexEOD <- read.csv(file="..\\Downloads\\amex.txt",delimiter="\t")$Symbol

#https://www.portfolioprobe.com/user-area/documentation/portfolio-probe-cookbook/data-basics/read-a-tab-separated-file-into-r/
amexEOD <- read.table("..\\Downloads\\amex.txt",sep="\t", header=TRUE)$Symbol

#in nasdaq traded
#3098
nyse <- read.csv("https://old.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download")$Symbol

wget("ftp://ftp.nasdaqtrader.com/SymbolDirectory/mfundslist.txt")

mfunds <- head(read.csv(file="mfundslist.txt",sep="|"),-2)$Fund.Symbol

#67
bonds <- head(read.csv("ftp://ftp.nasdaqtrader.com/SymbolDirectory/bondslist.txt",sep="|")$Symbol,-2)

nasdaqtraded <- head(read.csv("ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqtraded.txt",sep="|")$Symbol,-2)
#8895 -> nasdaqtraded

nasdaqother <- head(read.csv("ftp://ftp.nasdaqtrader.com/SymbolDirectory/otherlisted.txt",sep="|")$ACT.Symbol,-2)
#5338 nasdaqother

nasdaqFTPSources <- unique(nasdaqtraded,nasdaqother)

#nasdaqother is completely encapsulated in nasdaqtraded
#3554 non nasdaq (nyse + amex?)
setdiff(nasdaqother,nasdaqtraded)

#get rid of amex and symbols which are both amex markets
setdiff(amex,nasdaqtraded)

#https://stackoverflow.com/questions/17598134/compare-two-character-vectors-in-r/17598665
setdiff(nasdaqtraded,nasdaqother)

#what in 1st is not in 2nd
setdiff(nasdaq,nasdaqtraded)
#32

#77
setdiff(amexEOD,nasdaqFTPSources)

#37
setdiff(amex,nasdaqFTPSources)
#37




