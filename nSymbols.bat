setlocal enableextensions enabledelayedexpansion
set host=192.168.3.103
set PGPASSWORD=Read1234
set dbName=readyloop

	echo create table if not exists nSymbolsTemplate (symbol varchar(8), securityName varchar(256), MarketCategory varchar(4),testIssue varchar(4),financialStatus varchar(4),roundLotSize varchar(4),ETF varchar(4), nextShares varchar(4),CONSTRAINT nsymbolsTemplate_pkey PRIMARY KEY (symbol)) WITH (OIDS=FALSE) TABLESPACE pg_default;| psql -U postgres -h %host% %dbName%
	
		echo drop table if exists nsymbols;| psql -U postgres -h %host% %dbName%	
		
		echo CREATE TABLE if not exists nSymbols as select * from nSymbolsTemplate;| psql -U postgres -h %host% %dbName%
		
		echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres -h %host% %dbName%
	
		echo CREATE TABLE if not exists nSymbolsTemp as select * from nSymbolsTemplate;| psql -U postgres -h %host% %dbName%

		echo \copy nSymbolsTemp from 'c:\test\nasdaqSymbolsNoHeaderFull.csv' DELIMITER ';';| psql -U postgres -h %host% %dbName%
		
		echo insert into nSymbols select distinct * from nSymbolsTemp ON CONFLICT DO NOTHING;| psql -U postgres -h %host% %dbName%	
		
		echo ALTER TABLE nSymbols OWNER to postgres;| psql -U postgres -h %host% %dbName%

