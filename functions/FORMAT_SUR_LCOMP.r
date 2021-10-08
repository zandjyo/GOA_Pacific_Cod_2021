# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

FORMAT_SUR_LCOMP <- function(data=data,seas=1,flt=3,gender=3,part=0,Nsamp=100)
{
    years<-unique(data$YEAR)
    bins<-unique(data$BIN)

    nbin=length(bins)
    nyr<-length(years)
    x<-matrix(ncol=((2*nbin)+6),nrow=nyr)
    x[,2]<-seas
    x[,3]<-flt
    x[,4]<-gender
    x[,5]<-part
    x[,6]<-Nsamp

    for(i in 1:nyr)
    {
        x[i,1]<-years[i]

        x[i,7:(nbin+6)]<-data$F_PROP[data$YEAR==years[i]]

        x[i,(nbin+7):((2*nbin)+6)]<-data$M_PROP[data$YEAR==years[i]]
    }
    x
}

