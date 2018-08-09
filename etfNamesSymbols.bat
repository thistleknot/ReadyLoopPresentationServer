cut -f 1,2 -d , ETFList.csv > temp.txt
sed -i 's/\"//g' temp.txt
move temp.txt ETFNamesSymbols.csv