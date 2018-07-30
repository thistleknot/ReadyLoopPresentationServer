Readme

Requires
	Gnuutils

	https://stackoverflow.com/questions/3454112/is-there-a-way-to-get-epoch-time-using-a-windows-command

	coreutils
	http://gnuwin32.sourceforge.net/packages/coreutils.htm

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
	
	https://www.programmableweb.com/news/96-stocks-apis-bloomberg-nasdaq-and-etrade/2013/05/22
	Quandl
		Quandl will handle ETF's
		see: https://blog.quandl.com/api-for-stock-data
		
		stocks (50 per day)
		https://blog.quandl.com/api-for-interest-rate-data
		
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
	REM acquire proxies from: https://free-proxy-list.net/anonymous-proxy.html#
	REM format of file ip:port


Dependencies

	PopulateDb.bat
		parsedata.bat
			download.bat
		
		subcurrentdate.bat
			currentdate.bat

		dlSP500.bat
			getCrumb.bat
			
		downloadBonds.bat
			getCrumb.bat