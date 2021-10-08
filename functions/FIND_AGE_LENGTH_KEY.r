# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

FIND_AGE_LENGTH_KEY <- function(Adata,Ldata,year,max_age=30)
{
    require(FSA)
    require(NCStats)

    Adata$AGE1<-Adata$AGE
    Adata$AGE1[Adata$AGE>max_age] <- max_age
    rb.age1<-subset(Adata,Adata$YEAR==year&Adata$SEX==1)
    rb.age2<-subset(Adata,Adata$YEAR==year&Adata$SEX==2)
    rb.len1<-subset(Ldata,Ldata$YEAR==year&Ldata$SEX==1)
    rb.len2<-subset(Ldata,Ldata$YEAR==year&Ldata$SEX==2)

    rb.age1<-data.frame(age=rb.age1$AGE1,tl=rb.age1$LENGTH)
    rb.age2<-data.frame(age=rb.age2$AGE1,tl=rb.age2$LENGTH)

    rb.len1<-aggregate(list(FREQ=rb.len1$FREQUENCY),by=list(LENGTH=rb.len1$LENGTH),FUN=sum)
    rb.len2<-aggregate(list(FREQ=rb.len2$FREQUENCY),by=list(LENGTH=rb.len2$LENGTH),FUN=sum)


    expand.length<-function(data)
    {
        x<-rep(data$LENGTH[1],data$FREQ[1])
        for( i  in 2:nrow(data))
        {
            x1<-rep(data$LENGTH[i],data$FREQ[i])
            x<-c(x,x1)
        }

        y<-data.frame(age=NA,tl=x)
        y
    }

    rb.len1<-expand.length(rb.len1)
    rb.len2<-expand.length(rb.len2)

    rb.age1 <- rbind(rb.age1,expand.grid(age=1,tl=c(min(rb.len1$tl),(min(rb.age1$tl)-1))))
    rb.age2 <- rbind(rb.age2,expand.grid(age=1,tl=c(min(rb.len2$tl),(min(rb.age2$tl)-1))))

# lencat(df,cl,startcat=0,w=1,...)
#       df: A data.frame that (minimally) contains a column of length
#           measurements.
#       cl: A number or string indicating which column the length
#           measurements occupy in the data.frame, ‘df’.
# startcat: A number indicating the beginning of the first length-class.
#        w: A number indicating the width of length classes to create.

# ***NOTE*** hardcoded values, with starting value at 4 cm, bin width 1 cm
#    rb.age1.1<-lencat(rb.age1,"tl",startcat=40,w=10)
#    rb.age2.1<-lencat(rb.age2,"tl",startcat=40,w=10)

    # bin sizes are in millimeters
    bin_start <- 10
    bin_width <- 10
    rb.age1$LCat<-lencat(x=rb.age1$tl,data=rb.age1,formula=~tl,startcat=bin_start,w=bin_width)
    rb.age2$LCat<-lencat(x=rb.age2$tl,data=rb.age2,formula=~tl,startcat=bin_start,w=bin_width)


    rb.raw1 <- table(rb.age1$LCat,rb.age1$age)
    rb.key1 <- prop.table(rb.raw1,margin=1)
    rb.raw2 <- table(rb.age2$LCat,rb.age2$age)
    rb.key2 <- prop.table(rb.raw2,margin=1)


    rb.len1.1 <- ageKey(key=rb.key1,data=rb.len1,formula=age~tl)
    rb.len2.1 <- ageKey(key=rb.key2,data=rb.len2,formula=age~tl)

    AL<-list(len1=rb.len1.1,len2=rb.len2.1)
    AL
}

