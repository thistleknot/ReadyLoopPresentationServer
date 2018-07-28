REM SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "tokens=*" %%a in ('numLines2.bat c:\test\aobc.csv') do SET numKeys=%%a
REM echo %numKeys%


FOR /L %%i IN (1,1,%numKeys%) DO (

	REM ECHO %%i
	returnLine.bat %%i c:\test\nasdaqSymbolsNoHeader.csv;

  
)	