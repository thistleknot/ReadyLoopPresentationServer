@echo off
wc -l %1 > temp.txt
cut -d ' ' -f 1 < temp.txt
erase temp.txt
@echo on


