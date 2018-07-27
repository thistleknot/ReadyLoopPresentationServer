SETLOCAL ENABLEDELAYEDEXPANSION
SET count=1
FOR /f "tokens=*" %%G IN ('type c:\test\nasdaqSymbolsNoHeader.csv') DO (

REM call :s_do_sums "%%G"'
call :s_do_sums "%%G"' > test.txt
type test.txt

REM doesn't work
set e=|type test.txt
REM echo %e% > test2.txt
echo !e!
type test2.txt
)
GOTO :eof

:s_do_sums
 echo %count%
 set /a count+=1
 GOTO :eof