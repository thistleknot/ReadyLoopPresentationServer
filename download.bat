call vars.bat

echo %1
echo %2
echo %3

curl -x %1 -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%2&outputsize=full&apikey=%3&datatype=csv" -o c:\test\%2.csv
awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%2 c:\test\%2.csv > c:\test\%2wSymbols.csv
	
echo drop table temp_table%2;| psql -U postgres %dbName%

echo create table temp_table%2 as table temp_table;|psql -U postgres %dbName%

echo copy temp_table%2 from 'c:\test\%%awSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

echo insert into %tableName% select distinct * from temp_table%2 ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

echo drop table temp_table%2;| psql -U postgres %dbName%
	
timeout /t 4
exit
