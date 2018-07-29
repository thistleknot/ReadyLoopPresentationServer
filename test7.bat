REM setlocal enableextensions enabledelayedexpansion

REM thank you
REM https://stackoverflow.com/questions/3454112/is-there-a-way-to-get-epoch-time-using-a-windows-command
set gnuUtilpath=c:\Program Files (x86)\coreutils-5.3.0-bin\bin\

set epochNow="%gnuUtilpath%date.exe" +%%s
%epochNow% 
%epochNow% > epochNow.txt
cat epochNow.txt

set epochThen="%gnuUtilpath%date.exe" -d "01/01/2001" +%%s
%epochThen%
%epochThen% > epochThen.txt
cat epochThen.txt

for /f "delims=" %%x in ('cat epochThen.txt') do set "begin=%%x"
for /f "delims=" %%x in ('cat epochNow.txt') do set "end=%%x"

echo %begin%
echo %end%

set task="%gnuUtilpath%wget.exe"
for /f "delims=" %%x in ('getCrumb.bat') do set "crumb=%%x"
echo %crumb%

REM works
curl -s --cookie cookie.txt  "https://query1.finance.yahoo.com/v7/finance/download/%%5ESP500TR?period1=0978336000&period2=1532888283&interval=1d&events=history&crumb=%crumb%"

