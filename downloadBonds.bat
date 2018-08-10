
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

REM etfsymbols.bat

for /F %%a in ('tail -n +2 c:\test\ETFNamesSymbols.csv') do (

	
	echo !reset!
	call set reset=1
	echo %%a
	
	REM subDownloadBonds.bat
	
	start call subDownloadBonds.bat %%a %begin% %end% !crumb!
	
	REM it's not waiting for file to download before doing comparison
	REM for /f "delims=" %%z in ('differ.bat c:\test\share\ETF-%%a.csv c:\test\invalidCookie.txt') do (set "reset=%%z")
	
	REM If !reset! equ 0 (
		REM echo %%a %begin% %end% !crumb!
		
		REM )
	
	timeout /t 3
	
	
)
erase etfSymbolsNoQuotesNoHeader.txt


	