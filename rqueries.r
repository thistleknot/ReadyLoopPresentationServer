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
