@echo off
cut -f 1 -d "," ETFList.csv > etfSymbolswQuotes.txt
tail -n +2 etfSymbolswQuotes.txt > etfSymbolswQuotesNoHeader.txt
sed 's/\"//g' etfSymbolswQuotesNoHeader.txt > etfSymbolsNoQuotesNoHeader.txt
echo on