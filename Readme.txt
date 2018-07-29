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

