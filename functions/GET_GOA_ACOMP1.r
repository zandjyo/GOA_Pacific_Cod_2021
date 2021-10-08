GET_GOA_ACOMP1<-function(srv_sp_str="99999",max_age=20,Seas=1,FLT=2,Gender=1,Part=0,Ageerr=1,Lgin_lo=-1,Lgin_hi=-1,Nsamp=100){
  ## create sql query

  test<-paste("SELECT GOA.AGECOMP_TOTAL.SURVEY_YEAR AS YEAR, \n",
    "GOA.AGECOMP_TOTAL.AGE, \n",
    "SUM(GOA.AGECOMP_TOTAL.AGEPOP) AS AGEPOP \n",
    "FROM GOA.AGECOMP_TOTAL \n",
    "WHERE GOA.AGECOMP_TOTAL.AGE        > 0 \n",
    "AND GOA.AGECOMP_TOTAL.SEX          < 9 \n",
    "AND GOA.AGECOMP_TOTAL.SPECIES_CODE = ", srv_sp_str," \n",
    "GROUP BY GOA.AGECOMP_TOTAL.SURVEY_YEAR, \n",
    "GOA.AGECOMP_TOTAL.AGE, \n",
    "GOA.AGECOMP_TOTAL.SPECIES_CODE \n",
    "ORDER BY YEAR, \n",
    "GOA.AGECOMP_TOTAL.AGE \n",sep="")




   ## run database query
    Acomp=sqlQuery(AFSC,test)
    YR<-unique(sort(Acomp$YEAR))
    grid=expand.grid(AGE=c(1:max_age),YEAR=YR)
    Acomp30<-subset(Acomp,Acomp$AGE>=max_age)
    
    if(nrow(Acomp30)>0){
        A30<-aggregate(list(AGEPOP=Acomp30$AGEPOP),by=list(YEAR=Acomp30$YEAR),FUN=sum)
        A30$AGE=max_age
        Acomp<-subset(Acomp,Acomp$AGE<max_age)
        Acomp<-merge(Acomp,A30,all=T)
    }
   
     Acomp<-merge(grid,Acomp,all=T)
    Acomp$AGEPOP[is.na(Acomp$AGEPOP)==T]<-0
   
   
    y<-matrix(ncol=9+max_age,nrow=length(YR))
    x<-data.frame(y)
    names(x)<-c("YEAR","Seas","FltSvy","Gender","Part","Ageerr","Lgin_lo","Lgin_hi","Nsamp",paste("F",c(1:max_age),sep=""))
    x$YEAR=YR
    x$Seas=Seas
    x$FltSvy=FLT
    x$Gender=Gender
    x$Part=Part
    x$Ageerr=Ageerr
    x$Lgin_lo=Lgin_lo
    x$Lgin_hi=Lgin_hi
    x$Nsamp=Nsamp
   
    for (i in 1:length(YR)){
      x[i,10:(9+max_age)]<-Acomp$AGEPOP[Acomp$YEAR==YR[i]]
      }
    
    x
}
   
   
   
   
   

  
   