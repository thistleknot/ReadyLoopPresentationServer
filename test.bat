set /A i=0
echo off
for /F "delims=;" %%a in (c:\test\nasdaqSymbolsNoHeader.csv) do (

set /A i+=1
call set n=%%i%%

)
call echo %n%