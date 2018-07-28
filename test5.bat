setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
echo %numKeys%

FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a

set dbName=readyloop
set tableName=dadjclose

FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numLines=%%a

REM returnLine.bat %%i c:\test\nasdaqSymbolsNoHeader.csv >> list.txt

set /A counter=1
FOR /L %%i IN (1,1,%numLines%) DO (

	REM new file

	
	echo "counter: " !counter!
	
	if !counter! == 1 call returnLine.bat %%i 'c:\test\nasdaqSymbolsNoHeader.csv' > list.txt
	if !counter! gtr 1 call returnLine.bat %%i 'c:\test\nasdaqSymbolsNoHeader.csv' >> list.txt
	if !counter! == %numKeys% call type list.txt
	if !counter! == %numKeys% call echo	
	if !counter! == %numKeys% call set /A counter=0
	
	set /A counter+=1
	
	
timeout /t 1
				
	
	
		
  
)	