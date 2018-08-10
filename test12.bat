REM FOR /F "tokens=*" %%a in ('returnNumLines.bat apiKey.txt') do SET numKeys=%%a
FOR /F "tokens=*" %%a in ('differ.bat c:\test\share\nasdaq\NS-YNDX.csv c:\test\share\diffComparison') do SET delta=%%a
echo %delta%
if(%delta%=="") echo "erase"