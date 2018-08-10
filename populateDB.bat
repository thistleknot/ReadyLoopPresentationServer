setlocal enableextensions enabledelayedexpansion

mkdir c:\test\
mkdir c:\test\share
mkdir c:\test\share\nasdaq
mkdir c:\test\share\other
mkdir c:\test\share\etf

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a
set waitPeriod=12
echo %waitPeriod%
set PGPASSWORD=1234
set fullFlag=1

set dbName=readyloop
set tableName=nasdaq_facts
setlocal enableextensions enabledelayedexpansion

REM %1 = drop flag, assume 0 (not 1)

set dbName=readyloop
REM set tableName=nasdaq_facts

REM download NASDAQ & Other (DOW and NYSE)
curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqlisted.txt" --stderr -> nasdaqlisted.txt
curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/otherlisted.txt" --stderr -> otherlisted.txt

REM ETF Bonds
curl --silent "https://www.nasdaq.com/investing/etfs/etf-finder-results.aspx?download=Yes" --stderr -> ETFList.csv

	REM symbol list, nothing else.
	call etfnamessymbols.bat
	REM just symbol names with symbol header, should be merged
	xcopy ETFNamesSymbols.csv C:\test\ /y
	more +1 c:\test\ETFNamesSymbols.csv > ETFNamesSymbolsNoHeaderwQuotes.csv

REM remove last line that is a log
	sed -i "$d" nasdaqlisted.txt
	sed -i "$d" otherlisted.txt
	
REM ^^essential for | , escape character stuff
sed 's/^^/"/;s/|/;/g;s/$/"/' nasdaqlisted.txt > removedPipes.txt
sed 's/^^/"/;s/|/;/g;s/$/"/' otherlisted.txt > removedPipes2.txt

REM remove quotes (had a few errors with ,'s in the descriptions for etflist.csv
sed 's/^^/"/;s/"//g;s/$//' removedPipes.txt > c:\test\nasdaqSymbolsMaster.csv
sed 's/^^/"/;s/"//g;s/$//' removedPipes2.txt > c:\test\otherSymbolsMaster.csv


REM remove header, required for downloadDataOther.bat and downloadDataNasdaq.bat and insertBonds.bat
more +1 c:\test\nasdaqSymbolsMaster.csv > c:\test\nasdaqSymbolsNoHeaderFull.csv
more +1 c:\test\otherSymbolsMaster.csv > c:\test\otherSymbolsNoHeaderFull.csv
cut -f 1,2 -d , ETFList.csv > c:\test\ETFListwQuotes.csv
sed 's/^^/"/;s/"//g;s/$//' c:\test\ETFListwQuotes.csv > c:\test\ETFList.csv
REM xcopy ETFList.csv c:\test\ETFList.csv

randomizeSymbolList.bat c:\test\nasdaqSymbolsNoHeaderFull.csv > c:\test\RNG-nasdaqSymbolsNoHeaderFull.csv
randomizeSymbolList.bat c:\test\otherSymbolsNoHeaderFull.csv > c:\test\RNG-otherSymbolsNoHeaderFull.csv

head -n 601 c:\test\RNG-nasdaqSymbolsNoHeaderFull.csv > c:\test\nasdaqSymbolsNoHeader100RNG.csv
head -n 601 c:\test\RNG-otherSymbolsNoHeaderFull.csv > c:\test\otherSymbolsNoHeader100RNG.csv

xcopy c:\test\nasdaqSymbolsNoHeader100RNG.csv c:\test\nasdaqSymbolsNoHeader.csv /y
xcopy c:\test\otherSymbolsNoHeader100RNG.csv c:\test\otherSymbolsNoHeader.csv /y


REM download SP500 Index
echo "test1"
set command="dlsp500.bat ^> SP500.csv"
%command%

echo "test2"
REM rebuild scripts
	REM if %1 equ 1 (
	REM echo drop database if exists %dbName%; create database %dbName%;| psql -U postgres; echo drop table if exists public.%tableName%; | psql -U postgres %dbName%
	REM echo drop table if exists public.nSymbols;| psql -U postgres %dbName%
	REM echo drop table if exists public.oSymbols;| psql -U postgres %dbName%
	REM )
	
REM indice tables

echo "test3"
	echo DROP TABLE eod_indices;| psql -U postgres %dbName%
echo "test4"
	echo CREATE TABLE if not exists eod_indices_Template( symbol character varying(16) COLLATE pg_catalog."default" NOT NULL, date date NOT NULL, open real, high real, low real, close real, adj_close real, volume double precision, CONSTRAINT eod_indicesTemplate_pkey PRIMARY KEY (symbol, date)) WITH (OIDS = FALSE) TABLESPACE pg_default; ALTER TABLE public.eod_indices OWNER to postgres;| psql -U postgres %dbName%
	
		echo CREATE TABLE if not exists eod_indices as select * from eod_indices_Template;| psql -U postgres %dbName%
		
		echo CREATE TABLE if not exists eod_indicesTemp as select * from eod_indices_Template;| psql -U postgres %dbName%
	
		REM for now we're just going to copy from a static file, but the intent is to go through a set of files and download each index from yahoo similar to how I download symbols from alphaadvantage.  I suppose I'll have to do something similar for FRED data.  A bunch of mini subtasks that download their own lists/structures of data (for example, I still only have nasdaq imported atm).
		
		xcopy sp500.csv c:\test\ /y
		
		awk '{print F,$1,$2,$3,$4,$5,$6,$7}' FS=, OFS=, F=SP500TR c:\test\sp500.csv > c:\test\sp500wSymbols.csv
  
		echo copy eod_indicesTemp from 'c:\test\sp500wSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%
		
		echo insert into eod_indices select distinct * from eod_indicesTemp ON CONFLICT DO NOTHING;| psql -U postgres %dbName%	
		
		echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres %dbName%

		REM need to create materialized views
	
		FOR /F "tokens=*" %%a in ('subcurrentdate.bat') do SET currentdate=%%a

		echo drop view v_eod_indices_date_filtered_indice| psql -U postgres %dbName%	
		REM echo CREATE OR REPLACE VIEW v_eod_indices_date_filtered_indice AS SELECT * FROM eod_indices WHERE eod_indices.date ^>= '2012-12-31'::date AND eod_indices.date ^<= '%currentdate%'::date order by date asc; > command.txt
		REM ECHO SELECT * FROM eod_indices WHERE eod_indices.date ^>= '2012-12-31'::date AND eod_indices.date ^<= '%currentdate%'::date ORDER BY DATE ASC; > command.txt
		
		REM set command=returnLine 1 command.txt
		REM %command%|psql -U postgres %dbName%
		REM erase command.txt		
		
		
REM symbol tables

	REM Nasdaq

	echo create table if not exists nSymbolsTemplate (symbol varchar(8), securityName varchar(256), MarketCategory varchar(4),testIssue varchar(4),financialStatus varchar(4),roundLotSize varchar(4),ETF varchar(4), nextShares varchar(4),CONSTRAINT nsymbolsTemplate_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres %dbName%
	
		echo CREATE TABLE if not exists nSymbols as select * from nSymbolsTemplate;| psql -U postgres %dbName%
	
		echo CREATE TABLE if not exists nSymbolsTemp as select * from nSymbolsTemplate;| psql -U postgres %dbName%

		echo copy nSymbolsTemp from 'c:\test\nasdaqSymbols.csv' DELIMITER ';' CSV HEADER;| psql -U postgres %dbName%
		
		echo insert into nSymbols select distinct * from nSymbolsTemp ON CONFLICT DO NOTHING;| psql -U postgres %dbName%	
		
		echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres %dbName%

	REM Other (DOW and NYSE)
	echo CREATE TABLE if not exists oSymbolsTemplate (symbol varchar(8), securityName varchar(256), Exchange varchar(16),CQSSymbol varchar(16),ETF varchar(8),roundLotSize varchar(4),testIssue varchar(4), nasdaqSymbol varchar(8),CONSTRAINT osymbolsTemplate_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres %dbName%
	
		echo CREATE TABLE if not exists oSymbols as select * from oSymbolsTemplate;| psql -U postgres %dbName%
	
		echo CREATE TABLE if not exists oSymbolsTemp as select * from oSymbolsTemplate;| psql -U postgres %dbName%

		echo copy nSymbolsTemp from 'c:\test\otherSymbols.csv' DELIMITER ';' CSV HEADER;| psql -U postgres %dbName%
		
		echo insert into oSymbols select distinct * from oSymbolsTemp ON CONFLICT DO NOTHING;| psql -U postgres %dbName%	
		
		echo ALTER TABLE oSymbols OWNER to postgres;| psql -U postgres %dbName%

	REM Bonds
	echo CREATE TABLE if not exists bSymbolsTemplate (symbol varchar(8), securityName varchar(256),CONSTRAINT bsymbolsTemplate_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres %dbName%
	
		echo CREATE TABLE if not exists bSymbols as select * from bSymbolsTemplate;| psql -U postgres %dbName%
		
			echo CREATE TABLE if not exists bSymbolsTemp as select * from bSymbolsTemplate;| psql -U postgres %dbName%

			echo ALTER TABLE bSymbols OWNER to postgres;| psql -U postgres %dbName%				
			
			echo copy bSymbolsTemp from 'c:\test\ETFList.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

			echo insert into bSymbols select distinct * from bSymbolsTemp ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

			echo drop table bSymbolsTemp;| psql -U postgres %dbName%		

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
						
			echo UPDATE custom_calendar SET prev_trading_day = PTD.ptd FROM (SELECT date, (SELECT MAX(CC.date) FROM custom_calendar CC WHERE CC.trading=1 AND CC.date^<custom_calendar.date) ptd FROM custom_calendar) PTD WHERE custom_calendar.date = PTD.date; > command.txt

			REM OMG it works
			set command=returnLine 1 command.txt
			%command%|psql -U postgres %dbName%
			erase command.txt
			
			REM had to use nulliff 
			REM need to base this on current dates
			rem Note: select * from v_eod_indices_2013_2017 where adjusted_close='0'
			echo Create Materialized View IF NOT EXISTS returnsNasdaq AS SELECT EOD.symbol,EOD.timestamp,EOD.adjusted_close/NULLIF( PREV_EOD.adjusted_close, 0 )-1.0 AS ret FROM v_eod_indices_2013_2017 EOD INNER JOIN custom_calendar CC ON EOD.timestamp=CC.date INNER JOIN v_eod_indices_2013_2017 PREV_EOD ON PREV_EOD.symbol=EOD.symbol AND PREV_EOD.timestamp=CC.prev_trading_day; REFRESH MATERIALIZED VIEW returnsNasdaq WITH DATA;| psql -U postgres %dbName%
			
		REM query: select symbol, AVG(NULLIF(ret,0)) as average from returnsNasdaq group by symbol order by average desc; 
			
			REM exclusions
			REM echo SELECT symbol, 'More than 1% missing' as reason INTO exclusions_2013_2017 FROM %tableName% GROUP BY symbol HAVING count(*)::real/(SELECT COUNT(*) FROM custom_calendar WHERE trading=1 AND date BETWEEN '2012-12-31' AND '2018-07-28')::real^<0.99; > command.txt
			
			REM OMG it works
			set command=returnLine 1 command.txt
			%command%|psql -U postgres %dbName%
			erase command.txt			
			
			echo INSERT INTO exclusions_2013_2017 SELECT DISTINCT symbol, 'Return higher than 100%' as reason FROM returnsNasdaq WHERE ret>1.0; > command.txt
			
			REM OMG it works
			set command=returnLine 1 command.txt
			%command%|psql -U postgres %dbName%
			erase command.txt						
		
			echo create view filtered as SELECT * FROM returnsNasdaq WHERE symbol NOT IN  (SELECT DISTINCT symbol FROM exclusions_2013_2017);| psql -U postgres %dbName%		
		
			echo select symbol, AVG(NULLIF(ret,0)) as average from filtered group by symbol order by average desc;| psql -U postgres %dbName%	

			REM NOCREATEROL throws an error
			echo CREATE USER readyloop WITH LOGIN NOSUPERUSER NOCREATEDB INHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD 'read123'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO readyloop; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readyloop;| psql -U postgres %dbName%	
					
REM create NASDAQ & Other (DOW and NYSE) fact tables
	echo CREATE TABLE IF NOT EXISTS nasdaq_facts_template (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT nasdaq_facts_template_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE nasdaq_facts_template OWNER to postgres; | psql -U postgres %dbName%
	
	echo CREATE TABLE IF NOT EXISTS other_facts_template (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT other_facts_template_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE other_facts_template OWNER to postgres; | psql -U postgres %dbName%
	
	echo CREATE TABLE IF NOT EXISTS other_facts AS select * from other_facts_template;| psql -U postgres %dbName%

REM create Bonds fact table		
	echo CREATE TABLE IF NOT EXISTS bond_facts_template (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,CONSTRAINT bond_facts_template_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE bond_facts_template OWNER to postgres; | psql -U postgres %dbName%
	
	echo CREATE TABLE IF NOT EXISTS bond_facts AS select * from bond_facts_template;| psql -U postgres %dbName%	
	
REM create ETF-Bonds fact table	
	echo CREATE TABLE IF NOT EXISTS public.etf_bond_facts_template (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,CONSTRAINT etf_bond_facts_template_key PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE public.etf_bond_facts_template OWNER to postgres; | psql -U postgres %dbName%
	
	echo CREATE TABLE IF NOT EXISTS etf_bond_facts AS select * from public.etf_bond_facts_template;| psql -U postgres %dbName%
	
REM download data
	
	downloadBonds.bat
		
	downloadDataNasdaq.bat
	
		cd c:\test\share\nasdaq\
	
		checkBad.bat	
	
	downloadDataOther.bat
	
		cd c:\test\share\other\
	
		checkBad.bat
		
	cd c:\Users\user\Documents\alphaAdvantageApi\ReadyLoopPresentationServer
		
	rem insertBonds.bat

REM echo select * from %tableName%;| psql -U postgres %dbName%
REM echo's all symbols
	echo select symbol FROM nSymbols;| psql -U postgres %dbName%
