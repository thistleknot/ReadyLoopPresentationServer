REM SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "tokens=*" %%a in ('returnNumLines.bat c:\test\nasdaqSymbolsNoHeader.csv') do SET numLines=%%a
REM echo %numKeys%


FOR /L %%i IN (1,1,%numLines%) DO (

	REM ECHO %%i
	returnLine.bat %%i c:\test\nasdaqSymbolsNoHeader.csv;

  
)	