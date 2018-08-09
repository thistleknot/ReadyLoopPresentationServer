@echo off
setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a
set waitPeriod=12
echo %waitPeriod%
set PGPASSWORD=1234
set fullFlag=1

set dbName=readyloop
set tableName=nasdaq_facts
@echo on

REM proxy
echo %1

REM symbol
echo %2

REM Key
echo %3

if %fullFlag%==1 (curl -x %1 -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&outputsize=full&apikey=%3&datatype=csv" -o c:\test\%2.csv)
if NOT %fullFlag%==1 (curl -x %1 -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&apikey=%3&datatype=csv" -o c:\test\%2.csv)

REM adds symbol to front of columns
awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%2 c:\test\%2.csv > c:\test\%2wSymbols.csv
	
REM echo drop table temp_table%2;| psql -U postgres %dbName%

REM echo create table temp_table%2 as table temp_table;|psql -U postgres %dbName%

REM echo copy temp_table%2 from 'c:\test\%2wSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

REM echo insert into %tableName% select distinct * from temp_table%2 ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

REM echo drop table temp_table%2;| psql -U postgres %dbName%
	
timeout /t 4

exit