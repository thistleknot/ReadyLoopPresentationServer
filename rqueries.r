non repeating random numbers
sample.int(10, 10)

ShortCurcuit
RpM<-RbM_training
RpM$ptf<-RaM_training %*% opt_wM
chart.CumReturns(RpM,legend.loc = 'topleft')
Return.cumulative(RpM)


#
RpM<-RbM_testing 
RpM$ptf<-RaM_testing %*% opt_wM
chart.CumReturns(RpM,legend.loc = 'topleft')
Return.cumulative(RpM)


RpM<-RbM_testing 
RpM$ptf<-RaM_testing %*% opt_wM
chart.CumReturns(RpM,legend.loc = 'topleft')
Return.cumulative(RpM)

#r queries
testing<-eod[which(eod$date=='2013-03-30'),,]