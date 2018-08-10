@echo off
cut -f 1,1 -d , ETFList.csv > temp.txt
sed -i 's/\"//g' temp.txt > ETFNamesSymbols.txt
erase temp.txt
@echo on