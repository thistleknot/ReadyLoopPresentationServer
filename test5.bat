setlocal enableextensions enabledelayedexpansion
set /p lessThan=|printf '\74'
echo UPDATE custom_calendar SET prev_trading_day = PTD.ptd FROM (SELECT date, (SELECT MAX(CC.date) FROM custom_calendar CC WHERE CC.trading=1 AND CC.date%%lessThan%%custom_calendar.date) ptd FROM custom_calendar) PTD WHERE custom_calendar.date = PTD.date;| psql -U postgres -h %host% %dbName%
	