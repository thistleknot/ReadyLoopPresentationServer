curl -s --cookie-jar cookie.txt https://finance.yahoo.com/quote/%%5ESP500TR?p=%%5ESP500TR| tr "}" "\n" | grep CrumbStore | cut -d':' -f 3 | sed 's+"++g'