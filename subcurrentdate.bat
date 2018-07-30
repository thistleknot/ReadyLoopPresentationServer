@echo off
currentdate.bat|tail -3|head -1|sed "s/^[ \t]*//"
@echo on