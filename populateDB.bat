set PGPASSWORD=|type psqlPW.txt
REM findstr /R /N "^" apikey.txt| find /C ":" > lines.txt
REM sed -i "$d" lines.txt
REM set lines=|type lines.txt
REM Thank you: https://stackoverflow.com/questions/6359820/how-to-set-commands-output-as-a-variable-in-a-batch-file
FOR /F "tokens=*" %a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%a
FOR /F "tokens=*" %a in ('returnLine.bat %numKeys%') do SET APIKEY=%a
rem set numKeys=|returnNumLines.bat apiKey.txt
REM set APIKEY=|type apikey.txt

set dbName=somedb
set tableName=ur_table
set pipe=|printf '\174'

curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqlisted.txt" --stderr -> nasdaqlisted.txt
curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/otherlisted.txt" --stderr -> otherlisted.txt

REM remove last line
sed -i "$d" nasdaqlisted.txt
sed -i "$d" otherlisted.txt

REM ^^essential for | , escape character stuff
sed 's/^^/"/;s/|/;/g;s/$/"/' nasdaqlisted.txt > removedPipes.txt
sed 's/^^/"/;s/|/;/g;s/$/"/' otherlisted.txt > removedPipes2.txt

REM remove quotes
sed 's/^^/"/;s/"//g;s/$//' removedPipes.txt > c:\test\nasdaqSymbols.csv
sed 's/^^/"/;s/"//g;s/$//' removedPipes2.txt > c:\test\otherSymbols.csv

REM rebuild scripts
echo drop database if exists nasdaqsymbols; create database nasdaqsymbols;| psql -U postgres
REM no need for separate db's
REM echo drop database if exists othersymbols; create database othersymbols;| psql -U postgres

echo drop table if exists public.nSymbols;| psql -U postgres nasdaqsymbols
echo drop table if exists public.oSymbols;| psql -U postgres nasdaqsymbols

echo CREATE TABLE nSymbols (symbol varchar(8), securityName varchar(256), MarketCategory varchar(4),testIssue varchar(4),financialStatus varchar(4),roundLotSize varchar(4),ETF varchar(4), nextShares varchar(4),CONSTRAINT nsymbols_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres nasdaqsymbols

echo CREATE TABLE oSymbols (symbol varchar(8), securityName varchar(256), Exchange varchar(16),CQSSymbol varchar(16),ETF varchar(8),roundLotSize varchar(4),testIssue varchar(4), nasdaqSymbol varchar(8),CONSTRAINT osymbols_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres nasdaqsymbols

echo ALTER TABLE public.nSymbols OWNER to postgres;| psql -U postgres nasdaqsymbols

echo ALTER TABLE public.oSymbols OWNER to postgres;| psql -U postgres nasdaqsymbols

echo COPY nSymbols(symbol,securityName,MarketCategory,testIssue,financialStatus,roundLotSize,ETF,nextShares) FROM 'c:\test\nasdaqSymbols.csv' DELIMITER ';' CSV HEADER;| psql -U postgres nasdaqsymbols

echo COPY oSymbols(symbol,securityName,Exchange,CQSSymbol,ETF,roundLotSize,testIssue,nasdaqSymbol) FROM 'c:\test\otherSymbols.csv' DELIMITER ';' CSV HEADER;| psql -U postgres nasdaqsymbols

more +1 c:\test\nasdaqSymbols.csv > c:\test\nasdaqSymbolsNoHeader.csv
more +1 c:\test\nasdaqSymbols.csv > c:\test\otherSymbolsNoHeader.csv

REM rebuild scripts
	REM echo drop database if exists %dbName%; create database %dbName%;| psql -U postgres
	REM echo drop table if exists public.%tableName%; | psql -U postgres %dbName%

echo CREATE TABLE IF NOT EXISTS public.%tableName% (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE public.%tableName% OWNER to postgres; | psql -U postgres %dbName%

parseData.bat

REM echo drop table temp_table;| psql -U postgres somedb

echo COPY %tableName%^(symbol,timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient^) FROM 'c:\test\%awSymbol.csv' DELIMITER ';' CSV HEADER;^| psql -U postgres %dbName%	

echo COPY %tableName%(symbol,timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient) FROM 'c:\test\%awSymbol.csv' DELIMITER ',' CSV HEADER;^| psql -U postgres %dbName%	
	
echo ALTER TABLE %tableName% DROP CONSTRAINT timestamp_pkey;| psql -U postgres %dbName%
echo ALTER TABLE %tableName% ADD CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp,symbol);| psql -U postgres %dbName%

REM echo select * from %tableName%;| psql -U postgres %dbName%
REM echo's all symbols
echo select symbol FROM nSymbols;| psql -U postgres nasdaqsymbols
