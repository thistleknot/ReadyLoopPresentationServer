REM Called by PopulateDB.bat after bonds have been downloaded.  Creates tables, requires 2 inputs

REM proxy
echo %1

REM symbol
echo %2

REM Key
echo %3

REM adds symbol to front of columns

for /F "delims=," %%a in ('etfnamessymbols.bat') do (

	awk '{print F,$1,$2,$3}' FS=, OFS=, F=%2 c:\test\share\etf-%2.csv > c:\test\share\etf-%2wSymbols.csv
	
	
			REM echo drop table bSymbolsTemp;| psql -U postgres %dbName%
			
			
REM echo create table temp_table%2 as table bSymbolsTemplate;|psql -U postgres %dbName%

	)
	