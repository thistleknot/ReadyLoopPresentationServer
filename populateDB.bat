set PGPASSWORD=1234
REM findstr /R /N "^" apikey.txt| find /C ":" > lines.txt
REM sed -i "$d" lines.txt
REM set lines=|type lines.txt
REM Thank you: https://stackoverflow.com/questions/6359820/how-to-set-commands-output-as-a-variable-in-a-batch-file
FOR /F "tokens=*" %a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%a
FOR /F "tokens=*" %a in ('returnLine.bat %numKeys%') do SET APIKEY=%a
rem set numKeys=|returnNumLines.bat apiKey.txt
REM set APIKEY=|type apikey.txt

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
