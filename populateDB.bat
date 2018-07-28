REM vars.bat
setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a
set waitPeriod=12
echo %waitPeriod%
set PGPASSWORD=1234

set dbName=readyloop
set tableName=dadjclose

REM download symbols
curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqlisted.txt" --stderr -> nasdaqlisted.txt
curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/otherlisted.txt" --stderr -> otherlisted.txt

REM remove last line that is a log
	sed -i "$d" nasdaqlisted.txt
	sed -i "$d" otherlisted.txt

REM ^^essential for | , escape character stuff
sed 's/^^/"/;s/|/;/g;s/$/"/' nasdaqlisted.txt > removedPipes.txt
sed 's/^^/"/;s/|/;/g;s/$/"/' otherlisted.txt > removedPipes2.txt

REM remove quotes
sed 's/^^/"/;s/"//g;s/$//' removedPipes.txt > c:\test\nasdaqSymbols.csv
sed 's/^^/"/;s/"//g;s/$//' removedPipes2.txt > c:\test\otherSymbols.csv

echo drop table if exists public.nSymbols;| psql -U postgres %dbName%
echo drop table if exists public.oSymbols;| psql -U postgres %dbName%

REM rebuild scripts
	echo drop database if exists %dbName%; create database %dbName%;| psql -U postgres
	echo drop table if exists public.%tableName%; | psql -U postgres %dbName%
	
REM symbol tables
	echo CREATE TABLE nSymbols (symbol varchar(8), securityName varchar(256), MarketCategory varchar(4),testIssue varchar(4),financialStatus varchar(4),roundLotSize varchar(4),ETF varchar(4), nextShares varchar(4),CONSTRAINT nsymbols_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres %dbName%

	echo CREATE TABLE oSymbols (symbol varchar(8), securityName varchar(256), Exchange varchar(16),CQSSymbol varchar(16),ETF varchar(8),roundLotSize varchar(4),testIssue varchar(4), nasdaqSymbol varchar(8),CONSTRAINT osymbols_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres %dbName%
	
	echo ALTER TABLE public.nSymbols OWNER to postgres;| psql -U postgres %dbName%

	echo ALTER TABLE public.oSymbols OWNER to postgres;| psql -U postgres %dbName%

	echo COPY nSymbols(symbol,securityName,MarketCategory,testIssue,financialStatus,roundLotSize,ETF,nextShares) FROM 'c:\test\nasdaqSymbols.csv' DELIMITER ';' CSV HEADER;| psql -U postgres %dbName%

	echo COPY oSymbols(symbol,securityName,Exchange,CQSSymbol,ETF,roundLotSize,testIssue,nasdaqSymbol) FROM 'c:\test\otherSymbols.csv' DELIMITER ';' CSV HEADER;| psql -U postgres %dbName%	

	REM calendar
	
			echo CREATE TABLE public.custom_calendarTemplate(date date NOT NULL,y bigint,m bigint,d bigint, dow character varying(3) COLLATE pg_catalog."default", trading smallint, CONSTRAINT custom_calendarTemplate_pkey PRIMARY KEY (date)) WITH (OIDS = FALSE) TABLESPACE pg_default; ALTER TABLE public.custom_calendarTemplate OWNER to postgres;| psql -U postgres %dbName%	
		
			echo drop table temp_table2;| psql -U postgres %dbName%	
				
			echo create table temp_table2 as table  public.custom_calendarTemplate;|psql -U postgres %dbName%	
				
			REM manually created file
			REM atm based on nasdaq holidays as found here: http://markets.on.nytimes.com/research/markets/holidays/holidays.asp?display=all
			xcopy tradingDays.csv c:\test\ /y
				
			echo copy temp_table2 from 'c:\test\tradingDays.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%	
				
			echo insert into public.custom_calendar select distinct * from temp_table2 ON CONFLICT DO NOTHING;| psql -U postgres %dbName%	
				
			echo drop table temp_table2;| psql -U postgres %dbName%	
			
			REM add EOM and Trading Day
			
			echo ALTER TABLE public.custom_calendar ADD COLUMN eom smallint;| psql -U postgres %dbName%	

			echo ALTER TABLE public.custom_calendar ADD COLUMN prev_trading_day date;| psql -U postgres %dbName%	
			
			REM EOM Flag
			echo UPDATE custom_calendar SET eom = EOMI.endofm FROM (SELECT CC.date,CASE WHEN EOM.y IS NULL THEN 0 ELSE 1 END endofm FROM custom_calendar CC LEFT JOIN (SELECT y,m,MAX(d) lastd FROM custom_calendar WHERE trading=1 GROUP by y,m) EOM ON CC.y=EOM.y AND CC.m=EOM.m AND CC.d=EOM.lastd) EOMI WHERE custom_calendar.date = EOMI.date;| psql -U postgres %dbName%
			
			set lessThan=|printf '\74'
			REM Prior Trading Day
			REM has to be ran manually!
			
			echo UPDATE custom_calendar SET prev_trading_day = PTD.ptd FROM (SELECT date, (SELECT MAX(CC.date) FROM custom_calendar CC WHERE CC.trading=1 AND CC.date^<custom_calendar.date) ptd FROM custom_calendar) PTD WHERE custom_calendar.date = PTD.date; > command.txt

			REM OMG it works
			set command=returnLine 1 command.txt
			%command%|psql -U postgres %dbName%
			
	
		
REM required for parsedata.bat
	more +1 c:\test\nasdaqSymbols.csv > c:\test\nasdaqSymbolsNoHeader.csv
	more +1 c:\test\nasdaqSymbols.csv > c:\test\otherSymbolsNoHeader.csv

REM create fact table	
	echo CREATE TABLE IF NOT EXISTS public.%tableName% (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE public.%tableName% OWNER to postgres; | psql -U postgres %dbName%

REM download data
	parseData.bat

REM echo select * from %tableName%;| psql -U postgres %dbName%
REM echo's all symbols
	echo select symbol FROM nSymbols;| psql -U postgres %dbName%
