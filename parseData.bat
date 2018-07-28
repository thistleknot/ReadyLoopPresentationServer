call vars.bat
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
	
		set /A newCounter=1
	
			for /F "delims=;" %%a in (list.txt) do (
				echo %%a
				
				FOR /F "tokens=*" %%c in ('returnLine.bat !newCounter! apiKey.txt') do SET APIKEY=%%c
				SET /A test=%RANDOM% * 20 / 32768 + 1
				
				FOR /F "tokens=*" %%b in ('returnLine.bat %test% proxyList.txt') do SET PROXY=%%b
				echo !newCounter!
				echo !PROXY!
				echo %%a
				echo !APIKEY!
				start call download.bat !PROXY! %%a !APIKEY!
				set /A newCounter+=1

				)
				timeout /t 6

			
	)
	
	if !counter! == %numKeys% call echo	
	
	if !counter! == %numKeys% call set /A counter=0
	
	set /A counter+=1
		
	@echo on
  
)	