fc /b %1 c:\test\share\diffComparison > nul
if errorlevel 1 (
    echo different
) else (
    erase %1
)