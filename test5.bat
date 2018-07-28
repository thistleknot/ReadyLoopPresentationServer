setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a

set dbName=readyloop
set tableName=dadjclose
 

REM SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numLines=%%a
REM echo %numKeys%

set /A arch=1
FOR /L %%i IN (1,1,%numLines%) DO (

	REM if(!arch! == 1) (returnLine.bat %%i c:\test\nasdaqSymbolsNoHeader.csv > list.txt)
	REM if(!arch! not == 1) (returnLine.bat %%i c:\test\nasdaqSymbolsNoHeader.csv >> list.txt)

	REM ECHO %%i
	
	REM if (!arch! == !numKeys!) (set /a a=1)
	REM if (!arch! not == !numKeys!) (set /a a+=1)
	echo !arch!
	set /a arch+=1
	
	if !arch! gtr 100 (echo ">100")
	if !arch! lss 100 (echo "<100")
  
)	