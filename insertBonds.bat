REM Called by PopulateDB.bat after bonds have been downloaded.  Creates tables, requires 2 inputs

REM adds symbol to front of columns

cd c:\test\share\etf\

rename "etf-*.csv" "////*.csv"

set dbName=readyloop
set host=192.168.1.5
set PGPASSWORD=Read1234

echo CREATE TABLE IF NOT EXISTS etf_bond_facts AS select * from etf_bond_facts_template;| psql -U postgres -h %host% %dbName%	

dir c:\test\share\etf\*.csv /b > bondDirList.txt
cut -f 1 -d . bondDirList.txt > bondList

for /F %%a in (bondList) do (

			awk '{print F,$1,$2,$3,$4,$5,$6,$7}' FS=, OFS=, F=%%a c:\test\share\etf\%%a.csv > c:\test\share\etf\%%awSymbols.csv

			echo drop table if exists temp_table_%%a;| psql -U postgres -h %host% %dbName%
	
			echo create table bond_facts_%%a as table etf_bond_facts_template;|psql -U postgres -h %host% %dbName%	

			echo \copy bond_facts_%%a from 'c:\test\share\etf\%%awSymbols.csv' DELIMITER ',' CSV HEADER NULL AS 'null';| psql -U postgres -h %host% %dbName%

			echo insert into etf_bond_facts select distinct * from bond_facts_%%a ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%

			echo drop table bond_facts_%%a;| psql -U postgres -h %host% %dbName%
	)
erase bondDirList.txt
erase bondlist
cd c:\users\user\Documents\alphaAdvantageApi\ReadyLoopPresentationServer\
exit