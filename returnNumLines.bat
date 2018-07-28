@echo off
setlocal enableextensions enabledelayedexpansion
find /c /v "" %1 > temp.txt
awk '{ print $NF }' temp.txt
@echo on