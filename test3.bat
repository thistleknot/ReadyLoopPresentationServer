setlocal enableextensions enabledelayedexpansion
set /a count = 1
for /F "delims=;" %%a in (c:\test\nasdaqSymbolsNoHeader.csv) do (
	@echo off
  set /a count += 1
	@echo on
  echo !count!
  REM echo %%a
)
endlocal