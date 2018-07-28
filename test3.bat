setlocal enableextensions enabledelayedexpansion
set /a count = 1
for /F "delims=;" %%a in (c:\test\nasdaqSymbolsNoHeader.csv) do (
	
  
	echo !count!
@echo off
	if !count! == 3 (set /a count = 0)
	if not !count! == 3 set /a count += 1
	
@echo on
  
  
	
)
endlocal
