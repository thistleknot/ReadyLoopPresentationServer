
set name=MSFT
set PGPASSWORD=1234
set APIKEY=|type apikey.txt
set dbName=somedb
set tableName=ur_table

curl --silent "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=MSFT&outputsize=full&apikey=%APIKEY%&datatype=csv" --stderr -> %name%.csv

curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqlisted.txt" --stderr -> nasdaqlisted.txt

xcopy %name%.csv c:\test\ /y

REM last line

sed -i "$d" nasdaqlisted.txt

REM ^^essential for |
sed 's/^^/"/;s/|/;/g;s/$/"/' nasdaqlisted.txt > removedPipes.txt

sed 's/^^/"/;s/"//g;s/$//' removedPipes.txt > c:\test\nasdaqSymbols.csv
erase nasdaqlisted.txt
erase removedPipes.txt

echo drop database if exists nasdaqSymbols; create database nasdaqsymbols;| psql -U postgres

echo drop table if exists public.nSymbols;| psql -U postgres nasdaqsymbols

REM Symbol|Security Name|Market Category|Test Issue|Financial Status|Round Lot Size|ETF|NextShares

echo CREATE TABLE nSymbols (symbol varchar(8), securityName varchar(256), MarketCategory varchar(4),testIssue varchar(4),financialStatus varchar(4),roundLotSize varchar(4),ETF varchar(4), nextShares varchar(4),CONSTRAINT nsymbols_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres nasdaqsymbols

echo ALTER TABLE public.nSymbols OWNER to postgres;| psql -U postgres nasdaqsymbols

REM symbol,securityName,MarketCategory,testIssue,financialStatus,roundLotSize,ETF,nextShares

echo COPY nSymbols(symbol,securityName,MarketCategory,testIssue,financialStatus,roundLotSize,ETF,nextShares) FROM 'c:\test\nasdaqSymbols.csv' DELIMITER ';' CSV HEADER;| psql -U postgres nasdaqsymbols

echo drop database if exists %dbName%; create database %dbName%;| psql -U postgres
echo drop table if exists public.%tableName%; CREATE TABLE public.%tableName% (timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE public.%tableName% OWNER to postgres; COPY %tableName%(timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient) FROM 'c:\test\%name%.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

echo ALTER TABLE %tableName% ADD COLUMN symbol varchar(8) DEFAULT '%name%';| psql -U postgres %dbName%

echo ALTER TABLE %tableName% DROP CONSTRAINT timestamp_pkey;| psql -U postgres %dbName%
echo ALTER TABLE %tableName% ADD CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp,symbol);| psql -U postgres %dbName%

erase output.txt
echo select * from %tableName%;| psql -U postgres %dbName% > output.txt
notepad output.txt

