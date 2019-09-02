REM @echo off
setlocal enableextensions enabledelayedexpansion

sel fullFlag=1

REM FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
REM FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
REM FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a
REM FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\otherSymbolsNoHeader.csv') do SET numOtherSymbols=%%a
REM set waitPeriod=12
REM echo %waitPeriod%
REM set PGPASSWORD=Read1234
REM set fullFlag=1

REM set dbName=readyloop
REM set tableName=nasdaq_facts
REM @echo on

REM proxy
echo %1

REM symbol
echo %2

REM Key
echo %3

REM if %fullFlag%==1 (curl -x %1 -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&outputsize=full&apikey=%3&datatype=csv" -o c:\test\share\nasdaq\NS-%2.csv)
REM if %fullFlag%==1 (curl -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&outputsize=full&apikey=%3&datatype=csv" -o c:\test\share\nasdaq\NS-%2.csv)
curl -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&outputsize=full&apikey=%3&datatype=csv" -o c:\test\share\nasdaq\NS-%2.csv
REM if NOT %fullFlag%==1 (curl -x %1 -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&apikey=%3&datatype=csv" -o c:\test\share\nasdaq\NS-%2.csv)
REM if NOT %fullFlag%==1 (curl -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&apikey=%3&datatype=csv" -o c:\test\share\nasdaq\NS-%2.csv)

REM adds symbol to front of columns
REM awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%2 c:\test\%2.csv > c:\test\share\nasdaq\NS-%2wSymbols.csv
	
REM echo drop table temp_table%2;| psql -U postgres -h %host% %dbName%

REM echo create table temp_table%2 as table temp_table;|psql -U postgres -h %host% %dbName%	

REM echo \copy temp_table%2 from 'c:\test\%2wSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres -h %host% %dbName%

REM echo insert into %tableName% select distinct * from temp_table%2 ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%

REM echo drop table temp_table%2;| psql -U postgres -h %host% %dbName%
	
REM timeout /t 1

exit