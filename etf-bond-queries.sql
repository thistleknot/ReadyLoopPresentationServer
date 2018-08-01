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
