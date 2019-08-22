set host=192.168.3.103
set PGPASSWORD=Read1234
set dbName=readyloop

	REM calendar
	
			echo drop table public.custom_calendar cascade| psql -U postgres -h %host% %dbName%	
	
			echo CREATE TABLE public.custom_calendar_Template(date date NOT NULL,y bigint,m bigint,d bigint, dow character varying(3) COLLATE pg_catalog."default", trading smallint, CONSTRAINT custom_calendarTemplate_pkey PRIMARY KEY (date)) WITH (OIDS = FALSE) TABLESPACE pg_default; ALTER TABLE public.custom_calendar_Template OWNER to postgres;| psql -U postgres -h %host% %dbName%	
		
			echo drop table temp_table2;| psql -U postgres -h %host% %dbName%	
				
			echo CREATE TABLE IF NOT EXISTS public.custom_calendar AS select * from custom_calendar_Template;| psql -U postgres -h %host% %dbName%
			
			echo create table temp_table2 as table public.custom_calendar_Template;|psql -U postgres -h %host% %dbName%	
				
			REM manually created file
			REM atm based on nasdaq holidays as found here: http://markets.on.nytimes.com/research/markets/holidays/holidays.asp?display=all
			xcopy tradingDays.csv c:\test\ /y
				
			echo \copy temp_table2 from PROGRAM 'cat c:\test\tradingDays.csv' DELIMITER ',' CSV HEADER;| psql -U postgres -h %host% %dbName%	
				
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
			%command%| psql -U postgres -h %host% %dbName%	
			erase command.txt
			
			echo select symbol, AVG(NULLIF(close,0)) as average from mv_qs_facts group by symbol order by average asc;| psql -U postgres -h %host% %dbName%
	