@echo off
:files_differ
echo 0

REM same
fc /b %1 %2 > nul
if errorlevel 1 echo 1
@echo on