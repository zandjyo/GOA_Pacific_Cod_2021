
  
LENGTH4AGE_BY_CATCH_GOA<-function(fsh_sp_str=202 ,fsh_sp_label = "'PCOD'",ly=2019, STATE=3,max_age=10){
	require(RODBC)
	require(data.table)
	require(reshape2)
  require(rgdal)
  require(dplyr)
  require(lubridate)



 	test <- paste("SELECT \n ",
      "CASE \n ",
      "  WHEN OBSINT.DEBRIEFED_LENGTH.GEAR in (1,2,3,4) \n ",
      "  THEN 0\n ",
      "  WHEN OBSINT.DEBRIEFED_LENGTH.GEAR in 6 \n ",
      "  THEN 2 \n ",
      "  WHEN OBSINT.DEBRIEFED_LENGTH.GEAR in (5,7,9,10,11,68,8) \n ",
      "  THEN 3 \n ",
      "END                                              AS GEAR, \n ",
      "CONCAT('H',TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_JOIN))       AS HAUL_JOIN, \n ",
      "TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') AS MONTH, \n ",
      "CASE \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') <= 2 \n ",
      "  THEN 1 \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') > 2 \n ",
      "  AND TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') <= 4 \n ",
      "  THEN 2 \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') > 4 \n ",
      "  AND TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') <= 8 \n ",
      "  THEN 3 \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') > 8 \n ",
      "  AND TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') <= 10 \n ",
      "  THEN 4 \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') > 10 \n ",
      "  THEN 5 \n ",
      "END                                                AS SEASON, \n ",
      "CASE \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') in (1,2,3) \n ",
      "  THEN 1 \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') in (4,5,6) \n ",
       "  THEN 2 \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') in (7,8,9) \n ",
      "  THEN 3 \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') in (10,11,12) \n ",
      "  THEN 4 \n ",
      "END                                                AS QUARTER, \n ",
       "CASE \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') in (1,2,3,4) \n ",
      "  THEN 1 \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') in (5,6,7,8) \n ",
       "  THEN 2 \n ",
      "  WHEN TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'MM') in (9,10,11,12) \n ",
      "  THEN 3 \n ",
      "END                                                AS TRIMESTER, \n ",
      "TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'YYYY') AS YEAR, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.EXTRAPOLATED_NUMBER        AS NUMB, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.CRUISE        AS CRUISE, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.PERMIT        AS PERMIT, \n ",
       "OBSINT.DEBRIEFED_SPCOMP.HAUL        AS HAUL, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.EXTRAPOLATED_WEIGHT / 1000 AS WEIGHT, \n ",
       "OBSINT.DEBRIEFED_LENGTH.SEX                     AS SEX, \n ",
      "OBSINT.DEBRIEFED_LENGTH.LENGTH                     AS LENGTH, \n ",
      "OBSINT.DEBRIEFED_LENGTH.FREQUENCY                  AS FREQ, \n ",
       "OBSINT.DEBRIEFED_HAUL.LONDD_END AS LON, \n",
        "OBSINT.DEBRIEFED_HAUL.LATDD_END AS LAT, \n",
        "OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE AS HDAY, \n",
      "OBSINT.DEBRIEFED_HAUL.NMFS_AREA AS AREA \n",
      "FROM OBSINT.DEBRIEFED_HAUL \n ",
      "INNER JOIN OBSINT.DEBRIEFED_SPCOMP \n ",
      "ON OBSINT.DEBRIEFED_HAUL.HAUL_JOIN = OBSINT.DEBRIEFED_SPCOMP.HAUL_JOIN \n ",
      "INNER JOIN OBSINT.DEBRIEFED_LENGTH \n ",
      "ON OBSINT.DEBRIEFED_HAUL.HAUL_JOIN = OBSINT.DEBRIEFED_LENGTH.HAUL_JOIN \n ",
      "WHERE OBSINT.DEBRIEFED_HAUL.NMFS_AREA BETWEEN 600 AND 699 \n",
      "AND OBSINT.DEBRIEFED_LENGTH.NMFS_AREA != 670 \n",
      "AND OBSINT.DEBRIEFED_SPCOMP.SPECIES  in  (",fsh_sp_str,")",
      "AND OBSINT.DEBRIEFED_LENGTH.SPECIES    in  (",fsh_sp_str,")",sep="")

  	Dspcomp=data.table(sqlQuery(AFSC,test))

    Dspcomp$GEAR1<-"TRAWL"
    Dspcomp$GEAR1[Dspcomp$GEAR==2]<-"POT"
    Dspcomp$GEAR1[Dspcomp$GEAR==3]<-"LONGLINE"
    Dspcomp$GEAR<-Dspcomp$GEAR1


    HJ <- Dspcomp[,list(Nsamp=length(unique(HAUL_JOIN))),by="YEAR,GEAR"]
    HJA <- Dspcomp[,list(Nsamp=length(unique(HAUL_JOIN))),by="YEAR,GEAR,AREA,TRIMESTER"]





    Dspcomp$HAUL1<-as.character(paste(Dspcomp$CRUISE,Dspcomp$PERMIT,Dspcomp$HAUL,sep="_"))

   

    WED<-function(x=Dspcomp$HDAY[1])
      { y<-data.table(

        weekday=weekdays(x),
        wed=ceiling_date(x, "week"),  
        plus= ifelse(weekdays(x) %in% c("Sunday"), 6, -1),
        YR=year(x))

        y$next_saturday<-date(y$wed)+y$plus
        y[YR<1993]$next_saturday<-date(y[YR<1993]$wed)

        y$yr2<-year(y$next_saturday)
        y[YR!=yr2]$next_saturday<-date(paste0(y[YR!=yr2]$YR,"-12-31"))
   
        return(y$next_saturday)
    }


    Dspcomp$WED<-WED(Dspcomp$HDAY)

    t5<-Dspcomp[,list(T2FREQ=sum(FREQ)),by=c('HAUL_JOIN','NUMB')]
    t5$KEEP=1
    t5[T2FREQ<10]$KEEP<-0
    t6<-t5[KEEP==1]

    Dspcomp<-merge(t6,Dspcomp,all.x=T)


    Dspcomp$AREA<-trunc(Dspcomp$AREA/10)*10
  	
   
    x<-Dspcomp[,list(N1=min(NUMB), HFREQ=sum(FREQ)),by=c("YEAR,WED,TRIMESTER,AREA,HAUL1,GEAR")] ## get individual haul extrapolated numbers of fish
    y<-x[,list(N2=sum(N1),TFREQ=sum(HFREQ)),by=c("YEAR,WED,AREA,TRIMESTER,GEAR")]  ## get total observed numbers of fish per year, area,state,  and gear
    z<-Dspcomp[,list(FREQ=sum(FREQ)),by=c("YEAR,WED,TRIMESTER,AREA,HAUL1,SEX,LENGTH,GEAR")] ## number of fish by length bin, haul, gear and year

    z2<-merge(x,y,all=T,by=c("YEAR","WED","TRIMESTER","AREA","GEAR"))
    z3<-merge(z,z2,all=T,by=c("YEAR","WED","TRIMESTER","AREA","GEAR","HAUL1"))
    z3$PROP<-((z3$FREQ/z3$HFREQ)*z3$N1)/z3$N2  ## for each length bin, haul, gear and year  calculated the proportion of fish 
 	  z4<-z3[YEAR>=1991]
  	z4<-z4[order(GEAR,YEAR,SEX,LENGTH),]
  	D_SPCOMP<-z4[,list(PROP=sum(PROP)),by=c("YEAR,WED,TRIMESTER,AREA,GEAR,SEX,LENGTH")]


    D_SPCOMP_161<-D_SPCOMP[,list(P1=sum(PROP)),by=c("YEAR,GEAR,AREA,TRIMESTER,SEX,LENGTH")]
    D_SPCOMP_161x<-D_SPCOMP[,list(tot=sum(PROP)),by=c("YEAR,GEAR,AREA,TRIMESTER")]
    D_SPCOMP_161<-merge(D_SPCOMP_161,D_SPCOMP_161x,all=T)
    D_SPCOMP_161$PROP<-D_SPCOMP_161$P1/D_SPCOMP_161$tot

    grid<-data.table(expand.grid(YEAR=sort(unique(D_SPCOMP_161$YEAR)),GEAR=unique(D_SPCOMP_161$GEAR),AREA=unique(D_SPCOMP_161$AREA),TRIMESTER=c(1:3),SEX=c("M","F","U"),LENGTH=seq(1,117,1)))

    D_SPCOMP_161<-merge(D_SPCOMP_161,grid,all=T,by=c("YEAR","GEAR","AREA","TRIMESTER","SEX","LENGTH"))

  
    test <- paste("SELECT SUM(COUNCIL.COMPREHENSIVE_BLEND_CA.WEIGHT_POSTED)AS TONS, \n ",
                  "to_char(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE,'MM') AS MONTH, \n",
                  "CASE \n ",
      				"  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') <= 2 \n ",
     				"  THEN 1 \n ",
      				"  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') > 2 \n ",
      				"  AND TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') <= 4 \n ",
      				"  THEN 2 \n ",
      				"  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') > 4 \n ",
      				"  AND TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') <= 8 \n ",
      				"  THEN 3 \n ",
      				"  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') > 8 \n ",
      				"  AND TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') <= 10 \n ",
      				"  THEN 4 \n ",
      				"  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') > 10 \n ",
      				"  THEN 5 \n ",
      			"END                                                AS SEASON, \n ",
      			"CASE \n ",
      				"  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') in (1,2,3) \n ",
      				"  THEN 1 \n ",
      				"  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') in (4,5,6) \n ",
       				"  THEN 2 \n ",
      				"  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') in (7,8,9) \n ",
      				"  THEN 3 \n ",
      				"  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') in (10,11,12) \n ",
      				"  THEN 4 \n ",
      			"END                                                AS QUARTER, \n ", 
            "CASE \n ",
              "  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') in (1,2,3,4) \n ",
              "  THEN 1 \n ",
              "  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') in (5,6,7,8) \n ",
              "  THEN 2 \n ",
              "  WHEN TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, 'MM') in (9,10,11,12) \n ",
              "  THEN 3 \n ",
              "END                                                AS TRIMESTER, \n ",       
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_GEAR AS GEAR, \n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR AS YEAR, \n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.REPORTING_AREA_CODE AS AREA, \n",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE AS WED,  \n",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.AKR_STATE_FEDERAL_WATERS_CODE AS STATE \n ",
                  "FROM COUNCIL.COMPREHENSIVE_BLEND_CA \n ",
                   "WHERE COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_SUBAREA in ('CG','PWSI','SE','SEI','WG','WY') \n ",
                  "AND COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR <= ",ly," \n ",
                  "AND COUNCIL.COMPREHENSIVE_BLEND_CA.SPECIES_GROUP_CODE in (",fsh_sp_label,")\n ",
                  "GROUP BY COUNCIL.COMPREHENSIVE_BLEND_CA.SPECIES_GROUP_CODE, \n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_SUBAREA, \n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_GEAR, \n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.RETAINED_OR_DISCARDED, \n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.REPORTING_AREA_CODE, \n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE, \n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.AKR_STATE_FEDERAL_WATERS_CODE, \n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR \n ", sep="")


    CATCH<-data.table(sqlQuery(CHINA,test))

    CATCH$WED<-date(CATCH$WED)
    CATCH$STATE[is.na(CATCH$STATE)]<-"F"
   

    CATCH$GEAR1<-"TRAWL"
    CATCH$GEAR1[CATCH$GEAR=="POT"]<-"POT"
    CATCH$GEAR1[CATCH$GEAR=="HAL"]<-"LONGLINE"
    CATCH$GEAR1[CATCH$GEAR=="JIG"]<-"LONGLINE"
    CATCH$GEAR<-CATCH$GEAR1

  	CATCH$AREA<-trunc(CATCH$AREA/10)*10
  
  	y2 <- CATCH[,list(TOTAL=sum(TONS)),by="YEAR"]                                                 ## get total observed numbers of fish per year and gear
  	z2 <- CATCH[,list(TONS=sum(TONS)),by=c("YEAR,WED,TRIMESTER,AREA,GEAR")] ## get total number of measured fish by haul, gear, and year

  	x2 <- merge(y2,z2,all=T)
  	x2$CATCH_PROP<-x2$TONS/x2$TOTAL
        
        t1<-Dspcomp[,list(TFREQ=sum(FREQ)),by=c('TRIMESTER','YEAR','AREA','GEAR1')]
        names(t1)[4]<-'GEAR'
  
    D_LENGTH<-merge(D_SPCOMP,x2,all=T, by=c("YEAR","WED","TRIMESTER","AREA","GEAR"))
  	D_LENGTH$LENGTH[D_LENGTH$LENGTH>116]<-117
    D_LENGTH$PROP1<- D_LENGTH$PROP*D_LENGTH$CATCH_PROP
    DLENGTH<-D_LENGTH[!is.na(PROP1)]
	  DLENGTH<-DLENGTH[,list(PROP1=sum(PROP1)),by=c("YEAR,TRIMESTER,AREA,GEAR,SEX,LENGTH")]

  t2<-merge(DLENGTH,t1)
  t3<-t2[TFREQ>=30]
  t3[,'TFREQ':=NULL]

    grid<-data.table(expand.grid(YEAR=sort(unique(DLENGTH$YEAR)),TRIMESTER=c(1:3),AREA=unique(DLENGTH$AREA),GEAR=unique(DLENGTH$GEAR),SEX=c("M","F","U"),LENGTH=seq(1,117,1)))

    DLENGTH1<-merge(grid,t3,all.x=T,by=c("YEAR","TRIMESTER","AREA","GEAR","SEX","LENGTH"))
    DLENGTH1[is.na(PROP1)]$PROP1<-0
    DLENGTH_NS<-DLENGTH1[,list(PROP=sum(PROP1)),by=c("YEAR,GEAR,SEX,LENGTH")]
  
	
    SLENGTH<-read.csv("Z:/Steve WorkingFolders/2020_Assessments/PCOD/State_Data/ALL_STATE_LENGTHS.csv")
    SLENGTH<-data.table(SLENGTH[,1:9])
    SLENGTH<-SLENGTH[LENGTH>0]
    SLENGTH$AREA<-trunc(SLENGTH$AREA/10)*10

    SLENGTH$GEAR1<-"TRAWL"
    SLENGTH$GEAR1[SLENGTH$GEAR==91]<-"POT"
    SLENGTH$GEAR1[SLENGTH$GEAR %in% c(5,26,61)]<-"LONGLINE"
    SLENGTH$GEAR<-SLENGTH$GEAR1

    SLENGTH$LENGTH[SLENGTH$LENGTH>116]<-117

    x<-SLENGTH$SEX
    SLENGTH$SEX<-as.character(SLENGTH$SEX)
    SLENGTH$SEX<-"M"
    SLENGTH$SEX[x==2]<-"F"
    SLENGTH$SEX[x==9]<-"U"

     
   
    SLENGTH$TRIMESTER<-1
    SLENGTH$TRIMESTER[SLENGTH$MONTH>4&SLENGTH$MONTH<=8]<-2
    SLENGTH$TRIMESTER[SLENGTH$MONTH>8]<-3
    
    S1<-SLENGTH[,list(SFREQ=sum(FREQ)),by=c('TRIMESTER','YEAR','AREA','GEAR1')]
    names(S1)[4]<-'GEAR'

    SHJA <- SLENGTH[,list(TOT=sum(FREQ)),by="YEAR,GEAR,TRIMESTER,AREA"]
    SHJA <- SHJA[order(GEAR,AREA,YEAR),]
    SHJA$Nsamp <- round(SHJA$TOT/50)
    SHJA[, TOT:=NULL]

    Sx<-SLENGTH[,list(FREQ=sum(FREQ)),by="YEAR,TRIMESTER,AREA,GEAR,SEX,LENGTH"]
    Sy<-SLENGTH[,list(TOTAL=sum(FREQ)),by="YEAR,TRIMESTER,AREA,GEAR"]

    Sz<-merge(Sx,Sy,by=c("YEAR","TRIMESTER","AREA","GEAR"))
    Sz$PROP<-Sz$FREQ/Sz$TOTAL
    Sz<-subset(Sz,select=-c(TOTAL,FREQ))
   
   S2<-merge(Sz,S1)
   S3<-S2[SFREQ>=30]
   S3[,'SFREQ':=NULL]
 
  
    grid<-data.table(expand.grid(YEAR=sort(unique(SLENGTH$YEAR)),TRIMESTER=c(1:3),AREA=unique(SLENGTH$AREA),GEAR=unique(SLENGTH$GEAR),SEX=c("M","F","U"),LENGTH=seq(1,117,1)))
    
    Sz<-merge(grid,S3,all=T,by=c("YEAR","TRIMESTER","AREA","GEAR","SEX","LENGTH"))
    SCATCH<-x2[,list(CATCH_PROP=sum(CATCH_PROP)),by=c("YEAR,TRIMESTER,AREA,GEAR")]

    S_LENGTH<-merge(Sz,SCATCH,all=T, by=c("YEAR","TRIMESTER","AREA","GEAR"))
    S_LENGTH<-S_LENGTH[!is.na(LENGTH)]
    S_LENGTH[is.na(S_LENGTH)]<-0

    S_LENGTH$PROP1<- S_LENGTH$PROP*S_LENGTH$CATCH_PROP

    SLENGTH1<-S_LENGTH[,list(PROP1=sum(PROP1)),by="YEAR,TRIMESTER,AREA,GEAR,SEX,LENGTH"]

## take the one that has the most lengths recorded

   # Dy<-y[GEAR=="POT"][,list(FFREQ=sum(TFREQ)),by=c("YEAR,TRIMESTER,AREA,GEAR")]
   # Sy<-Sy[GEAR=="POT"][,list(SFREQ=sum(TOTAL)),by=c("YEAR,TRIMESTER,AREA,GEAR")]
   #yy=merge(Sy,Dy, all=T,by=c("YEAR","TRIMESTER","AREA","GEAR"))

    yy=merge(S1,t1,all=T) 
     
    yy[is.na(yy)]<-0
    yy$STATE<-0
    yy$STATE[yy$SFREQ>yy$TFREQ]<-1             ## test to see which dataset has more lengths measured
    yy1<-yy[STATE==1]
    yy1<-yy1[,c(1:4,7)]

    S_LENGTHx<-merge(SLENGTH1,yy1,all.x=T,by=c("YEAR","TRIMESTER","AREA","GEAR"))
    D_LENGTHx<-merge(DLENGTH1,yy1,all.x=T,by=c("YEAR","TRIMESTER","AREA","GEAR"))

    S_LENGTHx<-S_LENGTHx[!is.na(STATE)]
    D_LENGTHx<-D_LENGTHx[is.na(STATE)]

    D_LENGTHx<-merge(D_LENGTHx,HJA,by=c("YEAR","TRIMESTER","AREA","GEAR"),all.x=T)
    S_LENGTHx<-merge(S_LENGTHx,SHJA,by=c("YEAR","TRIMESTER","AREA","GEAR"),all.x=T)

    D_LENGTHx[is.na(D_LENGTHx)]<-0
    S_LENGTHx[is.na(S_LENGTHx)]<-0 

    LENGTHx<-rbind(D_LENGTHx,S_LENGTHx)
    DLENGTH_S1<-LENGTHx[,list(PROP=sum(PROP1),Nsamp=sum(Nsamp)),by="YEAR,GEAR,SEX,LENGTH"]
 
## fill in the blanks code  Fill in years,trimester,area,gear with state port data if federal data are missing

  yy3<-yy[TFREQ<30&SFREQ>=30]
  yy3<-yy3[,c(1:4,7)]

    S_LENGTHx<-merge(SLENGTH1,yy3,all.x=T,by=c("YEAR","TRIMESTER","AREA","GEAR"))## added by 
    D_LENGTHx<-merge(DLENGTH1,yy3,all.x=T,by=c("YEAR","TRIMESTER","AREA","GEAR"))

    S_LENGTHx<-S_LENGTHx[!is.na(STATE)]
    D_LENGTHx<-D_LENGTHx[is.na(STATE)]

    D_LENGTHx<-merge(D_LENGTHx,HJA,by=c("YEAR","TRIMESTER","AREA","GEAR"),all.x=T)
    S_LENGTHx<-merge(S_LENGTHx,SHJA,by=c("YEAR","TRIMESTER","AREA","GEAR"),all.x=T)

    D_LENGTHx[is.na(D_LENGTHx)]<-0
    S_LENGTHx[is.na(S_LENGTHx)]<-0 

    LENGTHx<-rbind(D_LENGTHx,S_LENGTHx)
 
    DLENGTH_S2<-LENGTHx[,list(PROP=sum(PROP1),Nsamp=sum(Nsamp)),by="YEAR,GEAR,SEX,LENGTH"]
    LENGTHS<-list(NO_STATE=DLENGTH_NS,STATE_HIGH=DLENGTH_S1,STATE_HOLE=DLENGTH_S2)
  
    ldata<-data.table(LENGTHS[[STATE]])
    ldata$FREQUENCY<-ldata$PROP*10000
 
    age=data.table(GET_DOM_AGE(fsh_sp_str=202,sp_area="'GOA'",max_age=20))
    age<-age[!is.na(AGE)]
    age$GEAR<-as.character(age$GEAR)
    age[GEAR %in% c(1,2,3,4)]$GEAR<- "TRAWL"
    age[GEAR %in% c(6)]$GEAR<- "POT"
    age[GEAR %in% c(5,7,9,10,11,68,8)]$GEAR<- "LONGLINE"
    age<-age[!is.na(GEAR)]
    age<-age[YEAR>2007]
    ldata<-ldata[YEAR>2007]

    gears<-unique(age$GEAR)
    z<-data.frame(matrix(ncol=5,nrow=1))
    names(z)<-c("YEAR","GEAR","SEX","AGE","LENGTH" )
  
    for(j in 1:length(gears)){
      age1<-age[GEAR==gears[j]]
      ldata1<-ldata[GEAR==gears[j]]
      years<-sort(unique(age1$YEAR))
      for( i in 1:length(years)){
        x=find_ALF(Adata=age1,Ldata=ldata1,year=years[i])
        y1=data.frame(YEAR=years[i],GEAR=gears[j],SEX=1,AGE=x$len1$age,LENGTH=x$len1$tl)
        y2=data.frame(YEAR=years[i],GEAR=gears[j],SEX=2,AGE=x$len2$age,LENGTH=x$len2$tl)
        z=rbind(z,y1,y2)
      }

    }

    S_length_age<-subset(z,!is.na(z$YEAR))
    Total_AGE<-aggregate(list(FREQ=S_length_age$AGE),by=list(GEAR=S_length_age$GEAR,AGE=S_length_age$AGE,YEAR=S_length_age$YEAR),FUN=length)

    GRID<-expand.grid(GEAR=gears,YEAR=sort(unique(S_length_age$YEAR)),AGE=c(1:(max_age+10)))
    Total_AGE<-merge(GRID,Total_AGE, all=T)
    Total_AGE$FREQ[is.na(Total_AGE$FREQ)]=0
    Total<-aggregate(list(Total=S_length_age$AGE),by=list(GEAR=S_length_age$GEAR,YEAR=S_length_age$YEAR),FUN=length)
    Total_AGE<-merge(Total,Total_AGE, all=T)
    Total_AGE$PROB<-Total_AGE$FREQ/Total_AGE$Total
    Total_AGE<-subset(Total_AGE,select=-c(Total))
    Total_AGE<-Total_AGE[order(Total_AGE$YEAR,Total_AGE$GEAR,Total_AGE$AGE),]

    Total_AGE_Flat<-dcast(Total_AGE,GEAR+YEAR~AGE)

    Total_AGE_Flat2<-Total_AGE_Flat[,1:(max_age+2)]
    Total_AGE_Flat2[,(max_age+2)]<-rowSums(Total_AGE_Flat[,(max_age+2):ncol(Total_AGE_Flat)])



    Total_AGE_Flat<-data.table(subset(Total_AGE_Flat2,!is.na(Total_AGE_Flat[,3])))

    Total_AGE_Flat$fleet<-1
    Total_AGE_Flat[GEAR=="LONGLINE"]$fleet<-2
    Total_AGE_Flat[GEAR=="POT"]$fleet<-3

    Nsamp=ldata[,list(Nsamp=min(200,mean(Nsamp))),by=c("YEAR,GEAR")]

    Total_AGE_Flat<-merge(Total_AGE_Flat,Nsamp,all.x=T)
 
    y<-Total_AGE_Flat[,3:(max_age+2)]
    nyr=nrow(Total)
    
  



    x<-data.frame(YEAR=Total_AGE_Flat$YEAR,Seas=rep(1,nyr),FltSrv=Total_AGE_Flat$fleet,Gender=rep(0,nyr),Part=rep(0,nyr),Ageerr=rep(1,nyr),Lgin_lo=rep(-1,nyr),Lgin_hi=rep(-1,nyr),Nsamp=Total_AGE_Flat$Nsamp) #,Total_AGE_Flat[,3:22])
    x[,10:(ncol(y)+9)]<-y
    
    names(x)[10:ncol(x)]<-paste0("F",1:max_age)
    return(x)
  }

