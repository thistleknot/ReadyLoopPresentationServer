@echo off
cut -f 1,1 -d , ETFList.csv > temp.txt
sed -i 's/\"//g' temp.txt
move temp.txt ETFNamesSymbols.csv
@echo on