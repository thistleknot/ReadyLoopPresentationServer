@echo off
setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\otherSymbolsNoHeader.csv') do SET numOtherSymbols=%%a
set waitPeriod=12
echo %waitPeriod%
set PGPASSWORD=1234
set fullFlag=1

@echo on

setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
echo %numKeys%

FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\otherSymbolsNoHeader.csv') do SET numOtherSymbols=%%a

FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\otherSymbolsNoHeader.csv') do SET numLines=%%a
@echo off

set /A counter=1
FOR /L %%i IN (1,1,%numLines%) DO (

	REM new file
	
	echo "counter: " !counter!

	REM queue's up a certain # before downloading
	if !counter! == 1 call returnLine.bat %%i 'c:\test\otherSymbolsNoHeader.csv' > listOther.txt
	if !counter! gtr 1 call returnLine.bat %%i 'c:\test\otherSymbolsNoHeader.csv' >> listOther.txt
	
	REM list is ready
	if !counter! == %numKeys% ( 
	
		set /A newCounter=1
	
			REM %%a is symbol
			for /F "delims=;" %%a in (listOther.txt) do (
				echo %%a
				
				FOR /F "tokens=*" %%c in ('returnLine.bat !newCounter! apiKey.txt') do SET APIKEY=%%c
				SET /A test=%RANDOM% * 20 / 32768 + 1
				
				FOR /F "tokens=*" %%b in ('returnLine.bat %%newCounter%% proxyList.txt') do SET PROXY=%%b
				echo !newCounter!
				echo !PROXY!
				echo %%a
				echo !APIKEY!
				start call downloadAlphaOther.bat !PROXY! %%a !APIKEY!
				set /A newCounter+=1				
				)
				timeout /t 55	
	)
	
	if !counter! == %numKeys% call echo	
	
	if !counter! == %numKeys% call set /A counter=0
	
	set /A counter+=1
		
	@echo on
  
)	
listAORemnants.bat
exit