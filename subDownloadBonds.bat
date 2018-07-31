@echo off
set a=%1
set begin=%2
set end=%3
set crumb=%4
curl -s --cookie cookie.txt "https://query1.finance.yahoo.com/v7/finance/download/%1?period1=0%2&period2=%3&interval=1d&events=history&crumb=%4" > "c:\test\ETF-%1.csv" 
@echo on
REM exit