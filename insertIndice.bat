setlocal enableextensions enabledelayedexpansion

set PGPASSWORD=Read1234
set host=192.168.3.103
set fullFlag=1

REM download SP500 Index
set command=dlsp500.bat ^> SP500.csv

REM FOR /F "tokens=*" %%a in ('subcurrentdate.bat') do SET currentdate=%%a

call %command%

REM indice tables

	echo DROP TABLE if exists eod_indices;| psql -U postgres -h %host% %dbName%
	
	echo CREATE TABLE if not exists eod_indices_Template( symbol character varying(16) COLLATE pg_catalog."default" NOT NULL, date date NOT NULL, open real, high real, low real, close real, adj_close real, volume double precision, CONSTRAINT eod_indicesTemplate_pkey PRIMARY KEY (symbol, date)) WITH (OIDS = FALSE) TABLESPACE pg_default; ALTER TABLE public.eod_indices OWNER to postgres;| psql -U postgres -h %host% %dbName%
	
		echo CREATE TABLE if not exists eod_indices as select * from eod_indices_Template;| psql -U postgres -h %host% %dbName%
		
		echo CREATE TABLE if not exists eod_indicesTemp as select * from eod_indices_Template;| psql -U postgres -h %host% %dbName%
	
		REM for now we're just going to copy from a static file, but the intent is to go through a set of files and download each index from yahoo similar to how I download symbols from alphaadvantage.  I suppose I'll have to do something similar for FRED data.  A bunch of mini subtasks that download their own lists/structures of data (for example, I still only have nasdaq imported atm).
		
		xcopy sp500.csv c:\test\ /y
		
		awk '{print F,$1,$2,$3,$4,$5,$6,$7}' FS=, OFS=, F=SP500TR c:\test\sp500.csv > c:\test\sp500wSymbols.csv
  
		echo \copy eod_indicesTemp from 'c:\test\sp500wSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres -h %host% %dbName%
		
		echo insert into eod_indices select distinct * from eod_indicesTemp ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%	

		REM need to create materialized views
	
		echo drop view v_eod_indices_date_filtered_indice| psql -U postgres -h %host% %dbName%	
		REM echo CREATE OR REPLACE VIEW v_eod_indices_date_filtered_indice AS SELECT * FROM eod_indices WHERE eod_indices.date ^>= '2012-12-31'::date AND eod_indices.date ^<= '%currentdate%'::date order by date asc; > command.txt
		REM ECHO SELECT * FROM eod_indices WHERE eod_indices.date ^>= '2012-12-31'::date AND eod_indices.date ^<= '%currentdate%'::date ORDER BY DATE ASC; > command.txt
		
		REM set command=returnLine 1 command.txt
		REM %command%|psql -U postgres -h %host% %dbName%	
		REM erase command.txt		
		
		