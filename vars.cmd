setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a
set waitPeriod=12
echo %waitPeriod%
set PGPASSWORD=1234

set dbName=readyloop
set tableName=dadjclose