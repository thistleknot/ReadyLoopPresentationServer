@echo off
set PGPASSWORD=Read1234
set host=192.168.1.5
set dbName=readyloop
ECHO SELECT CURRENT_DATE;| psql -U postgres -h %host% %dbName%
@echo on
