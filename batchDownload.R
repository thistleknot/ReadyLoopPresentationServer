library(BatchGetSymbols)

nasdaq_Tickers <- as.data.frame(read.csv("c:/test/nasdaqNamesSymbols.csv",header = FALSE))
other_Tickers <- as.data.frame(read.csv("c:/test/otherNamesSymbols.csv",header = FALSE))
etf_Tickers <- as.data.frame(read.csv("c:/test/ETFNamesSymbols.csv",header = FALSE))

first.date <- Sys.Date()-365
last.date <- Sys.Date()

nasdaq.out <- BatchGetSymbols(tickers = as.character(nasdaq_Tickers$V1),
                         first.date = first.date,
                         last.date = last.date)

other.out <- BatchGetSymbols(tickers = as.character(other_Tickers$V1),
                              first.date = first.date,
                              last.date = last.date)

etf.out <- BatchGetSymbols(tickers = as.character(etf_Tickers$V1),
                             first.date = first.date,
                             last.date = last.date)


print(nasdaq.out$df.control)
print(nasdaq.out$df.tickers)
View(df)