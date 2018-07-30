@echo off
tail -n +2 ETFlist.csv|sed 's/\"//g'
@echo on