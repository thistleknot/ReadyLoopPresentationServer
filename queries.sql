	CREATE OR REPLACE VIEW public.v_eod_indices_2013_2017 AS
	 SELECT dadjclose.symbol,
		dadjclose.timestamp,
		dadjclose.adjusted_close
	   FROM dadjclose
	   WHERE dadjclose.timestamp >= '2012-12-31'::date AND dadjclose.timestamp <= '2018-07-28'::date;
	   
	CREATE OR REPLACE VIEW public.v_eod_indices_2017_2017 AS
	 SELECT dadjclose.symbol,
		dadjclose.timestamp,
		dadjclose.adjusted_close
	   FROM dadjclose
	   WHERE dadjclose.timestamp >= '2017-12-31'::date AND dadjclose.timestamp <= '2018-07-28'::date;	   

Create Materialized View returnsNasdaq AS
		SELECT EOD.symbol,EOD.timestamp,EOD.adjusted_close/NULLIF( PREV_EOD.adjusted_close, 0 )-1.0 AS ret
			FROM v_eod_indices_2013_2017 EOD INNER JOIN custom_calendar CC ON EOD.timestamp=CC.date
			INNER JOIN v_eod_indices_2013_2017 PREV_EOD ON PREV_EOD.symbol=EOD.symbol AND PREV_EOD.timestamp=CC.prev_trading_day;
			REFRESH MATERIALIZED VIEW returnsNasdaq WITH DATA;
			
Create Materialized View returnsNasdaq2 AS
		SELECT EOD.symbol,EOD.timestamp,EOD.adjusted_close/NULLIF( PREV_EOD.adjusted_close, 0 )-1.0 AS ret
			FROM v_eod_indices_2017_2017 EOD INNER JOIN custom_calendar CC ON EOD.timestamp=CC.date
			INNER JOIN v_eod_indices_2017_2017 PREV_EOD ON PREV_EOD.symbol=EOD.symbol AND PREV_EOD.timestamp=CC.prev_trading_day;
			REFRESH MATERIALIZED VIEW returnsNasdaq2 WITH DATA;			
			
			select * from custom_calendar order by date asc;
			
			select * from v_eod_indices_2013_2017 where adjusted_close='0'
			
select symbol, AVG(NULLIF(ret,0)) as average from returnsNasdaq group by symbol order by average desc; 
			