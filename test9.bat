
for /f "delims=" %%x in ('getCrumb2.bat') do set "crumb=%%x"

echo %crumb%

curl -s --cookie cookie.txt  "https://query1.finance.yahoo.com/v7/finance/download/HDGE?period1=1325404800&period2=1514707200&interval=1d&events=history&crumb=%crumb%"