setlocal enableextensions enabledelayedexpansion
set host=192.168.3.103
set PGPASSWORD=Read1234

set dbName=readyloop

REM download Quantshare export

	echo DROP TABLE if exists qs_facts cascade;| psql -U postgres -h %host% %dbName%;
	
		echo CREATE TABLE if not exists qs_facts as select * from qs_facts_Template;| psql -U postgres -h %host% %dbName%
		
		REM http://matt.might.net/articles/ssh-hacks/
		REM cat file | ssh -e none remote-host 'cat > file'
		
		REM https://stackoverflow.com/questions/33353997/how-to-insert-csv-data-into-postgresql-database-remote-database
		REM psql -h remotehost -d remote_mydb -U myuser -c "\copy mytable (column1, column2)  from '/path/to/local/file.csv' with delimiter as ','"
		echo \copy qs_facts from PROGRAM 'cat c:\test\share\quantshare\quotes.csv' DELIMITER ';' CSV HEADER;| psql -U postgres -h %host% readyloop
		
		REM echo \copy qs_facts from 'c:\test\share\quantshare\quotes.csv' DELIMITER ';' CSV HEADER;| psql -U postgres -h %host% %dbName%
		
		REM SELECT TO_CHAR(NOW(), 'yyyy/mm/dd')::date;
		
		REM echo insert into eod_indices select distinct * from eod_indicesTemp ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%	
		
		REM echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres -h %host% %dbName%
	
	REM views, ran after inserts to ensure refresh is properly applied.
	echo create materialized view if not exists mv_qs_symbols as select distinct (symbol) from qs_facts; refresh materialized view mv_qs_symbols; ALTER TABLE mv_qs_symbols OWNER to postgres; | psql -U postgres -h %host% readyloop
	
	echo create materialized view if not exists mv_qs_facts as select * from qs_facts; ALTER TABLE mv_qs_facts OWNER to postgres; | psql -U postgres -h %host% readyloop
	
	echo refresh materialized view mv_qs_facts; | psql -U postgres -h %host% readyloop
	
	echo DROP TABLE if exists qs_max_date;| psql -U postgres -h %host% readyloop
	
	echo CREATE TABLE qs_max_date as select max(timestamp) from mv_qs_facts; | psql -U postgres -h %host% readyloop
			
REM exit		
		