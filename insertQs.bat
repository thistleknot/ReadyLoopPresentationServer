REM setlocal enableextensions enabledelayedexpansion

REM set PGPASSWORD=Read1234

REM set dbName=readyloop

REM download Quantshare export

	REM echo DROP TABLE if exists qs_facts;| psql -U postgres -h %host% %dbName%
	
		REM echo CREATE TABLE if not exists qs_facts as select * from qs_facts_Template;| psql -U postgres -h %host% %dbName%
		
		echo copy qs_facts from 'c:\test\share\quantshare\quotes.csv' DELIMITER ';' CSV HEADER;| psql -U postgres -h %host% readyloop
		
		REM echo copy qs_facts from 'c:\test\share\quantshare\quotes.csv' DELIMITER ';' CSV HEADER;| psql -U postgres -h %host% %dbName%
		
		REM SELECT TO_CHAR(NOW(), 'yyyy/mm/dd')::date;
		
		REM echo insert into eod_indices select distinct * from eod_indicesTemp ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%	
		
		REM echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres -h %host% %dbName%
	
	REM views, ran after inserts to ensure refresh is properly applied.
	echo create materialized view if not exists mv_qs_symbols as select distinct (symbol) from qs_facts; refresh materialized view mv_qs_symbols; ALTER TABLE mv_qs_symbols OWNER to postgres; | psql -U postgres -h %host% readyloop
	
	echo create materialized view if not exists mv_qs_facts as select * from qs_facts; ALTER TABLE mv_qs_facts OWNER to postgres; | psql -U postgres -h %host% readyloop
	
	echo refresh materialized view mv_qs_facts; | psql -U postgres -h %host% readyloop
	
	echo DROP TABLE if exists qs_max_date;| psql -U postgres -h %host% readyloop
	
	echo CREATE TABLE as qs_max_date select max(timestamp) from mv_qs_facts; | psql -U postgres -h %host% readyloop
			
REM exit		
		