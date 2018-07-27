set PGPASSWORD=|type psqlPW.txt
setlocal enableextensions enabledelayedexpansion
REM set PGPASSWORD=1234
REM findstr /R /N "^" apikey.txt| find /C ":" > lines.txt
REM sed -i "$d" lines.txt
REM set lines=|type lines.txt
REM Thank you: https://stackoverflow.com/questions/6359820/how-to-set-commands-output-as-a-variable-in-a-batch-file
FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('returnLine.bat %numKeys% apiKey.txt') do SET APIKEY=%%a
rem set numKeys=|returnNumLines.bat apiKey.txt
REM set APIKEY=|type apikey.txt

set dbName=somedb
set tableName=ur_table

REM counter
REM set /A i=0

REM doesn't work in for loop, temp table holds symbol data before on distinct merge is performed over master table
echo CREATE TABLE temp_table (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT temp_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE temp_table OWNER to postgres; | psql -U postgres %dbName%

REM prints each entry
for /F "delims=;" %%a in (c:\test\nasdaqSymbolsNoHeader.csv) do (
	
	curl --silent "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%%a&outputsize=full&apikey=%APIKEY%&datatype=csv" --stderr -> c:\test\%%a.csv;

	awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%%a c:\test\%%a.csv > c:\test\%%awSymbols.csv
	
	echo drop table temp_table2;| psql -U postgres somedb
	
	echo create table temp_table2 as table temp_table;|psql -U postgres somedb

	echo copy temp_table2 from 'c:\test\%%awSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres somedb
	
	echo insert into ur_table select distinct * from temp_table2 ON CONFLICT DO NOTHING;| psql -U postgres somedb
	
	echo drop table temp_table2;| psql -U postgres somedb

	REM if %waitFlag% equ true Sleep '11';
	timeout 12
	
	
)

echo drop table temp_table;| psql -U postgres somedb