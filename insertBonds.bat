REM Called by PopulateDB.bat after bonds have been downloaded.  Creates tables, requires 2 inputs

REM adds symbol to front of columns

for /F "delims=," %%a in ('etfnamessymbols.bat') do (

			awk '{print F,$1,$2,$3,$4,$5,$6,$7}' FS=, OFS=, F=%%a c:\test\share\etf-%%a.csv > c:\test\share\etf-%%awSymbols.csv
	
			echo drop table if exists temp_table%%a;| psql -U postgres %dbName%
	
			echo create table bond_facts%%a as table bond_facts_template;|psql -U postgres %dbName%

			echo copy bond_facts%%a from 'c:\test\share\etf-%%awSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%

			echo insert into etf_bond_facts select distinct * from bond_facts%%a ON CONFLICT DO NOTHING;| psql -U postgres %dbName%

			echo drop table bond_facts%%a;| psql -U postgres %dbName%
	)
	