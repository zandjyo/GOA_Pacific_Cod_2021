 # adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

FORMAT_ACOMP <- function(data=BS_ACOMP,max_age=max_age,len_bins=seq(1,100,1),seas=1,flt=3,gender=3,part=0,Ageerr=2,Lbin_lo=1,Lbin_hi=-1,Nsamp=100)
{

    years<-unique(data$YEAR)
    bins<-unique(data$AGE)

    nbin<-length(bins)
    nyr<-length(years)
    
    x<-matrix(ncol=((2*nbin)+9),nrow=nyr)
    x[,2]<-seas
    x[,3]<-flt
    x[,4]<-gender
    x[,5]<-part
    x[,6]<-Ageerr
    x[,7]<-Lbin_lo
    x[,8]<-Lbin_hi
    x[,9]<-Nsamp
    
    for(i in 1:nyr)
    {
        x[i,1]<-years[i]

        x[i,10:(nbin+9)]<-data$F_PROP[data$YEAR==years[i]]

        x[i,(nbin+10):((2*nbin)+9)]<-data$M_PROP[data$YEAR==years[i]]
    }
    
    x<-data.frame(x)
    names(x)<-c("Year","Seas","FltSrv","Gender","Part","Ageerr","Lbin_lo","Lbin_hi","Nsamp",rep(seq(1,max_age,1),2))
    x
}

