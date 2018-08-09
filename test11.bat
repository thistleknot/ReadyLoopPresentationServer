				SET /A test=%RANDOM% * 20 / 32768 + 1
				
				FOR /F "tokens=*" %%b in ('returnLine.bat %test% proxyList.txt') do SET PROXY=%%b