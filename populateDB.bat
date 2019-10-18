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
set host=192.168.3.103
set PGPASSWORD=Read1234
set fullFlag=1

set dbName=readyloop
set tableName=nasdaq_facts

REM needed for null string for copy statements
set NULL="null"

REM %1 = drop flag, assume 0 (not 1)

REM download NASDAQ & Other (DOW and NYSE)
curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqlisted.txt" --stderr -> nasdaqlisted.txt
curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/otherlisted.txt" --stderr -> otherlisted.txt

REM ETF Bonds
curl --silent "https://www.nasdaq.com/investing/etfs/etf-finder-results.aspx?download=Yes" --stderr -> ETFList.csv

	REM encapsulate q quotes
	cut -f 1,2 -d , ETFList.csv > c:\test\ETFListwQuotes.csv

REM remove last line that is a log
	sed -i "$d" nasdaqlisted.txt
	sed -i "$d" otherlisted.txt
	
REM ^^essential for | , escape character stuff
	sed 's/^^/"/;s/|/;/g;s/$/"/' nasdaqlisted.txt > removedPipes.txt
	sed 's/^^/"/;s/|/;/g;s/$/"/' otherlisted.txt > removedPipes2.txt
	
	REM remove quotes
	sed 's/^^/"/;s/"//g;s/$//' removedPipes.txt > c:\test\nasdaqSymbolsMaster.csv
	sed 's/^^/"/;s/"//g;s/$//' removedPipes2.txt > c:\test\otherSymbolsMaster.csv	
	sed 's/^^/"/;s/"//g;s/$//' c:\test\ETFListwQuotes.csv > c:\test\ETFList.csv	

REM remove header, required for downloadDataOther.bat and downloadDataNasdaq.bat and insertBonds.bat
	more +1 c:\test\nasdaqSymbolsMaster.csv > c:\test\nasdaqSymbolsNoHeaderFull.csv
	more +1 c:\test\otherSymbolsMaster.csv > c:\test\otherSymbolsNoHeaderFull.csv
	more +1 c:\test\ETFNamesSymbols.csv > c:\test\ETFNamesSymbolsNoHeaderFull.csv

REM symbol list, nothing else.
	cut -f 1 -d ; c:\test\nasdaqSymbolsNoHeaderFull.csv > c:\test\nasdaqNamesSymbols.csv
	cut -f 1 -d , c:\test\ETFNamesSymbolsNoHeaderFull.csv > c:\test\ETFNamesSymbols.csv
	cut -f 1 -d ; c:\test\otherSymbolsNoHeaderFull.csv > c:\test\otherNamesSymbols.csv
	
REM xcopy ETFList.csv c:\test\ETFList.csv

	cmd.exe /c randomizeSymbolList.bat c:\test\nasdaqSymbolsNoHeaderFull.csv c:\test\RNG-nasdaqSymbolsNoHeaderFull.csv

	cmd.exe /c randomizeSymbolList.bat c:\test\otherSymbolsNoHeaderFull.csv c:\test\RNG-otherSymbolsNoHeaderFull.csv
	
	cmd.exe /c randomizeSymbolList.bat c:\test\ETFNamesSymbolsNoHeaderFull.csv c:\test\RNG-ETFNamesSymbolsNoHeaderFull.csv
	
head -n 400 c:\test\RNG-nasdaqSymbolsNoHeaderFull.csv > c:\test\nasdaqSymbolsNoHeader100RNG.csv
head -n 600 c:\test\RNG-otherSymbolsNoHeaderFull.csv > c:\test\otherSymbolsNoHeader100RNG.csv
head -n 800 c:\test\RNG-ETFNamesSymbolsNoHeaderFull.csv > c:\test\ETFNamesSymbolsNoHeader100RNG.csv

xcopy c:\test\nasdaqSymbolsNoHeader100RNG.csv c:\test\nasdaqSymbolsNoHeader.csv /y
xcopy c:\test\otherSymbolsNoHeader100RNG.csv c:\test\otherSymbolsNoHeader.csv /y
xcopy c:\test\ETFNamesSymbolsNoHeader100RNG.csv c:\test\ETFNamesSymbolsNoHeader.csv /y

REM rebuild scripts
	REM if %1 equ 1 (
	
	echo drop database readyloop; create database readyloop;| psql -U postgres -h %host%
	echo drop table if exists public.nasdaq_facts cascade; | psql -U postgres -h %host% %dbName%
	echo drop table if exists public.other_facts cascade; | psql -U postgres -h %host% %dbName%
	echo drop table if exists public.etf_bond_facts cascade; | psql -U postgres -h %host% %dbName%
	echo drop table if exists public.qs_facts cascade; | psql -U postgres -h %host% %dbName%
	echo drop table if exists public.nSymbols;| psql -U postgres -h %host% %dbName%
	echo drop table if exists public.oSymbols;| psql -U postgres -h %host% %dbName%
	echo drop table if exists public.bSymbols;| psql -U postgres -h %host% %dbName%
	REM )
	
REM symbol tables

	REM Nasdaq

	cmd.exe /c nSymbols.bat
	
	REM Other (DOW and NYSE)
	echo CREATE TABLE if not exists oSymbolsTemplate (symbol varchar(8), securityName varchar(256), Exchange varchar(16),CQSSymbol varchar(16),ETF varchar(8),roundLotSize varchar(4),testIssue varchar(4), nasdaqSymbol varchar(8),CONSTRAINT osymbolsTemplate_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres -h %host% %dbName%
	
		echo drop table if exists oSymbols;| psql -U postgres -h %host% %dbName%	
	
		echo CREATE TABLE if not exists oSymbols as select * from oSymbolsTemplate;| psql -U postgres -h %host% %dbName%
	
		echo CREATE TABLE if not exists oSymbolsTemp as select * from oSymbolsTemplate;| psql -U postgres -h %host% %dbName%

		echo \copy nSymbolsTemp from 'c:\test\otherSymbols.csv' DELIMITER ';' CSV HEADER;| psql -U postgres -h %host% %dbName%
		
		echo insert into oSymbols select distinct * from oSymbolsTemp ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%	
		
		echo ALTER TABLE oSymbols OWNER to postgres;| psql -U postgres -h %host% %dbName%

	REM Bonds
	echo CREATE TABLE if not exists bSymbolsTemplate (symbol varchar(8), securityName varchar(256),CONSTRAINT bsymbolsTemplate_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres -h %host% %dbName%
	
		echo CREATE TABLE if not exists bSymbols as select * from bSymbolsTemplate;| psql -U postgres -h %host% %dbName%
		
			echo CREATE TABLE if not exists bSymbolsTemp as select * from bSymbolsTemplate;| psql -U postgres -h %host% %dbName%

			echo ALTER TABLE bSymbols OWNER to postgres;| psql -U postgres -h %host% %dbName%				
			
			echo \copy bSymbolsTemp from 'c:\test\ETFList.csv' DELIMITER ',' CSV HEADER;| psql -U postgres -h %host% %dbName%

			echo insert into bSymbols select distinct * from bSymbolsTemp ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%

			echo drop table bSymbolsTemp;| psql -U postgres -h %host% %dbName%		

	REM calendar
	
			cmd.exe /c calendar.bat
			
REM create NASDAQ & Other (DOW and NYSE) fact tables
	echo CREATE TABLE IF NOT EXISTS nasdaq_facts_template (symbol varchar(8), timestamp date, open real null, high real null,low real null,close real null,adjusted_close real null,volume real null,dividend_amount real null,split_coefficient real null,CONSTRAINT nasdaq_facts_template_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default; ALTER TABLE nasdaq_facts_template OWNER to postgres; | psql -U postgres -h %host% %dbName%
	
	echo CREATE TABLE IF NOT EXISTS other_facts_template (symbol varchar(8), timestamp date, open real null, high real null,low real null,close real null,adjusted_close real null,volume real null,dividend_amount real null,split_coefficient real null,CONSTRAINT other_facts_template_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default; ALTER TABLE other_facts_template OWNER to postgres; | psql -U postgres -h %host% %dbName%
	
	echo CREATE TABLE IF NOT EXISTS other_facts AS select * from other_facts_template;| psql -U postgres -h %host% %dbName%

REM create ETF-Bonds fact table	
	echo CREATE TABLE IF NOT EXISTS public.etf_bond_facts_template (symbol varchar(8), timestamp date, open real null, high real null, low real null, close real null, adjusted_close real null, volume real null, CONSTRAINT etf_bond_facts_template_key PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default; ALTER TABLE public.etf_bond_facts_template OWNER to postgres; | psql -U postgres -h %host% %dbName%
	
	echo CREATE TABLE IF NOT EXISTS etf_bond_facts AS select * from public.etf_bond_facts_template;| psql -U postgres -h %host% %dbName%

	cmd.exe /c insertQs.bat
	
	REM echo select count (symbol) from mv_qs_symbols;| psql -U postgres -h %host% readyloop > qs_count.txt
	REM FOR /F "tokens=*" %%a in ('call returnline.bat 3 qs_count.txt') do SET numQSSymbols=%%a
	REM echo %numQSSymbols%
	
	
REM download data

	cmd.exe /c insertIndice.bat
	
	Rem need to run outside
	
	echo drop table if exists etf_bond_facts cascade;| psql -U postgres -h %host% %dbName%
	
	erase c:\test\share\etf\*.csv /q
	
	cmd.exe /c insertQs.bat
	
	REM cmd.exe /c downloadBonds.bat
	
		cd c:\test\share\etf\
		
		cmd.exe /c checkBadETF.bat
		
		echo f|xcopy reruns.txt c:\test\share\OtherReRuns.txt /y
		
		cd c:\users\user\Documents\alphaAdvantageApi\ReadyLoopPresentationServer\
		
		cmd.exe /c insertBonds.bat
	
	REM need to run outside.
	
	echo drop table if exists nasdaq_facts cascade;|psql -U postgres -h %host% %dbName%	
	
	erase c:\test\share\nasdaq\*.csv /q
	erase c:\test\share\nasdaq\reruns.txt
	erase c:\test\share\nasdaq\nasdaqDirList.txt
	erase c:\test\share\nasdaq\nasdaqList
	
		xcopy diffComparison c:\test\share\ /y
		xcopy diffComparisonETF c:\test\share\ /y
	
		REM cmd.exe /c downloadDataNasdaq.bat
	
		cd c:\users\user\Documents\alphaAdvantageApi\ReadyLoopPresentationServer\

		cmd.exe /c nasdaqCleanup.bat
		
		REM cmd.exe /c insertNasdaq.bat		

	Rem can't run inside because it will drop when I wish to rerun!
	echo drop table if exists other_facts cascade;|psql -U postgres -h %host% %dbName%	
		
	erase c:\test\share\other\*.csv /q
	erase c:\test\share\other\reruns.txt
	erase c:\test\share\other\otherDirList.txt
	erase c:\test\share\other\otherList
	
		REM cmd.exe /c downloadDataOther.bat
		
		cd c:\users\user\Documents\alphaAdvantageApi\ReadyLoopPresentationServer\
		
		cmd.exe /c otherCleanup.bat
			
		cmd.exe /c insertOther.bat

REM echo select * from %tableName%;| psql -U postgres -h %host% %dbName%
REM echo's all symbols
	echo select symbol FROM nSymbols;| psql -U postgres -h %host% %dbName%
