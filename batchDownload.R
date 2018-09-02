library(BatchGetSymbols)

tickers <- as.data.frame(read.csv("c:/test/nasdaqSymbolsListNoHeaders.csv",header = FALSE))

first.date <- Sys.Date()-365
last.date <- Sys.Date()

l.out <- BatchGetSymbols(tickers = as.character(tickers$V1),
                         first.date = first.date,
                         last.date = last.date)

print(l.out$df.control)
print(l.out$df.tickers)
View(df)