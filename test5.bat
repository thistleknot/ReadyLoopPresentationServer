setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
echo %numKeys%

FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a

set dbName=readyloop
set tableName=dadjclose

FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numLines=%%a
@echo off

set /A counter=1
FOR /L %%i IN (1,1,%numLines%) DO (

	REM new file
	
	echo "counter: " !counter!

	if !counter! == 1 call returnLine.bat %%i 'c:\test\nasdaqSymbolsNoHeader.csv' > list.txt
	if !counter! gtr 1 call returnLine.bat %%i 'c:\test\nasdaqSymbolsNoHeader.csv' >> list.txt
	
	REM list is ready
	if !counter! == %numKeys% ( 
		FOR /L %%i IN (1,1,%numKeys%) DO (	
			
			REM for /F "delims=;" %%a in (!temporary!) do (echo %%a)
			REM echo !temporary!
			echo "outer loop: " %%i
			
			set /A innerCounter=1
			
			for /F "delims=;" %%a in (list.txt) do (
				@echo off
				FOR /F "tokens=*" %%b in ('returnLine.bat !innerCounter! apiKey.txt') do SET APIKEY=%%b
				FOR /F "tokens=*" %%b in ('returnLine.bat !innerCounter! proxyList.txt') do SET PROXY=%%b
				
					
				REM start curl -X !PROXY! -L "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=%%a&outputsize=full&apikey=!APIKEY!&datatype=csv" -o c:\test\%%a.csv;
				echo %%a
				echo "inner counter" !innerCounter!
				set /A innerCounter+=1
				
				)
		) 
	)
	
	if !counter! == %numKeys% call echo	
	
	if !counter! == %numKeys% call set /A counter=0
	
	set /A counter+=1
		
	@echo on
	
timeout /t 1
				
	
	
		
  
)	