set command=dlsp500.bat ^> SP500.csv

REM FOR /F "tokens=*" %%a in ('subcurrentdate.bat') do SET currentdate=%%a

call %command%

REM indice tables

	echo DROP TABLE if exists eod_indices;| psql -U postgres %dbName%
	
	echo CREATE TABLE if not exists eod_indices_Template( symbol character varying(16) COLLATE pg_catalog."default" NOT NULL, date date NOT NULL, open real, high real, low real, close real, adj_close real, volume double precision, CONSTRAINT eod_indicesTemplate_pkey PRIMARY KEY (symbol, date)) WITH (OIDS = FALSE) TABLESPACE pg_default; ALTER TABLE public.eod_indices OWNER to postgres;| psql -U postgres %dbName%
	
		echo CREATE TABLE if not exists eod_indices as select * from eod_indices_Template;| psql -U postgres %dbName%
		
		echo CREATE TABLE if not exists eod_indicesTemp as select * from eod_indices_Template;| psql -U postgres %dbName%
	
		REM for now we're just going to copy from a static file, but the intent is to go through a set of files and download each index from yahoo similar to how I download symbols from alphaadvantage.  I suppose I'll have to do something similar for FRED data.  A bunch of mini subtasks that download their own lists/structures of data (for example, I still only have nasdaq imported atm).
		
		xcopy sp500.csv c:\test\ /y
		
		awk '{print F,$1,$2,$3,$4,$5,$6,$7}' FS=, OFS=, F=SP500TR c:\test\sp500.csv > c:\test\sp500wSymbols.csv
  
		echo copy eod_indicesTemp from 'c:\test\sp500wSymbols.csv' DELIMITER ',' CSV HEADER;| psql -U postgres %dbName%
		
		echo insert into eod_indices select distinct * from eod_indicesTemp ON CONFLICT DO NOTHING;| psql -U postgres %dbName%	
		
		echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres %dbName%

