Readme

ToDo
	code changes

	replace ip's with a source file that is called from all files

password for server is set to 
	Read1234
	
	populateDB.bat
		host
			192.168.3.103
			
			user of container
			postgres
			Read1234
			
			rstudio
			1234

Important variables
	add to path	
		C:\Users\user\Documents\GitHub\ReadyLoopPresentationServer

stockmarketRCode
	setPercent,
	set to the % of top and bottom performers you wish to capture.  If set to 1%, it will capture the top 1% of the symbols and bottom 1% of the symbols to build hold/short profiles from.
	

History info

	only 3 pages
	useful to track what tickers to repull
	https://www.nasdaq.com/markets/stocks/symbol-change-history.aspx?page=3
	
	#possible way to scrape tables using gnu commands
	
		https://stackoverflow.com/questions/1403087/how-can-i-convert-an-html-table-to-csv

Requires

	7-zip
		C:\Program Files\7-Zip - path

	imagemagick
	
	coreutils
		http://gnuwin32.sourceforge.net/packages/coreutils.htm
	
		#gnuUtilpath=c:\Program Files (x86)\coreutils-5.3.0-bin\bin\

	set gnuUtilpath=c:\Program Files (x86)\GnuWin32\bin\

	psql needs to be accessible by path
		C:\Program Files\PostgreSQL\12\bin

	#needed for populateDB and other scripts, but not insertQs
	#mingw
		#msys
		
	curl
		#mingw
			#https://sourceforge.net/projects/mingw-w64/
	
		https://curl.haxx.se/windows/
		
		https://gitforwindows.org/
		
			add to path
			C:\Program Files\Git\mingw64\bin
	
	awk
		http://gnuwin32.sourceforge.net/packages/gawk.htm
		
		#gnuwin32
			http://gnuwin32.sourceforge.net/
	
		git for windows
		
			add to path
			
			C:\Program Files\Git\usr\bin\

	Add readyloop to path
	
	Gnuutils

	https://stackoverflow.com/questions/3454112/is-there-a-way-to-get-epoch-time-using-a-windows-command

	date requires
		libintl
		http://gnuwin32.sourceforge.net/packages/libintl.htm

		libiconv
		http://gnuwin32.sourceforge.net/packages/libiconv.htm

	Just download all 3, extract each so the extracted subfolders merge into one folder each zip contains eithe additive or the same folder names as coreutils). then you can run date +%2
	
	Wget (arguably no longer used)
	
		Requires
		https://astuteinternet.dl.sourceforge.net/project/gnuwin32/wget/1.11.4-1/wget-1.11.4-1-bin.zip
		
		http://downloads.sourceforge.net/gnuwin32/wget-1.11.4-1-dep.zip

NiFi/command line function
	yahoo finance "invoke-webrequest : { "finance": { "error": { "code": "Unauthorized", "description": "Invalid cookie" }"
	might be able to be used for redirects
		
Areas to look into
	Bloomberg terminal (am I rebuilding a bloomberg terminal?)
	alternative to 24,000/year
		
potential sources

	Market watch
	
		https://www.marketwatch.com/investing
		stock market simulator
		
		#simulators
		https://corporatefinanceinstitute.com/resources/knowledge/trading-investing/three-best-stock-simulators/
		
	Calendar
		great list of holidays for scraping!
		supports up to 1990
			http://www.market-holidays.com/
			https://www.timeanddate.com/holidays/us/2013
		
			has future dates
			https://www.nyse.com/markets/hours-calendars

	ETF Historical Prices and ratings (speculative, investment grade)
		see: https://www.pimco.com/en-us/resources/education/understanding-corporate-bonds/
		see: https://www.investopedia.com/financial-edge/0612/how-to-invest-in-corporate-bonds.aspx
		
	Yahoo
		S&P500
		https://finance.yahoo.com/quote/%5ESP500TR/history?period1=1325404800&period2=1514707200&interval=1d&events=history
		
		w/crumb
		"https://query1.finance.yahoo.com/v7/finance/download/%5ESP500TR?period1=0978336000&period2=1532971622&interval=1d&events=history&crumb=7Kqn5pS8WVy"
		
		HECO Corporate Bond
		https://finance.yahoo.com/quote/HECO/history?period1=1325404800&period2=1514707200&interval=1d&filter=history&frequency=1d
		
		w/crumb
		https://query1.finance.yahoo.com/v7/finance/download/HECO?period1=1325404800&period2=1514707200&interval=1d&events=history&crumb=XwK9tui4bLR		

		#they have a cboe list
		https://quant.stackexchange.com/questions/26162/where-can-i-get-a-list-of-all-yahoo-finance-stocks-symbols
		
		https://quant.stackexchange.com/questions/1640/where-to-download-list-of-all-common-stocks-traded-on-nyse-nasdaq-and-amex
		
		http://www.eoddata.com/symbols.aspx
			NYSE: http://www.eoddata.com/Data/symbollist.aspx?e=NYSE
			registration required
			
			allows me to download the entire nyse eoddata.  Not sure how to incorporate into splits or if it's necessary.  Very useful if I wish to maintain daily updates on say the nasdaq.  Requires manual download (or email?).
			
			has access to past 21 trading days (past month of data).  would only require a onetime manual update per month.
		
		http://markets.cboe.com/us/equities/market_statistics/
		
		https://stackoverflow.com/questions/5246843/how-to-get-a-complete-list-of-ticker-symbols-from-yahoo-finance		
	
	https://www.programmableweb.com/news/96-stocks-apis-bloomberg-nasdaq-and-etrade/2013/05/22
	https://www.quantshare.com/sa-620-10-new-ways-to-download-historical-stock-quotes-for-free
	
	Quandl
		Quandl will handle ETF's
		see: https://blog.quandl.com/api-for-stock-data
		
		stocks (50 per day)
		https://blog.quandl.com/api-for-interest-rate-data

	https://www.quantshare.com/sa-636-6-new-ways-to-download-free-intraday-data-for-the-us-stock-market
	https://www.quantshare.com/sa-620-10-new-ways-to-download-historical-stock-quotes-for-free
		
	Quantpedia
		tons of api sources as well as csv pubs
		https://quantpedia.com/Links/HistoricalData
		
	Use Quandl (if the script was't broken, might be easier to fix script than recoding an ETL)
		https://www.quantshare.com/title-95-export-to-csv-the-whole-database-including-symbols
		
	FRED
	AlphaAdvantage
	https://www.nasdaq.com/investing/etfs/etf-finder-results.aspx?download=Yes
	
	Bond Market in general (Aggregate)
		https://fred.stlouisfed.org/categories/32348/downloaddata
		https://www.treasury.gov/resource-center/data-chart-center/digitalstrategy/pages/developer.aspx
	
	Not very good
		http://etfdb.com/etfdb-category/corporate-bonds/
		https://www.ishares.com/us/products/290144/
		https://intrinio.com/ (paid)
			specifically bonds
			
		Municipal bonds
			https://emma.msrb.org/
			http://www.municipalbonds.com/
			
			Resources for bonds: https://learnbonds.com/5810/free-resources-for-bond-investors/#16
				lacking etf and historical keywords
			
		https://www.historicalstockprice.com/history/?a=historical&ticker=LQD&month=07&day=25&year=2018&x=17&y=6
	
	https://www.nasdaq.com/symbol/vcsh/historical
	
	https://www.quandl.com/data/PE?utm_source=google&utm_medium=organic&utm_campaign=&utm_content=api-for-stock-data

	Possible sources
		https://www.investing.com/etfs/ishares-inv-g-bond-historical-data
		can't seem to access file, even using cookies method
			sample java link: blob:https://www.investing.com/8de41496-fdc2-4a00-b61a-19fd0d843452
		
API's	
	https://www.programmableweb.com/news/96-stocks-apis-bloomberg-nasdaq-and-etrade/2013/05/22
	Quandl
	Alphadvantage
	yahoo finance
	
Configuration
	populdateDB.bat
		gnuUtilpath=c:\Program Files (x86)\coreutils-5.3.0-bin\bin\

APIKey.txt
	This is where you put your API keys

psqlpw.txt
	This is where you put your postgresql pw

proxylist.txt	
	REM acquire [US] proxies from: https://free-proxy-list.net/anonymous-proxy.html#
	REM format of file ip:port

Add readylooppresentationserver to path	
	
populateDB2.bat
	use with quantshare csv
	
	insertQs.bat
	InsertIndices.bat
	calender.bat
	
Dependencies

	PopulateDb.bat 
	
		InsertIndice.bat
	
		generates: ETFNamesSymbols.txt
		
		calendar.bat
		
		insertQs.bat
			#used for importing quantshare data
			#use quantshareExportfunction.cs in quantshare
			#create directory quantshare in c:\users\user\documents\
		
		downloadBonds.bat
		
		DownloadDataNasdaq.bat (Nasdaq)
			downloadAlphaNasdaq.bat 
			
			 c:\test\nasdaqSymbolsNoHeader.csv
			 c:\test\otherSymbolsNoHeader.csv
			 c:\test\ETFNamesSymbolsNoHeader.csv
			 
			nasdaqCleanup.bat
			
		DownloadDataOther.bat (DOW,NYSE)
			downloadAlphaOther.bat 
			
			c:\test\otherSymbolsNoHeader.csv
			
			otherCleanup.bat
				
		subcurrentdate.bat
			currentdate.bat

		dlSP500.bat
			getCrumb.bat
		
			downloadBonds.bat (ETF Bond Markets)
				subdownloadBonds.bat
					getCrumb.bat
				
			insertBonds.bat
				etfNamesSymbols.bat
				etfNamesSymbols2.bat
			
		insertNasdaq.bat
			nasdaqSymbols.bat
	
		checkBad.bat
			differ2.bat
			
			relies on c:\test\share\diffComparison'
			
		checkBadETF.bat
			differETF.bat
			
			to rerun
			parsereruns.bat
			xcopy reruns.txt to c:\test\ETFNamesSymbolsNoHeader.csv /y
			downloadBonds.bat