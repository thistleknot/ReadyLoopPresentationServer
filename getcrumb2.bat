@echo off
curl -s --cookie-jar cookie.txt https://finance.yahoo.com/quote/HDGE?p=HDGE| tr "}" "\n" | grep CrumbStore | cut -d':' -f 3 | sed 's+"++g'
@echo on