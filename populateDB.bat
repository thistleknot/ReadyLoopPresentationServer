set name=MSFT
set PGPASSWORD=1234
set APIKEY=|type apikey.txt
set dbName=somedb
set tableName=ur_table
set pipe=|printf '\174'

curl --silent "ftp://ftp.nasdaqtrader.com/SymbolDirectory/nasdaqlisted.txt" --stderr -> nasdaqlisted.txt

REM remove last line

sed -i "$d" nasdaqlisted.txt

REM ^^essential for |
sed 's/^^/"/;s/|/;/g;s/$/"/' nasdaqlisted.txt > removedPipes.txt

REM remove quotes
sed 's/^^/"/;s/"//g;s/$//' removedPipes.txt > c:\test\nasdaqSymbols.csv
REM sed 's/^^/"/;s/"//g;s/$//' nasdaqlisted.txt > c:\test\nasdaqSymbols.txt

REM erase nasdaqlisted.txt
REM erase removedPipes.txt

REM add symbol

xcopy %name%.csv c:\test\ /y

echo drop database if exists nasdaqSymbols; create database nasdaqsymbols;| psql -U postgres

echo drop table if exists public.nSymbols;| psql -U postgres nasdaqsymbols

REM Symbol|Security Name|Market Category|Test Issue|Financial Status|Round Lot Size|ETF|NextShares

echo CREATE TABLE nSymbols (symbol varchar(8), securityName varchar(256), MarketCategory varchar(4),testIssue varchar(4),financialStatus varchar(4),roundLotSize varchar(4),ETF varchar(4), nextShares varchar(4),CONSTRAINT nsymbols_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres nasdaqsymbols

echo ALTER TABLE public.nSymbols OWNER to postgres;| psql -U postgres nasdaqsymbols

REM symbol,securityName,MarketCategory,testIssue,financialStatus,roundLotSize,ETF,nextShares

echo COPY nSymbols(symbol,securityName,MarketCategory,testIssue,financialStatus,roundLotSize,ETF,nextShares) FROM 'c:\test\nasdaqSymbols.csv' DELIMITER ';' CSV HEADER;| psql -U postgres nasdaqsymbols

REM echo COPY nSymbols(symbol,securityName,MarketCategory,testIssue,financialStatus,roundLotSize,ETF,nextShares) FROM 'c:\test\nasdaqSymbols.txt' CSV HEADER --fields-terminated-by="|";| psql -U postgres nasdaqsymbols

more +1 c:\test\nasdaqSymbols.csv > c:\test\nasdaqSymbolsNoHeader.csv

REM echo select count(symbol) FROM nSymbols;| psql -U postgres nasdaqsymbols > count.txt

REM specific symbol
curl --silent "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=MSFT&outputsize=full&apikey=%APIKEY%&datatype=csv" --stderr -> %name%.csv
awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%name% c:\test\%name%.csv > c:\test\%name%wSymbol.csv

REM for /F "tokens=*" %%A in (c:\test\nasdaqSymbols.csv) do [echo %%A] %%A

echo drop database if exists %dbName%; create database %dbName%;| psql -U postgres
echo drop table if exists public.%tableName%; | psql -U postgres %dbName%

echo CREATE TABLE public.%tableName% (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE public.%tableName% OWNER to postgres; | psql -U postgres %dbName%

REM echo insert into %tableName%(symbol,timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient) FROM 'c:\test\%name%wSymbol.csv' DELIMITER ',' CSV HEADER;psql -U postgres %dbName%

REM COPY %tableName%(timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient) FROM 'c:\test\%name%.csv' DELIMITER ',' CSV HEADER;

echo COPY %tableName%(symbol,timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient) FROM 'c:\test\%name%wSymbol.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

REM CREATE TABLE public.%tableName% (timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE public.%tableName% OWNER to postgres; COPY %tableName%(timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient) FROM 'c:\test\%name%.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

REM prints each entry
for /F "delims=;" %a in (c:\test\nasdaqSymbolsNoHeader.csv) do (
     echo %a
)

echo UPDATE TABLE public.%tableName% (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE public.%tableName% OWNER to postgres; COPY %tableName%(symbol,timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient) FROM 'c:\test\%name%wSymbol.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

REM echo ALTER TABLE %tableName% ADD COLUMN symbol varchar(8) DEFAULT '%name%';| psql -U postgres %dbName%

echo ALTER TABLE %tableName% DROP CONSTRAINT timestamp_pkey;| psql -U postgres %dbName%
echo ALTER TABLE %tableName% ADD CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp,symbol);| psql -U postgres %dbName%

REM echo select * from %tableName%;| psql -U postgres %dbName%
REM echo's all symbols
echo select symbol FROM nSymbols;| psql -U postgres nasdaqsymbols
