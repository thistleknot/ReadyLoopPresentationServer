setlocal enableextensions enabledelayedexpansion

set fullFlag=1

REM go through remaining list
set /A newCounter=1

REM %%a is symbol
for /F "delims=;" %%a in (list.txt) do (
	echo %%a

	FOR /F "tokens=*" %%c in ('returnLine.bat !newCounter! apiKey.txt') do SET APIKEY=%%c

	SET /A test=%RANDOM% * 20 / 32768 + 1				
	REM for now not using random
	FOR /F "tokens=*" %%b in ('returnLine.bat %%newCounter%% proxyList.txt') do SET PROXY=%%b

	echo %test%
	echo !newCounter!
	echo !PROXY!
	echo %%a
	echo !APIKEY!
	start call downloadAlpha.bat !PROXY! %%a !APIKEY!
	set /A newCounter+=1				
)
timeout /t 4		
