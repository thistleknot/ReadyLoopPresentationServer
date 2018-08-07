-------------------------------------------------------------------------
-- Next, let's prepare a custom calendar (using a spreadsheet) --------
-------------------------------------------------------------------------

-- We need a stock market calendar to check our data for completeness

-- Because it is faster, we will use Excel (we need market holidays to do that)

-- We will use NETWORKDAYS.INTL function

-- date, y,m,d,dow,trading (format date and dow!)

-- Save as custom_calendar.csv and import to a new table

/*
LIFELINE:
-- DROP TABLE public.custom_calendar;
*/

	CREATE TABLE public.custom_calendar
	(
		date date NOT NULL,
		y bigint,
		m bigint,
		d bigint,
		dow character varying(3) COLLATE pg_catalog."default",
		trading smallint,
		CONSTRAINT custom_calendar_pkey PRIMARY KEY (date)
	)
	WITH (
		OIDS = FALSE
	)
	TABLESPACE pg_default;

	ALTER TABLE public.custom_calendar
		OWNER to postgres;



-- CHECK:
--SELECT * FROM custom_calendar LIMIT 10;

-- Let's add some columns to be used later: eom (end-of-month) and prev_trading_day
--import then do the following

-- LIFELINE
ALTER TABLE public.custom_calendar
    ADD COLUMN eom smallint;

ALTER TABLE public.custom_calendar
    ADD COLUMN prev_trading_day date;

	UPDATE custom_calendar
SET prev_trading_day = PTD.ptd
FROM (SELECT date, (SELECT MAX(CC.date) FROM custom_calendar CC WHERE CC.trading=1 AND CC.date<custom_calendar.date) ptd FROM custom_calendar) PTD
WHERE custom_calendar.date = PTD.date;


-- We could really use the last trading day of 2012 (as the end of the month)
--INSERT INTO custom_calendar VALUES('2011-12-30',2011,12,30,'Fri',1,1,NULL);
-- Re-run the update

UPDATE custom_calendar
SET eom = EOMI.endofm
FROM (SELECT CC.date,CASE WHEN EOM.y IS NULL THEN 0 ELSE 1 END endofm FROM custom_calendar CC LEFT JOIN
(SELECT y,m,MAX(d) lastd FROM custom_calendar WHERE trading=1 GROUP by y,m) EOM
ON CC.y=EOM.y AND CC.m=EOM.m AND CC.d=EOM.lastd) EOMI
WHERE custom_calendar.date = EOMI.date;


UPDATE custom_calendar
SET prev_trading_day = PTD.ptd
FROM (SELECT date, (SELECT MAX(CC.date) FROM custom_calendar CC WHERE CC.trading=1 AND CC.date<custom_calendar.date) ptd FROM custom_calendar) PTD
WHERE custom_calendar.date = PTD.date;



--update calendar
	--update custom_calendar set trading=0 where date='2013-03-29'
	--update custom_calendar set eom=1 where date='2013-03-28'
	--update custom_calendar set eom=0 where date='2013-03-29'

--select all symbols within last year.	
	create or replace view three_month_view AS
	select * from etf_bond_facts
	WHERE
		timestamp BETWEEN (current_date - interval '3 months') AND current_date 
		order by timestamp desc;
		
	create or replace view one_year_view AS
	select * from etf_bond_facts
	WHERE
		timestamp BETWEEN (current_date - interval '1 years') AND current_date 
		order by timestamp desc;

	create or replace view two_year_view AS
	select * from etf_bond_facts
	WHERE
		timestamp BETWEEN (current_date - interval '2 years') AND current_date 
		order by timestamp desc;
		
	create or replace view three_year_view AS
	select * from etf_bond_facts
	WHERE
		timestamp BETWEEN (current_date - interval '3 years') AND current_date 
		order by timestamp desc;		

	create or replace view four_year_view AS
	select * from etf_bond_facts
	WHERE
		timestamp BETWEEN (current_date - interval '4 years') AND current_date 
		order by timestamp desc;		
		

--pass variables from command line
--https://stackoverflow.com/questions/7389416/postgresql-how-to-pass-parameters-from-command-line
	--psql -h host -U username -d myDataBase -a -f myInsertFile

--https://stackoverflow.com/questions/9736085/run-a-postgresql-sql-file-using-command-line-arguments
	--psql -v v1=12 -v v2="'Hello World'"

--min/max dates
	-- select min(<date columnName>),max(date columnName) FROM <table>

	-- ex. 
		select min(timestamp),max(timestamp) FROM etf_bond_facts;

--show # of symbols per year by dividing by # of trading days
	SELECT date_part('year',date), COUNT(*)/252 FROM <table> GROUP BY date_part('year',date);
	
	-- ex.
		SELECT date_part('year',timestamp), COUNT(*)/252 FROM etf_bond_facts GROUP BY date_part('year',timestamp) order by date_part asc;

--select distinct symbols
	select distinct symbol from etf_bond_facts;
	
--symbol list
	select distinct symbol from etf_bond_facts order by symbol;
	
	--select years in data	
	create view if not exists unsortedYears As
	select distinct(date_part('year',timestamp))
	FROM etf_bond_facts
	as year_ ;
	select * from unsortedYears
	order by date_part asc;

	--1 year ago
		select (current_date - interval '12 months');		
	

	--# symbols to trade (yay, I can easily pivot these!)
	SELECT date_part('year',timestamp), COUNT(*)/63 FROM three_month_view GROUP BY date_part('year',timestamp);
	
	--https://stackoverflow.com/questions/5425627/sql-query-for-todays-date-minus-two-months
	--From postgresql
	--https://stackoverflow.com/questions/766657/how-do-you-use-variables-in-a-simple-postgresql-script
	--https://stackoverflow.com/questions/5425627/sql-query-for-todays-date-minus-two-months
	--https://www.postgresql.org/docs/8.2/static/functions-datetime.html
	-- http://www.postgresqltutorial.com/plpgsql-variables/	
