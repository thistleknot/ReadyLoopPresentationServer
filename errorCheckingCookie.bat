set reset=1


inbetween

for /f "delims=" %%z in ('differ.bat c:\test\ETF-%%a.csv c:\test\invalidCookie.txt') do (set "reset='hello'")
	echo "value of test"
	echo !reset!
	echo "after report of value"
	:while
	If !reset! equ "0" (
		echo "inside"
		
		for /f "delims=" %%y in ('getCrumb.bat %%a') do set "crumb2=%%y"
		start call subDownloadBonds.bat %%a %begin% %end% !crumb2!
		echo %%a %begin% %end% !crumb2!
		
		Goto :while
	   )