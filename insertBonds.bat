REM Called by PopulateDB.bat after bonds have been downloaded.  Creates tables, requires 2 inputs

REM proxy
echo %1

REM symbol
echo %2

REM Key
echo %3

REM adds symbol to front of columns
awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%2 c:\test\%2.csv > c:\test\%2wSymbols.csv
	
echo drop table temp_table%2;| psql -U postgres %dbName%

echo create table temp_table%2 as table temp_table;|psql -U postgres %dbName%

echo copy temp_table%2 from 'c:\test\%2wSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

echo insert into %tableName% select distinct * from temp_table%2 ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

echo drop table temp_table%2;| psql -U postgres %dbName%
	