setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a

set dbName=readyloop
set tableName=dadjclose
 

REM SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numLines=%%a
REM echo %numKeys%

set /A counter=1
FOR /L %%i IN (1,1,%numLines%) DO (

	if !counter! == 1 (returnLine.bat %%i c:\test\nasdaqSymbolsNoHeader.csv > list.txt)
	if !counter! gtr 1 (returnLine.bat %%i c:\test\nasdaqSymbolsNoHeader.csv >> list.txt)

	REM ECHO %%i
	
	if !counter! == !numKeys! (set /a a=1)
	if !counter! lss !numKeys! (set /a a+=1)
	echo !counter!
	set /a counter+=1
  
)	