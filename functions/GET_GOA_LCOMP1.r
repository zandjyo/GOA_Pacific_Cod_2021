GET_GOA_LCOMP1<-function(species="99999",bins=seq(0,109,1),bin=TRUE,SS=TRUE,seas=1,flt=3,gender=1,part=0,Nsamp=100){
  ## create sql query

test<-paste("SELECT GOA.SIZECOMP_TOTAL.YEAR AS YEAR, \n ",
    "GOA.SIZECOMP_TOTAL.LENGTH/10 as LENGTH, \n ",
    "GOA.SIZECOMP_TOTAL.TOTAL \n ",
    "FROM GOA.SIZECOMP_TOTAL \n ",
    "WHERE GOA.SIZECOMP_TOTAL.SPECIES_CODE = ",species,"  \n ",
    "ORDER BY GOA.SIZECOMP_TOTAL.YEAR, \n ",
    "GOA.SIZECOMP_TOTAL.LENGTH \n ", sep="")
   
   ## run database query
   lcomp=sqlQuery(AFSC,test)
   
   ## create grid for zero fill and merge with data 
   len<-c(0:max(lcomp$LENGTH))
   YR<-unique(sort(lcomp$YEAR))
   grid<-expand.grid(LENGTH=len,YEAR=YR)
   lcomp<-merge(grid,lcomp,all=T)
   
   lcomp$TOTAL[is.na(lcomp$TOTAL)==T]<-0
   
   lcomp<-lcomp[order(lcomp$YEAR,lcomp$LENGTH),]
   
   ##optional data binning 
   if(bin){
      lcomp<-BIN_LEN_DATA(data=lcomp,len_bins=bins)
      lcomp<-aggregate(list(TOTAL=lcomp$TOTAL),by=list(BIN=lcomp$BIN,YEAR=lcomp$YEAR),FUN=sum)
      N_TOTAL <- aggregate(list(T_NUMBER=lcomp$TOTAL),by=list(YEAR=lcomp$YEAR),FUN=sum)
      lcomp <- merge(lcomp,N_TOTAL)
      lcomp$TOTAL <- lcomp$TOTAL / lcomp$T_NUMBER
    } 

    ## optional format for ss3
    if(SS){
      years<-unique(lcomp$YEAR)
      bins<-unique(lcomp$BIN)

      nbin=length(bins)
      nyr<-length(years)
      x<-matrix(ncol=((nbin)+6),nrow=nyr)
      x[,2]<-seas
      x[,3]<-flt
      x[,4]<-gender
      x[,5]<-part
      x[,6]<-Nsamp

      for(i in 1:nyr)
        {
            x[i,1]<-years[i]

            x[i,7:(nbin+6)]<-lcomp$TOTAL[lcomp$YEAR==years[i]]
        }
        lcomp<-x
    }
  lcomp
}



   
   
   

  
   