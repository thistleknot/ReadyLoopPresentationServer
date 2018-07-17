
set name=MSFT
set PGPASSWORD=1234
set APIKEY=|type apikey.txt
set dbName=somedb
set tableName=ur_table

curl --silent "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=MSFT&outputsize=full&apikey=%APIKEY%&datatype=csv" --stderr -> %name%.csv

xcopy %name%.csv c:\test\ /y

echo drop database if exists %dbName%; create database %dbName%;| psql -U postgres
echo drop table if exists public.%tableName%; CREATE TABLE public.%tableName% (timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE public.%tableName% OWNER to postgres; COPY %tableName%(timestamp,open,high,low,close,adjusted_close,volume,dividend_amount,split_coefficient) FROM 'c:\test\%name%.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

echo ALTER TABLE %tableName% ADD COLUMN symbol varchar(8) DEFAULT '%name%';| psql -U postgres %dbName%

echo ALTER TABLE %tableName% DROP CONSTRAINT timestamp_pkey;| psql -U postgres %dbName%
echo ALTER TABLE %tableName% ADD CONSTRAINT timestamp_pkey PRIMARY KEY (timestamp,symbol);| psql -U postgres %dbName%

erase output.txt
echo select * from %tableName%;| psql -U postgres %dbName% > output.txt
notepad output.txt

