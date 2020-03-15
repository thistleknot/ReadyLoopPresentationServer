
library(curl)

h <- new_handle()
handle_setopt(h, copypostfields = "moo=moomooo");
handle_setheaders(h,
                  "Connection" = "keep-alive",
                  "Upgrade-Insecure-Requests" = "1",
                  "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.132 Safari/537.36",
                  "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
                  "Referer" = "http://www.eoddata.com/stocklist/AMEX.htm",
                  "Accept-Language" = "en-US,en;q=0.9",
                  "Cookie" = "__gads=ID=34b33646e43a5e8a:T=1584200597:S=ALNI_MZSPTiq_oEn-X-Ox4_M16Y9muOftA; __utmc=264658075; ASP.NET_SessionId=0ywx04vl5kdxz302vvpxwl2c; _cb_ls=1; _cb=pdMIZDjryuYDiwerc; __utmz=264658075.1584289827.10.9.utmgclid=Cj0KCQjwpLfzBRCRARIsAHuj6qVtcvw-m6atGa4iJDzijltp4h_6Js4hB3gqjshRcAFjgIVO-aBisAgaAsJwEALw_wcB|utmccn=(not%20set)|utmcmd=(not%20set)|utmctr=(not%20provided); _gac_UA-2324239-1=1.1584289517.Cj0KCQjwpLfzBRCRARIsAHuj6qVtcvw-m6atGa4iJDzijltp4h_6Js4hB3gqjshRcAFjgIVO-aBisAgaAsJwEALw_wcB; __utma=264658075.929918524.1584200590.1584289827.1584293058.11; _cb_svref=null; __utmt=1; EODDataAdmin=26B43C757BC9EB48D0ADEB9E2C88D79D47EA565AC3DB58BD11074ABCEEA2A1792F5D934CB0E95A85698CFF7D9D3E5E5CEF1D58DB1A57E856E9FB072E3461B7180E99FC6B8F6B98D434829001335616B5588B105ACEA7AE04F88C9EAE9EC66211BD825CD4426AE3AC7CDFB1CA532EBA27B91433B21DFEB595E2F44E162A5FDDB8; __utmb=264658075.13.10.1584293058; _chartbeat2=.1584205900215.1584294783474.11.B0fEJNSK4WQBgN3GUCdwD2xBcbdPX.6; _chartbeat5=630,171,%2Fstocklist%2FAMEX.htm,http%3A%2F%2Fwww.eoddata.com%2FData%2Fsymbollist.aspx%3Fe%3DAMEX,BTKKAXBWRSjZBJYqPDgzh0227O5q,,c,Bd-R-C7fBK2DMQNIDD2kSxRCIHrBO,eoddata.com,"
)

req <- curl_fetch_memory("http://www.eoddata.com/Data/symbollist.aspx?e=AMEX", handle = h)
tmp <- tempfile()
#req <- curl_download("http://www.eoddata.com/Data/symbollist.aspx?e=AMEX", handle = h, tmp)
#tmp
con <- curl("http://www.eoddata.com/Data/symbollist.aspx?e=AMEX", handle = h)
#jsonlite::prettify(readLines(con))

read.table(file='/tmp/RtmpbXB9SD/file1317c608d33',sep='\t')
req <- curl_fetch_memory("https://eu.httpbin.org/get?foo=123")
str(req)
