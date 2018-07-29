# Part 3c

# Stock Market Case in R
rm(list=ls(all=T)) # this just removes everything from memory

# Load CSV Files ----------------------------------------------------------

# Load daily prices from CSV - no parameters needed
dp<-read.csv('C:/Test/daily_prices.csv') # no arguments
dp<-read.csv('c:/test/export_daily_returns_2013_2017_2.csv')
dp<-read.csv('c:/test/export_monthly_returns_2013_2017_2.csv')
dpmine<-read.csv('c:/test/export_daily_returns_2013_2017.csv')

#Explore
head(dp) #first few rows
tail(dp) #last few rows
nrow(dp) #row count
nrow(dpmine) #row count


#This is an easy way (csv) but we are not going to use it here
rm(dp) # remove from memory
#We are going to perform most of the transformation tasks in R

# Connect to PostgreSQL ---------------------------------------------------

# Make sure you have created the reader role for our PostgreSQL database
# and granted that role SELECT rights to all tables
# Also, make sure that you have completed (or restored) Part 3b db

require(RPostgreSQL) # did you install this package?
require(DBI)
pg = dbDriver("PostgreSQL")
conn = dbConnect(drv=pg
                 ,user="stockmarketreader"
                 ,password="read123"
                 ,host="localhost"
                 ,port=5432
                 ,dbname="stockmarket"
)

#custom calendar

#qry='SELECT * FROM custom_calendar ORDER by date'
qry="select * from custom_calendar where date between '2012-12-30' AND '2018-03-27' "
qry4tdays="select * from custom_calendar where date between '2012-12-30' AND '2018-03-27' "
ccal<-dbGetQuery(conn,qry)
ccal4tdays<-dbGetQuery(conn,qry4tdays)
#eod prices and indices
qry1="SELECT symbol,date,adj_close FROM eod_indices WHERE date BETWEEN '2012-12-30' AND '2018-03-27'"
qry2="SELECT ticker,date,adj_close FROM eod_quotes WHERE date BETWEEN '2012-12-30' AND '2018-03-27'"
eod<-dbGetQuery(conn,paste(qry1,'UNION',qry2))
dbDisconnect(conn)

min(eod$date)
max(eod$date)
min(ccal4tdays$date)
max(ccal4tdays$date)
require(RPostgreSQL) # did you install this package?
require(DBI)
pg = dbDriver("PostgreSQL")
conn = dbConnect(drv=pg
                 ,user="readyloop"
                 ,password="read123"
                 ,host="localhost"
                 ,port=5432
                 ,dbname="readyloop"
)

#my own db
#custom calendar
qry="SELECT * FROM custom_calendar WHERE date BETWEEN '2012-12-30' AND '2018-07-28' ORDER by date"
ccalMine<-dbGetQuery(conn,qry)
#eod prices and indices
qry1="SELECT symbol,timestamp,adjusted_close FROM dadjclose WHERE timestamp BETWEEN '2012-12-30' AND '2018-07-28'"
eodMine<-dbGetQuery(conn,paste(qry1))
dbDisconnect(conn)

min(ccalMine$date)
max(ccalMine$date)
max(ccalMine$date)
min(eodMine$timestamp)
min(ccal4tdays$date)
max(ccal4tdays$date)
min(ccal@date)
min(eod$date)

#Explore
head(ccal)
tail(ccal)
nrow(ccal)

head(eod)
tail(eod)
nrow(eod)

head(eod[which(eod$symbol=='SP500TR'),])
tail(eod[which(eodMine$symbol=='SP500TR'),])

#For monthly we may need one more data item (for 2011-12-30)
#We can add it to the database (INSERT INTO) - but to practice:
#eod_row<-data.frame(symbol='SP500TR',date=as.Date('2012-12-30'),adj_close=2158.94)
#eod<-rbind(eod,eod_row)
#tail(eod)

# Use Calendar --------------------------------------------------------

#tdays<-ccal[which(ccal$trading==1),,drop=F]
tdays<-ccal4tdays[which(ccal4tdays$trading==1),,drop=F]
tdaysMine<-ccalMine[which(ccalMine$trading==1),,drop=F]
mdays<-ccal4tdays[which(ccal4tdays$trading==1 & ccal4tdays$eom==1),,drop=F]
mdaysMine<-ccalMine[which(ccalMine$trading==1 & ccalMine$eom==1),,drop=F]


min(tdays$date)
min(tdaysMine$date)
max(tdays$date)
max(tdaysMine$date)
max(mdaysMine$date)

head(mdays)
head(tdays)
nrow(tdays)-1
(nrow(tdaysMine)-1)

# Completeness ----------------------------------------------------------
# Percentage of completeness

max(table(eodMine$symbol))

#(nrow(tdays)-1)/max(table(eod$symbol))
#((nrow(tdaysMine)-1))/max(table(eodMine$symbol))
pct<-table(eod$symbol)/(nrow(tdays)-1)
pctMine<-table(eodMine$symbol)/(nrow(tdaysMine)-1)
selected_symbols_daily<-names(pct)[which(pct>=0.99)]
#this is my own nasdaq data 
selected_symbols_dailyMine<-names(pctMine)[which(pctMine>=0.99)]
length(selected_symbols_daily)
length(selected_symbols_dailyMine)

#no monthly?
eod_complete<-eod[which(eod$symbol %in% selected_symbols_daily),,drop=F]
eod_completeMine<-eodMine[which(eodMine$symbol %in% selected_symbols_dailyMine),,drop=F]

#check
head(eod_complete)
tail(eod_complete)
nrow(eod_complete)

#YOUR TURN: perform all these operations for monthly data
#Create eom and eom_complete
#Hint: which(ccal$trading==1 & ccal$eom==1)

# Transform (Pivot) -------------------------------------------------------

require(reshape2) #did you install this package?
eod_pvt<-dcast(eod_complete, date ~ symbol,value.var='adj_close',fun.aggregate = mean, fill=NULL)
#mine uses timestamp
eod_pvtMine<-dcast(eod_completeMine, timestamp ~ symbol,value.var='adjusted_close',fun.aggregate = mean, fill=NULL)
#check
eod_pvt[1:10,1:5] #first 10 rows and first 5 columns 
eod_pvtMine[1:10,1:5]
ncol(eod_pvt) # column count
nrow(eod_pvt)

# YOUR TURN: Perform the same set of tasks for monthly prices (create eom_pvt)

# Merge with Calendar -----------------------------------------------------
eod_pvt_complete<-merge.data.frame(x=tdays[,'date',drop=F],y=eod_pvt,by='date',all.x=T)
eom_pvt_complete<-merge.data.frame(x=mdays[,'date',drop=F],y=eod_pvt,by='date',all.x=T)

#doesn't work (this is not project related)
#eod_pvt_completeMine<-merge.data.frame(x=tdaysMine[,'date',drop=F],y=eod_pvtMine,by='timestamp',drop=F],all.x=T)


#check
eod_pvt_complete[1:10,1:5] #first 10 rows and first 5 columns
eom_pvt_complete[1:10,1:5] #first 10 rows and first 5 columns 
#eod_pvt_completeMine[1:10,1:5] #first 10 rows and first 5 columns

ncol(eod_pvt_complete)
ncol(eom_pvt_complete)
nrow(eod_pvt_complete)
nrow(eom_pvt_complete)

#use dates as row names and remove the date column
rownames(eod_pvt_complete)<-eod_pvt_complete$date
rownames(eom_pvt_complete)<-eom_pvt_complete$date
eod_pvt_complete$date<-NULL
eom_pvt_complete$date<-NULL

#re-check
eod_pvt_complete[1:10,1:5] #first 10 rows and first 5 columns 
ncol(eod_pvt_complete)
nrow(eod_pvt_complete)

# Missing Data Imputation -----------------------------------------------------
# We can replace a few missing (NA or NaN) data items with previous data
# Let's say no more than 3 in a row...
require(zoo)
eod_pvt_complete<-na.locf(eod_pvt_complete,na.rm=F,fromLast=F,maxgap=3)
eom_pvt_complete<-na.locf(eom_pvt_complete,na.rm=F,fromLast=F,maxgap=3)

#eod_pvt_completeMine<-na.locf(eod_pvt_completeMine,na.rm=F,fromLast=F,maxgap=3)


#re-check
eod_pvt_complete[1:10,1:5] #first 10 rows and first 5 columns 
ncol(eod_pvt_complete)
nrow(eod_pvt_complete)

# Calculating Returns -----------------------------------------------------
require(PerformanceAnalytics)
eod_ret<-CalculateReturns(eod_pvt_complete)
eom_ret<-CalculateReturns(eom_pvt_complete)

eod_retMine<-CalculateReturns(eod_pvt_completeMine)


#check
eod_ret[1:10,1:5] #first 10 rows and first 5 columns
eom_ret[1:10,1:5] #first 10 rows and first 5 columns 
ncol(eod_ret)
nrow(eod_ret)

#remove the first row
eod_ret<-tail(eod_ret,-1) #use tail with a negative value
eom_ret<-tail(eom_ret,-1) #use tail with a negative value
#eod_retMine<-tail(eod_retMine,-1) #use tail with a negative value
#check
eod_ret[1:10,1:5] #first 10 rows and first 5 columns 
ncol(eod_ret)
nrow(eod_ret)

# YOUR TURN: calculate eom_ret (monthly returns)

# Check for extreme returns -------------------------------------------
# There is colSums, colMeans but no colMax so we need to create it
colMax <- function(data) sapply(data, max, na.rm = TRUE)
# Apply it
max_daily_ret<-colMax(eod_ret)
max_monthly_ret<-colMax(eom_ret)

max_daily_ret[1:10] #first 10 max returns
max_monthly_ret[1:10] #first 10 max returns

# And proceed just like we did with percentage (completeness)
selected_symbols_daily<-names(max_daily_ret)[which(max_daily_ret<=1.00)]
selected_symbols_monthly<-names(max_monthly_ret)[which(max_monthly_ret<=1.00)]

length(selected_symbols_daily)
length(selected_symbols_monthly)

#subset eod_ret
eod_ret<-eod_ret[,which(colnames(eod_ret) %in% selected_symbols_daily)]
eom_ret<-eom_ret[,which(colnames(eom_ret) %in% selected_symbols_monthly)]
#check
eod_ret[1:10,1:5] #first 10 rows and first 5 columns 
eom_ret[1:10,1:5] #first 10 rows and first 5 columns
ncol(eod_ret)
ncol(eom_ret)

nrow(eod_ret)
nrow(eom_ret)

#YOUR TURN: subset eom_ret data

# Export data from R to CSV -----------------------------------------------
write.csv(eod_ret,'C:/Test/eod_ret.csv')
write.csv(eom_ret,'C:/Test/eom_ret.csv')



# You can actually open this file in Excel!


# Tabular Return Data Analytics -------------------------------------------

# We will select 'SP500TR' and c('AEGN','AAON','AMSC','ALCO','AGNC','AREX','ABCB','ABMD','ACTG','ADTN','AAPL','AAL')
# We need to convert data frames to xts (extensible time series)
Ra<-as.xts(eod_ret[,c('AEGN','AAON','AMSC','ALCO','AGNC','AREX','ABCB','ABMD','ACTG','ADTN','AAPL','AAL'),drop=F])

RaM<-as.xts(eom_ret[,c('L','LABL','LAD'),drop=F])


print(colnames(eom_ret))
Rb<-as.xts(eod_ret[,'SP500TR',drop=F]) #benchmark
RbM<-as.xts(eom_ret[,'SP500TR',drop=F]) #benchmark

head(Ra)
head(Rb)

# And now we can use the analytical package...

# Stats
table.Stats(Ra)
table.Stats(Rb)
table.Stats(RaM)

# Distributions
table.Distributions(Ra)
table.Distributions(RaM)

# Returns
table.AnnualizedReturns(cbind(Rb,Ra),scale=252) # note for monthly use scale=12
table.AnnualizedReturns(cbind(RbM,RaM),scale=12) # note for monthly use scale=12

# Accumulate Returns

acc_Ra<-Return.cumulative(Ra)
acc_RaM<-Return.cumulative(RaM)

acc_Rb<-Return.cumulative(Rb)
acc_RbM<-Return.cumulative(RbM)

# Capital Assets Pricing Model
table.CAPM(Ra,Rb)
table.CAPM(RaM,RbM)

# YOUR TURN: try other tabular analyses

# Graphical Return Data Analytics -----------------------------------------

# Cumulative returns chart
chart.CumReturns(Ra,legend.loc = 'topleft')
chart.CumReturns(RaM,legend.loc = 'topleft')

chart.CumReturns(Rb,legend.loc = 'topleft')
chart.CumReturns(RbM,legend.loc = 'topleft')

#Box plots
chart.Boxplot(cbind(Rb,Ra))

chart.Boxplot(cbind(RbM,RaM))

chart.Drawdown(Ra,legend.loc = 'bottomleft')

# YOUR TURN: try other charts

# MV Portfolio Optimization -----------------------------------------------

# withold the last 252 trading days
Ra_training<-head(Ra,-252)
RaM_training<-head(RaM,-3)

Rb_training<-head(Rb,-252)
RbM_training<-head(RbM,-3)

# use the last 252 trading days for testing
Ra_testing<-tail(Ra,252)
RaM_testing<-tail(RaM,3)

Rb_testing<-tail(Rb,252)
RbM_testing<-tail(RbM,3)

#optimize the MV (Markowitz 1950s) portfolio weights based on training
table.AnnualizedReturns(Rb_training)
table.AnnualizedReturns(RbM_training)

mar<-mean(Rb_training) #we need daily minimum acceptabe return
marM<-mean(RbM_training) #we need daily minimum acceptabe return

require(PortfolioAnalytics)
require(ROI) # make sure to install it
require(ROI.plugin.quadprog)  # make sure to install it

#names pulled from colnames
pspec<-portfolio.spec(assets=colnames(Ra_training))
pspecM<-portfolio.spec(assets=colnames(RaM_training))

#objectives and constraints
#markowitz portfolio
#reduce variation
pspec<-add.objective(portfolio=pspec,type="risk",name='StdDev')
pspecM<-add.objective(portfolio=pspecM,type="risk",name='StdDev')

#all weights must add to 1, not specifying mandatory positive
pspec<-add.constraint(portfolio=pspec,type="full_investment")
pspec<-add.constraint(portfolio=pspecM,type="full_investment")

pspecM<-add.constraint(portfolio=pspec,type="return",return_target=mar)
pspecM<-add.constraint(portfolio=pspecM,type="return",return_target=marM)

#optimize portfolio
opt_p<-optimize.portfolio(R=Ra_training,portfolio=pspec,optimize_method = 'ROI')
opt_pM<-optimize.portfolio(R=RaM_training,portfolio=pspecM,optimize_method = 'ROI')

#extract weights
#negative weights = short
opt_w<-opt_p$weights
opt_wM<-opt_pM$weights

#apply weights to test returns
Rp<-Rb_testing # easier to apply the existing structure
RpM<-RbM_testing # easier to apply the existing structure
#define new column that is the dot product of the two vectors
Rp$ptf<-Ra_testing %*% opt_w
RpM$ptf<-RaM_testing %*% opt_wM


#check
head(Rp)
head(RpM)
tail(RpM)

#Compare basic metrics
table.AnnualizedReturns(Rp)
table.AnnualizedReturns(RpM)

# Chart Hypothetical Portfolio Returns ------------------------------------

chart.CumReturns(RpM,legend.loc = 'topleft')

# End of Part 3c
# End of Stock Market Case Study 