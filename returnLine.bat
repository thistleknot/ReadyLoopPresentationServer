echo off
set line=%1
set "file=%2"
set /A i=0

for /F "usebackq delims=" %%a in ("%file%") do (
set /A i+=1
call set array[%%i%%]=%%a
call set n=%%i%%
)

call echo %%array[%1]%%
