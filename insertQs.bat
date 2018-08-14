REM setlocal enableextensions enabledelayedexpansion

REM set PGPASSWORD=1234

REM set dbName=readyloop

REM download Quantshare export

	REM echo DROP TABLE if exists qs_facts;| psql -U postgres %dbName%
	
		REM echo CREATE TABLE if not exists qs_facts as select * from qs_facts_Template;| psql -U postgres %dbName%
		
		echo copy qs_facts from 'd:\quantshare\quotes.csv' DELIMITER ';' CSV HEADER;| psql -U postgres readyloop
		
		REM echo copy qs_facts from 'd:\quantshare\quotes.csv' DELIMITER ';' CSV HEADER;| psql -U postgres %dbName%
		
		REM SELECT TO_CHAR(NOW(), 'yyyy/mm/dd')::date;
		
		REM echo insert into eod_indices select distinct * from eod_indicesTemp ON CONFLICT DO NOTHING;| psql -U postgres %dbName%	
		
		REM echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres %dbName%

	
	REM views, ran after inserts to ensure refresh is properly applied.
	echo create materialized view if not exists mv_qs_symbols as select distinct (symbol) from qs_facts; refresh materialized view mv_qs_symbols; ALTER TABLE mv_qs_symbols OWNER to postgres; | psql -U postgres readyloop
	
	echo create materialized view if not exists mv_qs_facts as select * from qs_facts; ALTER TABLE  mv_qs_facts OWNER to postgres; | psql -U postgres readyloop
	
	echo create materialized view if not exists mv_qs_facts as select * from qs_facts; ALTER TABLE  mv_qs_facts OWNER to postgres; | psql -U postgres readyloop
	
	echo refresh materialized view mv_qs_facts; | psql -U postgres readyloop
		
REM exit		
		