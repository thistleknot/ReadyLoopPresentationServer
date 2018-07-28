echo CREATE TABLE temp_table (symbol varchar(8), timestamp date, open real, high real,low real,close real,adjusted_close real,volume real,dividend_amount real,split_coefficient real,CONSTRAINT temp_pkey PRIMARY KEY (timestamp,symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;ALTER TABLE temp_table OWNER to postgres; | psql -U postgres %dbName%

curl -x %1 -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&outputsize=full&apikey=%3" -o c:\test\%2.csv
awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%2 c:\test\%2.csv > c:\test\%2wSymbols.csv
	
echo drop table temp_table2;| psql -U postgres %dbName%

echo create table temp_table2 as table temp_table;|psql -U postgres %dbName%

echo copy temp_table2 from 'c:\test\%%awSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

echo insert into %tableName% select distinct * from temp_table2 ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

echo drop table temp_table2;| psql -U postgres %dbName%
	
echo drop table temp_table;| psql -U postgres %dbName%
exit
