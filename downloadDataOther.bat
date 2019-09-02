@echo off
setlocal enableextensions enabledelayedexpansion

FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('returnLine.bat 1 psqlPW.txt') do SET PGPASSWORD=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numNasdaqSymbols=%%a
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\otherSymbolsNoHeader.csv') do SET numOtherSymbols=%%a
set waitPeriod=12
echo %waitPeriod%
set PGPASSWORD=Read1234
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
FOR /f "delims=;" %%a IN (c:\test\otherSymbolsNoHeader.csv) DO (

			REM %%a is symbol
				echo %%a
				
				FOR /F "tokens=*" %%c in ('returnLine.bat 1 apiKey.txt') do SET APIKEY=%%c
				
				REM SET /A test=%RANDOM% * 20 / 32768 + 1				
				REM for now not using random
				FOR /F "tokens=*" %%b in ('returnLine.bat 1 proxyList.txt') do SET PROXY=%%b

				REM echo %test%
				REM echo !newCounter!
				echo !PROXY!
				echo %%a
				echo !APIKEY!
				cmd.exe /c call downloadAlphaOther.bat !PROXY! %%a !APIKEY!
				rEM set /A newCounter+=1				
				timeout /t 8
				)
				
REM listAORemnants.bat
exit