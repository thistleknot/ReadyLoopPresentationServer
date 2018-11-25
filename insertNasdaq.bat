REM Called by PopulateDB.bat after bonds have been downloaded.  Creates tables, requires 2 inputs

REM adds symbol to front of columns

cd c:\test\share\nasdaq\

rename "NS-*.csv" "///*.csv"

set dbName=readyloop
set host=192.168.1.5
set PGPASSWORD=Read1234

echo CREATE TABLE IF NOT EXISTS nasdaq_facts AS select * from nasdaq_facts_template;| psql -U postgres -h %host% %dbName%

dir c:\test\share\nasdaq\*.csv /b > c:\test\share\nasdaq\nasdaqDirList.txt
cut -f 1 -d . c:\test\share\nasdaq\nasdaqDirList.txt > c:\test\share\nasdaq\NasdaqList

for /F %%a in (c:\test\share\nasdaq\NasdaqList) do (

			awk '{print F,$1,$2,$3,$4,$5,$6,$7,$8,$9}' FS=, OFS=, F=%%a c:\test\share\nasdaq\%%a.csv > c:\test\share\nasdaq\%%awSymbols.csv
				
			echo drop table if exists temp_table_NS_%%a;| psql -U postgres -h %host% %dbName%

			echo create table temp_table_NS_%%a as table nasdaq_facts_template;|psql -U postgres -h %host% %dbName%	

			echo \copy temp_table_NS_%%a from 'c:\test\share\nasdaq\%%awSymbols.csv' DELIMITER ',' CSV HEADER NULL AS 'null';| psql -U postgres -h %host% %dbName%

			echo insert into nasdaq_facts select distinct * from temp_table_NS_%%a ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%

			echo drop table temp_table_NS_%%a;| psql -U postgres -h %host% %dbName%			
			
	)
	
erase nasdaqDirList.txt
erase NasdaqList
cd c:\users\user\Documents\alphaAdvantageApi\ReadyLoopPresentationServer\
exit