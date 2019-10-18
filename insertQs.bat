setlocal enableextensions enabledelayedexpansion
set host=192.168.3.103
set PGPASSWORD=Read1234
set dbName=readyloop

REM download Quantshare export

	echo drop database readyloop; create database readyloop;| psql -U postgres -h %host%

	echo DROP materialized view if exists mv_qs_facts cascade| psql -U postgres -h %host% %dbName%
	echo DROP materialized view if exists mv_qs_symbols cascade| psql -U postgres -h %host% %dbName%

	echo DROP TABLE if exists qs_facts cascade| psql -U postgres -h %host% %dbName%
	
	echo drop table if exists qs_facts_template CASCADE;| psql -U postgres -h %host% readyloop
Rem create qs_fact table	
	echo CREATE TABLE IF NOT EXISTS qs_facts_template (id SERIAL, symbol varchar(8), timestamp date, close real null, open real null, high real null, low real null, volume real null, CONSTRAINT qs_facts_template_key PRIMARY KEY (id)) WITH (OIDS=TRUE) TABLESPACE pg_default; ALTER TABLE qs_facts_template OWNER to postgres; | psql -U postgres -h %host% readyloop
	
	echo CREATE TABLE IF NOT EXISTS qs_facts AS select * from qs_facts_template; | psql -U postgres -h %host% readyloop
	
	echo ALTER TABLE public.qs_facts ADD CONSTRAINT qs_facts_key PRIMARY KEY (id); | psql -U postgres -h %host% readyloop
	
	REM I looked at psqladmin and exported the sequence from qs_facts_template
	REM http://www.postgresqltutorial.com/postgresql-serial/
	echo CREATE SEQUENCE public.qs_facts_id_seq INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1; ALTER SEQUENCE public.qs_facts_id_seq OWNER TO postgres;| psql -U postgres -h %host% readyloop
	
	echo ALTER TABLE public.qs_facts ALTER COLUMN id SET DEFAULT nextval('qs_facts_id_seq'); | psql -U postgres -h %host% readyloop
	
	REM echo CREATE TABLE if not exists qs_facts as select * from qs_facts_Template| psql -U postgres -h %host% %dbName%
		
		REM http://matt.might.net/articles/ssh-hacks/
		REM cat file | ssh -e none remote-host 'cat > file'
		
		REM https://stackoverflow.com/questions/33353997/how-to-insert-csv-data-into-postgresql-database-remote-database
		REM psql -h remotehost -d remote_mydb -U myuser -c "\copy mytable (column1, column2)  from '/path/to/local/file.csv' with delimiter as ','"
		REM https://unix.stackexchange.com/questions/277080/copy-csv-data-while-simultaneously-filling-serial-column
		echo \copy qs_facts (symbol, timestamp, close, open, high, low, volume) from PROGRAM 'cat C:\Users\user\Documents\quantshare\quotes.csv' DELIMITER ';' CSV HEADER| psql -U postgres -h %host% %dbName%
		
		REM echo \copy qs_facts from 'c:\test\share\quantshare\quotes.csv' DELIMITER ';' CSV HEADER;| psql -U postgres -h %host% %dbName%
		
		REM SELECT TO_CHAR(NOW(), 'yyyy/mm/dd')::date;
		
		REM echo insert into eod_indices select distinct * from eod_indicesTemp ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%	
		
		REM echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres -h %host% %dbName%
	
	REM views, ran after inserts to ensure refresh is properly applied.
	
	echo create materialized view if not exists mv_qs_symbols as select distinct (symbol) from qs_facts | psql -U postgres -h %host% %dbName%
	echo refresh materialized view mv_qs_symbols | psql -U postgres -h %host% %dbName%
	echo ALTER TABLE mv_qs_symbols OWNER to postgres | psql -U postgres -h %host% %dbName%
	
	echo CREATE materialized view mv_qs_facts as SELECT DISTINCT ON (symbol, timestamp) id, timestamp, symbol, close, open, high, low, volume FROM qs_facts order by symbol, timestamp, id desc; | psql -U postgres -h %host% %dbName%
	
	echo ALTER TABLE mv_qs_facts OWNER to postgres| psql -U postgres -h %host% %dbName%
	
	echo refresh materialized view mv_qs_facts| psql -U postgres -h %host% %dbName%
	
	echo DROP TABLE if exists qs_max_date| psql -U postgres -h %host% %dbName%
	
	echo CREATE TABLE qs_max_date as select max(timestamp) from mv_qs_facts| psql -U postgres -h %host% %dbName%
			
REM exit		
		