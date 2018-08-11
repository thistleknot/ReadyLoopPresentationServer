REM @echo off
setlocal enableextensions enabledelayedexpansion
REM set a=%1
REM set begin=%2
REM set end=%3
REM set crumb=%4

echo %1


SET /A test=%RANDOM% * 20 / 32768 + 1
FOR /F "tokens=*" %%b in ('returnLine.bat %test% proxyList.txt') do SET PROXY=%%b
echo %PROXY%

REM curl -x %PROXY% -s --cookie cookie.txt "https://query1.finance.yahoo.com/v7/finance/download/%1?period1=0%2&period2=%3&interval=1d&events=history&crumb=%crumb%" > "c:\test\share\etf\ETF-%1.csv" 

for /f "delims=" %%x in ('getCrumb.bat %1') do set "crumb=%%x"
curl -s --cookie cookie.txt "https://query1.finance.yahoo.com/v7/finance/download/%1?period1=0%2&period2=%3&interval=1d&events=history&crumb=%crumb%" > "c:\test\share\etf\ETF-%1.csv" 
REM @echo on
exit