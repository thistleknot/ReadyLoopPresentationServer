setlocal enableextensions enabledelayedexpansion
REM for /f "delims=" %%x in ('getCrumb2.bat') do set "crumb=%%x"

echo %crumb%

for /F "delims=," %%a in ('etfSub.bat') do (
REM errors at end
REM for /F "delims=," %%a in ('cat test.txt') do (
	REM echo %%a
	for /f "delims=" %%x in ('getCrumb.bat %%a') do set "crumb=%%x"
	REM curl -s --cookie cookie.txt  "https://query1.finance.yahoo.com/v7/finance/download/HDGE?period1=1325404800&period2=1514707200&interval=1d&events=history&crumb=!crumb!"
	curl -s --cookie cookie.txt  "https://query1.finance.yahoo.com/v7/finance/download/%%a?period1=1325404800&period2=1514707200&interval=1d&events=history&crumb=!crumb!"
)


