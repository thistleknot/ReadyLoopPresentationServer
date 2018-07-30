echo %1
@echo off
curl -s --cookie-jar cookie.txt https://finance.yahoo.com/quote/%1?p=%1| tr "}" "\n" | grep CrumbStore | cut -d':' -f 3 | sed 's+"++g'
type cookie.txt
@echo on