# Code taken from SBSS_GET_ALL_DATA.r to format survey
# mean length/size-at-age and mean weight-at-age
#
# ZTA, 2013-09-23, R v2.15.1

FORMAT_AGE_MEANS1 <- function(srv_age_samples=NULL,max_age=10,type="L", seas=1,flt=4,gender=0,part=0,birthseas=1,growpattern=1)
{
  Age_All<-subset(srv_age_samples,!is.na(srv_age_samples$AGE))
  
  
  if (toupper(type) == "L")
  {
      # print warning if there are any blank or negative lengths
      bad_lengths <- max(dim(subset(Age_All,is.na(Age_All$LENGTH) == T))[1],
                         dim(subset(Age_All,Age_All$LENGTH < 1))[1])
      if (bad_lengths > 0)
      {
          print(paste("Warning in FORMAT_AGE_MEANS: ", bad_lengths, "database records with bad length values"))
          Age_All<-subset(Age_All,is.na(Age_All$LENGTH)==F)
      }

      Age_All<-subset(Age_All,Age_All$AGE1 > 0)

      # lengths are in millimeters in the RACEBASE.SPECIMEN table -> convert to cm
      Ave_AgeM<-aggregate(list(VALUE=Age_All$LENGTH/10),by=list(AGE=Age_All$AGE1,YEAR=Age_All$YEAR),FUN=mean)
      Ave_Age_M<-aggregate(list(SAMPLES=Age_All$LENGTH/10),by=list(AGE=Age_All$AGE1,YEAR=Age_All$YEAR),FUN=length)
      
 
      Ave_Age_M$VALUE<-Ave_AgeM$VALUE
 
      AGE1<-c(1:max_age)
      YEAR<-sort(as.numeric(unique(Age_All$YEAR)))
      AGE1<-expand.grid(AGE1,YEAR)
      names(AGE1)<-c("AGE","YEAR")

      Ave_AgeM<-merge(Ave_Age_M,AGE1,all=T)
      Ave_AgeM$VALUE[is.na(Ave_AgeM$VALUE)==T]<- -9
      Ave_AgeM$SAMPLES[is.na(Ave_AgeM$SAMPLES)==T]<- -9

  
      AGE_FRAME<-data.frame(YEAR=Ave_AgeM$YEAR,Age=Ave_AgeM$AGE,Sample=Ave_AgeM$SAMPLE,VALUE=Ave_AgeM$VALUE)
      AGE_FRAME<-AGE_FRAME[order(AGE_FRAME$YEAR,AGE_FRAME$Age),]

## set all "-9" values set above to 0
      AGE_FRAME$Sample[which(AGE_FRAME$Sample == -9,arr.ind=TRUE)] <- 0
      AGE_FRAME$VALUE[which(AGE_FRAME$VALUE == -9,arr.ind=TRUE)] <- 0
  
      
      years<-unique(AGE_FRAME$YEAR)
      bins<-unique(AGE_FRAME$Age)

      nbin=length(bins)
      nyr<-length(years)
      x<-matrix(ncol=((2*nbin)+7),nrow=nyr)

      x[,2]<-seas
      x[,3]<-flt
      x[,4]<-gender
      x[,5]<-part
      x[,6]<-1
      x[,7]<-999


    for(i in 1:nyr)
      {
        x[i,1]<-years[i]
        x[i,8:(nbin+7)]<-AGE_FRAME$VALUE[AGE_FRAME$YEAR==years[i]]
        x[i,(nbin+8):ncol(x)]<-AGE_FRAME$Sample[AGE_FRAME$YEAR==years[i]]
      }

} else if (toupper(type) == "W") {


  
      # print warning if there are any blank or negative weights
      bad_weights <- max(dim(subset(Age_All,is.na(Age_All$WEIGHT) == T))[1],
                         dim(subset(Age_All,Age_All$WEIGHT < 1))[1])
      if (bad_weights > 0)
      {
          print(paste("Warning in FORMAT_AGE_MEANS: ", bad_weights, "database records with bad weight values"))
          Age_All<-subset(Age_All,is.na(Age_All$WEIGHT)==F)
      }
      
      # weights are in grams in the RACEBASE.SPECIMEN table - convert to kg
      Ave_AgeM<-aggregate(list(VALUE=Age_All$WEIGHT/1000.0),by=list(AGE=Age_All$AGE1,YEAR=Age_All$YEAR),FUN=mean)
      Ave_Age_M<-aggregate(list(SAMPLES=Age_All$WEIGHT/1000.0),by=list(AGE=Age_All$AGE1,YEAR=Age_All$YEAR),FUN=length)

      Ave_Age_M$VALUE<-Ave_AgeM$VALUE

     
      AGE1<-c(1:max_age)
      YEAR<-sort(as.numeric(unique(Age_All$YEAR)))
      AGE1<-expand.grid(AGE1,YEAR)
      names(AGE1)<-c("AGE","YEAR")

      Ave_AgeM<-merge(Ave_Age_M,AGE1,all=T)
      Ave_AgeM$VALUE[is.na(Ave_AgeM$VALUE)==T]<- -9
      Ave_AgeM$SAMPLES[is.na(Ave_AgeM$SAMPLES)==T]<- -9

  
      AGE_FRAME<-data.frame(YEAR=Ave_AgeM$YEAR,Age=Ave_AgeM$AGE,Sample=Ave_AgeM$SAMPLE,VALUE=Ave_AgeM$VALUE)
      AGE_FRAME<-AGE_FRAME[order(AGE_FRAME$YEAR,AGE_FRAME$Age),]

## set all "-9" values set above to 0
      AGE_FRAME$Sample[which(AGE_FRAME$Sample == -9,arr.ind=TRUE)] <- 0
      AGE_FRAME$VALUE[which(AGE_FRAME$VALUE == -9,arr.ind=TRUE)] <- 0

        
      years <- sort(unique( AGE_FRAME$YEAR))
      bins  <- sort(unique( AGE_FRAME$Age))

      nbins <- length(bins)  # extra column for age-0
      nyrs  <- length(years)

      const.cols <- 6
      data.col.start <- const.cols + 1    # start at age-0 column

    # one line for each year and sex;
    # this assumes that there are data for each sex for each year
      x     <- matrix(ncol=(const.cols + nbins),nrow=2*nyrs)

      x[,2] <- seas

      x[,4] <- growpattern
      x[,5] <- birthseas
      x[,6] <- flt

      for(i in 1:nyrs)
        {
        # output the calculated mean weight-at-age values for FEMALES
          x[i,1] <- years[i]
          x[i,3] <- 0
          x[i,(data.col.start):(nbins+const.cols)] <- AGE_FRAME$VALUE[AGE_FRAME$YEAR==years[i]]

        # output the calculated mean weight-at-age values for MALES
          j <- nyrs + i
          x[j,1] <- years[i]
          x[j,3] <- 0
          x[j,(data.col.start):(nbins+const.cols)] <- AGE_FRAME$Sample[AGE_FRAME$YEAR==years[i]]
      } 
  } else { return(NULL) }

    x
}
