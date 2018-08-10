fc /b %1 c:\test\share\diffComparisonETF > nul
if errorlevel 1 (
    echo different
) else (
    erase %1
	echo %1 >> reruns.txt
)