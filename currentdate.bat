@echo off
set PGPASSWORD=1234
set dbName=readyloop
ECHO SELECT CURRENT_DATE;| psql -U postgres %dbName%
@echo on
