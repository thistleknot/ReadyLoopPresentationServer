@echo off
rem https://stackoverflow.com/questions/19393155/how-to-randomly-rearrange-lines-in-a-text-file-using-a-batch-file
setlocal
for /f "delims=" %%a in (%1) do call set "$$%%random%%=%%a"
(for /f "tokens=1,* delims==" %%a in ('set $$') do echo(%%b) > %2
endlocal
)