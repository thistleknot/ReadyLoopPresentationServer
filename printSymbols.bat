@echo off
FOR /L %%G IN (1,1,255) DO (
echo %%G
printf '\%%G'

)
@echo on