@echo off

REM tail -n +2 | takes to long when removing header.
cut -f 1,2 -d "," ETFList.csv|sed 's/\"//g'
@echo on