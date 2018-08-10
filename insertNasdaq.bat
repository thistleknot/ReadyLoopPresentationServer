REM Called by PopulateDB.bat after bonds have been downloaded.  Creates tables, requires 2 inputs

REM adds symbol to front of columns

set PGPASSWORD=1234

set dbName=readyloop

@echo off
cut -f 1,1 -d ; c:\test\nasdaqsymbolsnoheader.csv > tempNasdaqsymbols.txt
@echo on

echo drop table nasdaq_facts cascade;|psql -U postgres %dbName%

echo CREATE TABLE IF NOT EXISTS nasdaq_facts AS select * from nasdaq_facts_template;| psql -U postgres %dbName%

for /F "delims=," %%a in ('nasdaqSymbols.bat') do (

		awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%%a c:\test\share\%%a.csv > c:\test\share\%%awSymbols.csv
			
		echo drop table if exists temp_table%%a;| psql -U postgres %dbName%

		echo create table temp_table%%a as table nasdaq_facts_template;|psql -U postgres %dbName%

		echo copy temp_table%%a from 'c:\test\share\%%awSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

		echo insert into nasdaq_facts select distinct * from temp_table%%a ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

		echo drop table temp_table%%a;| psql -U postgres %dbName%			
			
	)
	
