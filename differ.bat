@echo off
:files_differ

REM same
fc /b %1 %2 > nul
if errorlevel 1 echo 1
if errorlevel 1 echo 0
@echo on