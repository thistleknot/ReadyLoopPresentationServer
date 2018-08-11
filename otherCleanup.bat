
cd c:\test\share\other\

cmd.exe /c checkBad.bat	

echo f|xcopy reruns.txt c:\test\share\OtherReRuns.txt /y

REM one more time
cd c:\test\share\other\

cmd.exe /c checkbad.bat
cmd.exe /c parsereruns.bat
echo f|xcopy reruns.txt c:\test\otherSymbolsNoHeader.csv /y
erase c:\test\share\other\reruns.txt

cd c:\Users\user\Documents\alphaAdvantageApi\ReadyLoopPresentationServer
cmd.exe /c downloadDataOther.bat

cd c:\test\share\other\
cmd.exe /c checkbad.bat
cmd.exe /c parsereruns.bat

REM echo f|xcopy reruns.txt c:\test\nasdaqSymbolsNoHeader.csv /y /
REM erase c:\test\share\nasdaq\reruns.txt
cd c:\Users\user\Documents\alphaAdvantageApi\ReadyLoopPresentationServer