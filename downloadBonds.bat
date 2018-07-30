
setlocal enableextensions enabledelayedexpansion

set gnuUtilpath=c:\Program Files (x86)\coreutils-5.3.0-bin\bin\

REM present date
set epochNow="%gnuUtilpath%date.exe" +%%s
%epochNow% > epochNow.txt

set epochThen="%gnuUtilpath%date.exe" -d "01/01/2001" +%%s
%epochThen% > epochThen.txt

for /f "delims=" %%x in ('cat epochThen.txt') do set "begin=%%x"
for /f "delims=" %%x in ('cat epochNow.txt') do set "end=%%x"
	
set task="%gnuUtilpath%wget.exe"

set urlbase=https://query1.finance.yahoo.com/v7/finance/download/

for /F "delims=," %%a in ('etfSub.bat') do (
	
	for /f "delims=" %%x in ('getCrumb.bat %%a') do set "crumb=%%x"
	curl -s --cookie cookie.txt "https://query1.finance.yahoo.com/v7/finance/download/%%a?period1=0%begin%&period2=%end%&interval=1d&events=history&crumb=!crumb!"
)


