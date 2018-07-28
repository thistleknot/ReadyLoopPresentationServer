call vars.bat

set /a count = 1

REM doesn't work in for loop, temp table holds symbol data before on distinct merge is performed over master table
echo CREATE TABLE temp_table (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT temp_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE temp_table OWNER to postgres; | psql -U postgres %dbName%

for /F "delims=;" %%a in (c:\test\nasdaqSymbolsNoHeader.csv) do (

	echo %%a

	REM key counter
	echo !count!
	FOR /F "tokens=*" %%b in ('returnLine.bat !count! apiKey.txt') do SET APIKEY=%%b
	FOR /F "tokens=*" %%b in ('returnLine.bat !count! proxyList.txt') do SET PROXY=%%b
	echo !APIKEY!
	echo !PROXY!
	echo %%a

	set t1=!TIME!
	echo !t1!

	REM query to see where left off (select distinct symbol from dadjclose order by symbol;)
	
	REM curl -x !PROXY! -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%%a&outputsize=full&apikey=!APIKEY!&datatype=csv" -o c:\test\%%a.csv;
	
	curl -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%%a&outputsize=full&apikey=!APIKEY!&datatype=csv" -o c:\test\%%a.csv;
	
	awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%%a c:\test\%%a.csv > c:\test\%%awSymbols.csv
	
	echo drop table temp_table2;| psql -U postgres %dbName%
	
	echo create table temp_table2 as table temp_table;|psql -U postgres %dbName%

	echo copy temp_table2 from 'c:\test\%%awSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%
	
	echo insert into %tableName% select distinct * from temp_table2 ON CONFLICT DO NOTHING;| psql -U postgres %dbName%
	
	echo drop table temp_table2;| psql -U postgres %dbName%
	
	set t2=!TIME!
	echo !t2!
	
	call tdiff.cmd !t1! !t2! > timeDiff.txt
	
	FOR /F "tokens=*" %%b in ('returnLine.bat 3 timeDiff.txt') do SET timeDiff=%%b
	
	echo !timeDiff!

	set startcsec=!timeDiff:~9,2!
	set startsecs=!timeDiff:~6,2!
	
	echo !startsecs!
	
	set /a seconds=!startsecs!
	
	SET noZerosSeconds=!seconds:0=!
	
	echo !noZerosSeconds!
	
	set /a noZeroSecondsMinus12=12-!noZerosSeconds!	

	if !count! == %numKeys% (set /a count = 0)
	if not !count! == %numKeys% set /a count += 1

 	if !noZerosSeconds! GTR 12 (timeout /t 0)
	
	if !noZerosSeconds! LSS 12 (timeout /t !noZeroSecondsMinus12!)
	
)

echo drop table temp_table;| psql -U postgres %dbName%
endlocal

:increaseby1
set /a "count+=1"