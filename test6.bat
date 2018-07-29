setlocal enableextensions enabledelayedexpansion

REM thank you
REM https://stackoverflow.com/questions/3454112/is-there-a-way-to-get-epoch-time-using-a-windows-command
set gnuUtilpath=c:\Program Files (x86)\coreutils-5.3.0-bin\bin\

set epochNow="%gnuUtilpath%date.exe" +%s
%epochNow% > epochNow.txt
cat epochNow.txt

set epochThen="%gnuUtilpath%date.exe" -d "01/01/2001" +%s
%epochThen% > epochThen.txt

set begin=|cat epochThen.txt
set end=|cat epochNow.txt

echo %begin% !begin!

REM thank you
REM https://stackoverflow.com/questions/3454112/is-there-a-way-to-get-epoch-time-using-a-windows-command
REM current date: gnudate +%s

REM thank you
REM https://stackoverflow.com/questions/10990949/convert-date-time-string-to-epoch-in-bash
REM date -d '06/12/2012 07:21:22' +"%s"
REM date -d '01/01/2000' +"%s"

REM https://www.gnu.org/software/coreutils/manual/html_node/Examples-of-date.html
REM date --date='1970-01-01 00:02:00 +0000' +%s
REM 120

REM Thank you
REM http://blog.bradlucas.com/posts/2017-06-02-new-yahoo-finance-quote-download-url/

REM 2012-12-31
REM https://query1.finance.yahoo.com/v7/finance/download/%5ESP500TR?period1=1356940800&period2=1522134000&interval=1d&events=history&crumb=XwK9tui4bLR
REM 2018-03-27

REM 2001-01-01
echo "https://query1.finance.yahoo.com/v7/finance/download/%5ESP500TR?period1=0%begin%&period2=%end%&interval=1d&events=history&crumb=XwK9tui4bLR"
REM 2018-03-27


REM curl -s --cookie-jar cookie.txt https://finance.yahoo.com/quote/%5ESP500TR?p=%5ESP500TR > ESP500TR.html

set downloadSP=curl -L -s --cookie-jar $cookieJar https://finance.yahoo.com/quote/%5ESP500TR?p=%5ESP500TR)
%downloadSP%

echo "https://query1.finance.yahoo.com/v7/finance/download/%5ESP500TR?period1=%begin%&period2=%end%&interval=1d&events=history&crumb=XwK9tui4bLR"

echo "https://query1.finance.yahoo.com/v7/finance/download/%5ESP500TR?period1=!begin!&period2=!end!&interval=1d&events=history&crumb=XwK9tui4bLR"

REM curl "https://query1.finance.yahoo.com/v7/finance/download/%5ESP500TR?period1=1356940800&period2=1522134000&interval=1d&events=history&crumb=XwK9tui4bLR"
echo "https://query1.finance.yahoo.com/v7/finance/download/%5ESP500TR?period1=1356940800&period2=1522134000&interval=1d&events=history&crumb=XwK9tui4bLR"

REM https://finance.yahoo.com/quote/%5ESP500TR?p=%5ESP500TR

rEM curl https://finance.yahoo.com/quote/GOOG?p=GOOG > goog.html

REM curl https://finance.yahoo.com/quote/%5ESP500TR?p=%5ESP500TR > ESP500TR.html
cat ESP500TR.html| tr "}" "\n" | grep CrumbStore | cut -d':' -f 3 | sed 's+"++g'

REM echo "$(curl -s --cookie-jar $cookieJar https://finance.yahoo.com/quote/%5ESP500TR?p=%5ESP500TR)"

REM https://query1.finance.yahoo.com/v7/finance/download/%5ESP500TR?period1=1356940800&period2=1522134000&interval=1d&events=history&crumb=XwK9tui4bLR


echo "https://query1.finance.yahoo.com/v7/finance/download/%5ESP500TR?period1=!begin!&period2=!end!&interval=1d&events=history&crumb=XwK9tui4bLR"

