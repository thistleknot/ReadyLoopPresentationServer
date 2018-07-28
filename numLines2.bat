@echo off
set /a counter=0
for /f %%a in (%1) do set /a counter+=1
echo %counter%
