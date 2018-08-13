setlocal enableextensions enabledelayedexpansion

set PGPASSWORD=1234

set dbName=readyloop

REM download Quantshare export

	echo DROP TABLE if exists qs_facts;| psql -U postgres %dbName%
	
		echo CREATE TABLE if not exists qs_facts as select * from qs_facts_Template;| psql -U postgres %dbName%
		
		echo copy qs_facts from 'd:\quantshare\quotes.csv' DELIMITER ';' CSV HEADER;| psql -U postgres %dbName%
		
		REM echo insert into eod_indices select distinct * from eod_indicesTemp ON CONFLICT DO NOTHING;| psql -U postgres %dbName%	
		
		REM echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres %dbName%

REM exit		
		