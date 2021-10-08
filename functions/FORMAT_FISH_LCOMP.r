# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

FORMAT_FISH_LCOMP <- function(data=FISH_COMP,seas=1,gender=3,part=0,Nsamp=100)
{
    num_gears <- 4
    got_one <- FALSE

    data$GEAR1[data$GEAR=="TRAWL"]<-1
    # data$GEAR1[data$GEAR=="FIXED"]<-2
    data$GEAR1[data$GEAR=="LONGLINE"]<-2
    data$GEAR1[data$GEAR=="POT"]<-3
    data$GEAR1[data$GEAR=="OTHER"]<-4

    y<-vector("list",length=num_gears)

    for (j in 1:num_gears)
    {
        data1<-subset(data,data$GEAR1==j)

        if (dim(data1)[1] > 0)
        {
            years <- sort(unique(data1$YEAR))
            bins  <- sort(unique(data1$LENGTH))

            nbin<-length(bins)
            nyr<-length(years)

            x_part<-matrix(ncol=((2*nbin)+6),nrow=nyr)

            x_part[,2]<-seas
            x_part[,3]<-j
            x_part[,4]<-gender
            x_part[,5]<-part
            x_part[,6]<-Nsamp

            for (i in 1:nyr)
            {
                print(paste("Year ",i))

                x_part[i,1]<-years[i]

                x_part[i,7:(nbin+6)]<-data1$FEMALES[data1$YEAR==years[i]]

                x_part[i,(nbin+7):((2*nbin)+6)]<-data1$MALES[data1$YEAR==years[i]]
            }

            y[[j]]<-x_part

            if (!got_one)
            {
                x_all <- y[[j]]
                got_one <- TRUE
            } else
            {
                x_all <- rbind(x_all,y[[j]])
            }
        }
    }

    x_all

}
