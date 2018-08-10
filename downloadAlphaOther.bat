setlocal enableextensions enabledelayedexpansion

set fullFlag=1

REM FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
REM FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
REM FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a
REM FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\otherSymbolsNoHeader.csv') do SET numOtherSymbols=%%a
REM set waitPeriod=12
REM echo %waitPeriod%
REM set PGPASSWORD=1234
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


FOR /F "tokens=*" %%a in ('returnLine.bat 1 useragent.txt') do SET useragent=%%a

REM if %fullFlag%==1 (curl -insecure -x %1 -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&outputsize=full&apikey=%3&datatype=csv" -o c:\test\share\other\O-%2.csv)
REM if NOT %fullFlag%==1 (curl -insecure -x %1 -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&apikey=%3&datatype=csv" -o c:\test\share\other\O-%2.csv)

if %fullFlag%==1 (curl -x %1 -L -u %useragent% "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&outputsize=full&apikey=%3&datatype=csv" -o c:\test\share\other\O-%2.csv)
if NOT %fullFlag%==1 (curl -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&apikey=%3&datatype=csv" -o c:\test\share\other\O-%2.csv)


REM adds symbol to front of columns
REM awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%2 c:\test\share\other\O-%2.csv > c:\test\share\other\O-%2wSymbols.csv
	
REM echo drop table temp_table%2;| psql -U postgres %dbName%

REM echo create table temp_table%2 as table temp_table;|psql -U postgres %dbName%

REM echo copy temp_table%2 from 'c:\test\%2wSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

REM echo insert into %tableName% select distinct * from temp_table%2 ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

REM echo drop table temp_table%2;| psql -U postgres %dbName%
	
timeout /t 4

exit