@echo off
FOR /F "tokens=*" %%a in ('subcurrentdate.bat') do SET currentdate=%%a
echo %currentdate%
@echo on