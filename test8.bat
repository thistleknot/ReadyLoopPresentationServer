setlocal enableextensions enabledelayedexpansion

set etfname=""

FOR /F "tokens=*" %%a in ('type apikey2.txt') do SET key=%%a

for /F "delims=," %%a in ('etfSub.bat') do (
	echo %%a
	
	curl https://www.quandl.com/api/v3/datasets/WIKI/%%a/data.csv?api_key=%key%
)

	