# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

FORMAT_AGE_LENGTH <- function(data=AGE_LENGTH,seas=1,flt=3,gender=3,part=0)
{
    years<-unique(data$YEAR)
    bins<-unique(data$Age)

    nbin=length(bins)
    nyr<-length(years)
    x<-matrix(ncol=((4*nbin)+7),nrow=nyr)

    x[,2]<-seas
    x[,3]<-flt
    x[,4]<-gender
    x[,5]<-part
    x[,6]<-1
    x[,7]<-999

    for(i in 1:nyr)
    {
        x[i,1]<-years[i]

        x[i,8:(nbin+7)]<-data$Females[data$YEAR==years[i]]
        x[i,(nbin+8):((2*nbin)+7)]<-data$Males[data$YEAR==years[i]]
        x[i,((2*nbin)+8):((3*nbin)+7)]<-data$Female_Sample[data$YEAR==years[i]]
        x[i,((3*nbin)+8):((4*nbin)+7)]<-data$Male_Sample[data$YEAR==years[i]]
    }

    x
}
