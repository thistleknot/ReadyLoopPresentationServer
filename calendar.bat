set PGPASSWORD=Read1234
set dbName=readyloop

	REM calendar
	
			echo drop table public.custom_calendar cascade| psql -U postgres -h %host% %dbName%	
	
			echo CREATE TABLE public.custom_calendar_Template(date date NOT NULL,y bigint,m bigint,d bigint, dow character varying(3) COLLATE pg_catalog."default", trading smallint, CONSTRAINT custom_calendarTemplate_pkey PRIMARY KEY (date)) WITH (OIDS = FALSE) TABLESPACE pg_default; ALTER TABLE public.custom_calendar_Template OWNER to postgres;| psql -U postgres -h %host% %dbName%	
		
			echo drop table temp_table2;| psql -U postgres -h %host% %dbName%	
				
			echo CREATE TABLE IF NOT EXISTS public.custom_calendar AS select * from custom_calendar_Template;| psql -U postgres -h %host% %dbName%
			
			echo create table temp_table2 as table public.custom_calendar_Template;|psql -U postgres %dbName%	
				
			REM manually created file
			REM atm based on nasdaq holidays as found here: http://markets.on.nytimes.com/research/markets/holidays/holidays.asp?display=all
			xcopy tradingDays.csv c:\test\ /y
				
			echo copy temp_table2 from 'c:\test\tradingDays.csv' DELIMITER ',' CSV HEADER;| psql -U postgres -h %host% %dbName%	
				
			echo insert into public.custom_calendar select distinct * from temp_table2 ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%	
				
			echo drop table temp_table2;| psql -U postgres -h %host% %dbName%	
			
			REM add EOM and Trading Day
			
			echo ALTER TABLE public.custom_calendar ADD COLUMN eom smallint;| psql -U postgres -h %host% %dbName%	

			echo ALTER TABLE public.custom_calendar ADD COLUMN prev_trading_day date;| psql -U postgres -h %host% %dbName%	
			
			REM EOM Flag
			echo UPDATE custom_calendar SET eom = EOMI.endofm FROM (SELECT CC.date,CASE WHEN EOM.y IS NULL THEN 0 ELSE 1 END endofm FROM custom_calendar CC LEFT JOIN (SELECT y,m,MAX(d) lastd FROM custom_calendar WHERE trading=1 GROUP by y,m) EOM ON CC.y=EOM.y AND CC.m=EOM.m AND CC.d=EOM.lastd) EOMI WHERE custom_calendar.date = EOMI.date;| psql -U postgres -h %host% %dbName%
						
			echo UPDATE custom_calendar SET prev_trading_day = PTD.ptd FROM (SELECT date, (SELECT MAX(CC.date) FROM custom_calendar CC WHERE CC.trading=1 AND CC.date^<custom_calendar.date) ptd FROM custom_calendar) PTD WHERE custom_calendar.date = PTD.date; > command.txt

			REM OMG it works
			set command=returnLine 1 command.txt
			%command%|psql -U postgres %dbName%
			erase command.txt
			
			REM had to use nulliff 
			REM need to base this on current dates
			rem Note: select * from v_eod_indices_2013_2017 where adjusted_close='0'
			REM echo Create Materialized View IF NOT EXISTS returnsNasdaq AS SELECT EOD.symbol,EOD.timestamp,EOD.adjusted_close/NULLIF( PREV_EOD.adjusted_close, 0 )-1.0 AS ret FROM v_eod_indices_2013_2017 EOD INNER JOIN custom_calendar CC ON EOD.timestamp=CC.date INNER JOIN v_eod_indices_2013_2017 PREV_EOD ON PREV_EOD.symbol=EOD.symbol AND PREV_EOD.timestamp=CC.prev_trading_day;| psql -U postgres -h %host% %dbName%
			REM echo REFRESH MATERIALIZED VIEW returnsNasdaq WITH DATA;| psql -U postgres -h %host% %dbName%
			
		REM query: select symbol, AVG(NULLIF(ret,0)) as average from returnsNasdaq group by symbol order by average desc; 
			
			REM exclusions
			REM echo SELECT symbol, 'More than 1% missing' as reason INTO exclusions_2013_2017 FROM %tableName% GROUP BY symbol HAVING count(*)::real/(SELECT COUNT(*) FROM custom_calendar WHERE trading=1 AND date BETWEEN '2012-12-31' AND '2018-07-28')::real^<0.99; > command.txt
			
			REM OMG it works
			REM set command=returnLine 1 command.txt
			REM %command%|psql -U postgres %dbName%
			REM erase command.txt			
			
		REM echo CREATE TABLE if not exists public.exclusions_2013_2017 (symbol character varying(8) COLLATE pg_catalog."default",reason text COLLATE pg_catalog."default") WITH (OIDS = FALSE) TABLESPACE pg_default; | psql -U postgres -h %host% %dbName%

			REM echo ALTER TABLE public.exclusions_2013_2017 OWNER to postgres;| psql -U postgres -h %host% %dbName%

			REM echo GRANT ALL ON TABLE public.exclusions_2013_2017 TO postgres;| psql -U postgres -h %host% %dbName%

			REM echo GRANT SELECT ON TABLE public.exclusions_2013_2017 TO readyloop;| psql -U postgres -h %host% %dbName%

		REM echo INSERT INTO exclusions_2013_2017 SELECT DISTINCT symbol, 'Return higher than 100%' as reason FROM returnsNasdaq WHERE ret>1.0; > command.txt
			
			REM OMG it works
			set command=returnLine 1 command.txt
			%command%|psql -U postgres %dbName%
			erase command.txt						
		
			REM echo create view filtered as SELECT * FROM returnsNasdaq WHERE symbol NOT IN  (SELECT DISTINCT symbol FROM exclusions_2013_2017);| psql -U postgres -h %host% %dbName%		
		
			REM echo select symbol, AVG(NULLIF(ret,0)) as average from filtered group by symbol order by average desc;| psql -U postgres -h %host% %dbName%	

			REM NOCREATEROL throws an error
			REM echo CREATE USER readyloop WITH LOGIN NOSUPERUSER NOCREATEDB INHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD 'read123'; 
			echo GRANT SELECT ON ALL TABLES IN SCHEMA public TO readyloop; ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readyloop;| psql -U postgres -h %host% %dbName%	
					
			