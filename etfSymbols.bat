@echo off
tail -n +2 | cut -f 1 -d "," ETFList.csv|sed 's/\"//g'
@echo on