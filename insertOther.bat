REM Called by PopulateDB.bat after bonds have been downloaded.  Creates tables, requires 2 inputs

REM adds symbol to front of columns

cd c:\test\share\other\

rename "O-*.csv" "//*.csv"

set dbName=readyloop
set host=192.168.3.103
set PGPASSWORD=Read1234

echo CREATE TABLE IF NOT EXISTS other_facts AS select * from other_facts_template;| psql -U postgres -h %host% %dbName%

dir c:\test\share\other\*.csv /b > c:\test\share\other\otherDirList.txt
cut -f 1 -d . c:\test\share\other\otherDirList.txt > c:\test\share\other\otherList

for /F %%a in (c:\test\share\other\OtherList) do (

		awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%%a c:\test\share\other\%%a.csv > c:\test\share\other\%%awSymbols.csv
			
		echo drop table if exists temp_table_O_%%a;| psql -U postgres -h %host% %dbName%

		echo create table temp_table_O_%%a as table other_facts_template;|psql -U postgres -h %host% %dbName%	

		echo \copy temp_table_O_%%a from 'c:\test\share\other\%%awSymbols.csv' DELIMITER ',' CSV HEADER NULL AS 'null';| psql -U postgres -h %host% %dbName%

		echo insert into other_facts select distinct * from temp_table_O_%%a ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%

		echo drop table temp_table_O_%%a;| psql -U postgres -h %host% %dbName%			
			
	)
	
erase otherDirList.txt
erase otherList
cd c:\users\user\Documents\alphaAdvantageApi\ReadyLoopPresentationServer\
exit