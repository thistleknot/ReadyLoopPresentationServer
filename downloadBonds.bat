
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
	echo %%a
	
	for /f "delims=" %%x in ('getCrumb.bat %%a') do set "crumb=%%x"
	REM subDownloadBonds.bat
		
	call subDownloadBonds.bat %%a %begin% %end% !crumb! > "c:\test\ETF-%%a.csv"
	
	
)


