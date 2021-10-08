FORMAT_LL_LCOMP<-function(data=LL_LCOMP,seas=1,flt=5,gender=0,part=0,Nsamp=60){

    years<-unique(data$YEAR)
    bins<-unique(data$BIN)
    
    N_TOTAL<-aggregate(list(T_NUMBER=data$TOTAL),by=list(YEAR=data$YEAR),FUN=sum)
    data<-merge(data,N_TOTAL)
    data$PROP<-data$UNSEXED/data$T_NUMBER
 


    nbin=length(bins)
    nyr<-length(years)
    x<-matrix(ncol=((2*nbin)+6),nrow=nyr)
    x[,2]<-seas
    x[,3]<-flt
    x[,4]<-gender
    x[,5]<-part
    x[,6]<-Nsamp
    
    for(i in 1:nyr){
      x[i,1]<-years[i]

      x[i,7:(nbin+6)]<-round(data$PROP[data$YEAR==years[i]],4)

      x[i,(nbin+7):((2*nbin)+6)]<- -1
      }
      x
    }