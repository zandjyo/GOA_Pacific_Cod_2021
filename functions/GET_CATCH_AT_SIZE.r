# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

GET_CATCH_AT_SIZE<-function(type="F",fsh_sp_str="99999",sp_area="'foo'",len_bins=seq(1,100,1),bin=TRUE)
{
  if(type=="F")
  {
  	## get catch at size for foreign observer data with optional binning
  	test<-GET_FOR_SPCOMP(fsh_sp_str=fsh_sp_str,sp_area=sp_area)
	names(test)<-c("HAUL_JOIN","SPECIES","EXTRAPOLATED_NUMBER","EXTRAPOLATED_WEIGHT")
  	test2<-GET_FOR_LEN(fsh_sp_str=fsh_sp_str,sp_area=sp_area)
	# names(test2)[6]<-"LENGTH"
    names(test2)[which(names(test2) == "SIZE_GROUP")] <- "LENGTH"
  	x<-aggregate(list(sum1=test2$FREQUENCY),by=list(HAUL_JOIN=test2$HAUL_JOIN),FUN=sum)
  }

  if(type=="D")
  {
  	## get catch at size for Domestic observer data with optional binning
  	test<-GET_DOM_SPCOMP(fsh_sp_str=fsh_sp_str,sp_area=sp_area)
  	test2<-GET_DOM_LEN(fsh_sp_str=fsh_sp_str,sp_area=sp_area)
 	 ## haul level calcs
  	x<-aggregate(list(sum1=test2$FREQUENCY),by=list(HAUL_JOIN=test2$HAUL_JOIN),FUN=sum)
  }

  if(type=="ALL")
  {
    ## get catch at size for both foreign and domestic observer data with optional binning
  	test<-GET_FOR_SPCOMP(fsh_sp_str=fsh_sp_str,sp_area=sp_area)
	names(test)<-c("HAUL_JOIN","SPECIES","EXTRAPOLATED_NUMBER","EXTRAPOLATED_WEIGHT")
  	test<-rbind(test,GET_DOM_SPCOMP(fsh_sp_str=fsh_sp_str,sp_area=sp_area))

  	test2<-GET_FOR_LEN(fsh_sp_str=fsh_sp_str,sp_area=sp_area)
  	# names(test2)[6]<-"LENGTH"
    names(test2)[which(names(test2) == "SIZE_GROUP")] <- "LENGTH"
	test3<-GET_DOM_LEN(fsh_sp_str=fsh_sp_str,sp_area=sp_area)
	test3<-data.frame(HAUL_JOIN=test3$HAUL_JOIN,YEAR=test3$YEAR,SEX=test3$SEX,LENGTH=test3$LENGTH,FREQUENCY=test3$FREQUENCY,GEAR=test3$GEAR)
	test2<-data.frame(HAUL_JOIN=test2$HAUL_JOIN,YEAR=test2$YEAR,SEX=test2$SEX,LENGTH=test2$LENGTH,FREQUENCY=test2$FREQUENCY,GEAR=test2$GEAR)
	test2<-rbind(test2,test3)
  	## haul level calcs
  	x<-aggregate(list(sum1=test2$FREQUENCY),by=list(HAUL_JOIN=test2$HAUL_JOIN),FUN=sum)
  }

## optional binning of data
  if(bin)
  {
    	test2<-BIN_LEN_DATA(test2,len_bins=len_bins)
    	test2$LENGTH<-test2$BIN
    	test2<-subset(test2,select=-c(BIN))
  }

  x<-merge(test2,x,all=T)
  remove(test2)
  x$PROP<-x$FREQUENCY/x$sum1 ## gives proportion per haul for size category
  x<-merge(x,test,all.x=T)
  remove(test)
  x$LNUMBERS<-x$PROP*x$EXTRAPOLATED_NUMBER

  # x$GEAR2[x$GEAR<6]<- "TRAWL"
  # x$GEAR2[x$GEAR>=6]<- "FIXED"
  # according to code written by Angie Grieg
  x$GEAR2[x$GEAR>=6]<- "OTHER"
  x$GEAR2[x$GEAR<=5]<- "TRAWL"
  x$GEAR2[x$GEAR==8]<- "LONGLINE"
  x$GEAR2[x$GEAR==6]<- "POT"

  x<-subset(x,select=-c(sum1))
  x<-subset(x,is.na(x$LNUMBERS)==F)
  x2<-aggregate(list(LNUMBERS=x$LNUMBERS),by=list(YEAR=x$YEAR,LENGTH=x$LENGTH,SEX=x$SEX,GEAR=x$GEAR2),FUN=sum)
  x<-aggregate(list(T_NUMBERS=x$LNUMBERS),by=list(YEAR=x$YEAR,GEAR=x$GEAR2),FUN=sum)
  x2<-merge(x2,x,all=T)
  remove(x)
  x2$NPROP<-x2$LNUMBERS/x2$T_NUMBERS
  x2<-x2[order(x2$GEAR,x2$YEAR,x2$SEX,x2$LENGTH),]

  if(bin)
  {
    	grid<-expand.grid(LENGTH=len_bins,YEAR=unique(x2$YEAR),SEX=unique(x2$SEX),GEAR=unique(x2$GEAR))
    	x2<-merge(x2,grid,all=T)
    	x2$NPROP[is.na(x2$NPROP)==T]<-0
    	x2$LNUMBERS[is.na(x2$LNUMBERS)==T]<-0
    	x2$T_NUMBERS[is.na(x2$T_NUMBERS)==T]<-0
   }

  x2
}

