@echo off
cut -f 1,1 -d , ETFList.csv > temp.txt
sed -i 's/\"//g' temp.txt
xcopy temp.txt ETFNamesSymbols.csv /y
erase temp.txt
@echo on