@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
for /F "delims=;" %a in (c:\test\nasdaqSymbolsNoHeader.csv) do (
  set temp=%%~nX
  echo !temp!
)