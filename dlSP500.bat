@echo off

REM set gnuUtilpath=c:\Program Files (x86)\coreutils-5.3.0-bin\bin\
set gnuUtilpath=c:\Program Files (x86)\GnuWin32\bin\

REM present date
set epochNow="%gnuUtilpath%date.exe" +%%s
%epochNow% > epochNow.txt

set epochThen="%gnuUtilpath%date.exe" -d "12/30/1999" +%%s
%epochThen% > epochThen.txt

for /f "delims=" %%x in ('cat epochThen.txt') do set "begin=%%x"
for /f "delims=" %%x in ('cat epochNow.txt') do set "end=%%x"
	
set urlbase=https://query1.finance.yahoo.com/v7/finance/download/

set symbol=%%5ESP500TR
for /f "delims=" %%x in ('getCrumb.bat %symbol%') do set "crumb=%%x"

curl -s --cookie cookie.txt  "%urlbase%%symbol%?period1=0%begin%&period2=%end%&interval=1d&events=history&crumb=%crumb%"
REM echo "%urlbase%%symbol%?period1=0%begin%&period2=%end%&interval=1d&events=history&crumb=%crumb%"
@echo on
