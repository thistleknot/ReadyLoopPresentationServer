REM Called by PopulateDB.bat after bonds have been downloaded.  Creates tables, requires 2 inputs

REM adds symbol to front of columns

set PGPASSWORD=1234

set dbName=readyloop

@echo off
cut -f 1,1 -d ; c:\test\othersymbolsnoheader.csv > tempOthersymbols.txt
@echo on

echo drop table other_facts cascade;|psql -U postgres %dbName%

echo CREATE TABLE IF NOT EXISTS other_facts AS select * from other_facts_template;| psql -U postgres %dbName%

for /F "delims=," %%a in (tempOthersymbols.txt) do (

		awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%%a c:\test\share\other\O-%%a.csv > c:\test\share\other\O-%%awSymbols.csv
			
		echo drop table if exists temp_table_O-%%a;| psql -U postgres %dbName%

		echo create table temp_table_O-%%a as table other_facts_template;|psql -U postgres %dbName%

		echo copy temp_table_O-%%a from 'c:\test\share\%%awSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

		echo insert into other_facts select distinct * from temp_table_O-%%a ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

		echo drop table temp_table_O-%%a;| psql -U postgres %dbName%			
			
	)
	
