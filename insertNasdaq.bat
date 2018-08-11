REM Called by PopulateDB.bat after bonds have been downloaded.  Creates tables, requires 2 inputs

REM adds symbol to front of columns

cd c:\test\share\nasdaq\

rename "NS-*.csv" "////*.csv"

set dbName=readyloop

set PGPASSWORD=1234

echo drop table if exists nasdaq_facts cascade;|psql -U postgres %dbName%

echo CREATE TABLE IF NOT EXISTS nasdaq_facts AS select * from nasdaq_facts_template;| psql -U postgres %dbName%

dir c:\test\share\nasdaq\*.csv /b > nasdaqDirList.txt
cut -f 1 -d . nasdaqDirList.txt > NasdaqList

for /F %%a in (NasdaqList) do (

			awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%%a c:\test\share\nasdaq\%%a.csv > c:\test\share\nasdaq\%%awSymbols.csv
				
			echo drop table if exists temp_table_%%a;| psql -U postgres %dbName%

			echo create table temp_table_%%a as table nasdaq_facts_template;|psql -U postgres %dbName%

			echo copy temp_table_%%a from 'c:\test\share\nasdaq\%%awSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

			echo insert into nasdaq_facts select distinct * from temp_table_%%a ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

			echo drop table temp_table_%%a;| psql -U postgres %dbName%			
			
	)
	
erase nasdaqDirList.txt
erase NasdaqList