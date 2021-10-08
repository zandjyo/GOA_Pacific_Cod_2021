# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

# this function gets data for one region at a time
# currently all functions are hardcoded for 4 fishing fleets and 1 survey -> 5 total

 # new_data           = new_data
 #                               new_file           = new_SS_dat_filename
 #                               new_year           = new_SS_dat_year
 #                               sp_area            = sp_area
 #                               fsh_sp_label       = fsh_sp_label
 #                               fsh_sp_area        = fsh_sp_area
 #                               fsh_sp_str         = fsh_sp_str
 #                               fsh_start_yr       = fsh_start_yr
 #                               srv_sp_str         = srv_sp_str
 #                               srv_start_yr       = srv_start_yr
 #                               len_bins           = len_bins
 #                               max_age            = max_age
 #                               is_new_SS_DAT_file = is_new_SS_DAT_file
 #                               AUXFCOMP           = AUXFCOMP



SBSS_GET_ALL_DATA <- function(new_data     = new_data,
                              LL_length = LL_LENGTH_FILE,
                              new_file     = "blarYYYY.dat",
                              new_year     = 9999,
                              sp_area      = "'foo'",
                              fsh_sp_label = "'foo'",
                              fsh_sp_area  = "'foo'",
                              fsh_sp_str   = "999",
                              fsh_start_yr = 1977,
                              srv_sp_str   = "99999",
                              srv_start_yr = 1977,
                              new_SS_dat_year= new_SS_dat_year,
                              len_bins     = seq(4,109,3),
                              max_age      = 10,
                              is_new_SS_DAT_file = FALSE,
                              AUXFCOMP           = 3)
{

  new_data$sourcefile <- new_file

## ----- get REGION catch -----

   test <- paste("SELECT SUM(COUNCIL.COMPREHENSIVE_BLEND_CA.WEIGHT_POSTED)AS TONS,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_SUBAREA AS ZONE,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_GEAR AS GEAR,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.RETAINED_OR_DISCARDED AS TYPE,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR AS YEAR,\n ",
                  "TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE,'MM') AS MONTH, \n",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.SPECIES_GROUP_CODE AS SPECIES_GROUP\n ",
                  "FROM COUNCIL.COMPREHENSIVE_BLEND_CA\n ",
                  "WHERE COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_SUBAREA in (",fsh_sp_area,")\n ",
                  "AND COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR <= ",new_year,"\n ",
                  "AND COUNCIL.COMPREHENSIVE_BLEND_CA.SPECIES_GROUP_CODE in (",fsh_sp_label,")\n ",
                  "GROUP BY COUNCIL.COMPREHENSIVE_BLEND_CA.SPECIES_GROUP_CODE,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_SUBAREA,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_GEAR,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.RETAINED_OR_DISCARDED,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR,\n ", 
                  "TO_CHAR(COUNCIL.COMPREHENSIVE_BLEND_CA.WEEK_END_DATE,'MM')", sep="")


    CATCH<-sqlQuery(CHINA,test)

    CATCH$GEAR1<-"TRAWL"

     CATCH$GEAR1[CATCH$GEAR=="POT"]<-"POT"
     CATCH$GEAR1[CATCH$GEAR=="HAL"]<-"LONGLINE"
     CATCH$GEAR1[CATCH$GEAR=="JIG"]<-"LONGLINE"

    CATCH$SEASON<-1
    CATCH$SEASON[CATCH$MONTH>=3]<-2
    CATCH$SEASON[CATCH$MONTH>=5]<-3
    CATCH$SEASON[CATCH$MONTH>=9]<-4
    CATCH$SEASON[CATCH$MONTH>=11]<-5

    CATCH_GEAR<-aggregate(list(TONS=CATCH$TONS),by=list(YEAR=CATCH$YEAR,GEAR=CATCH$GEAR1),FUN=sum)

    ## get the old catch data that isn't in the catch accounting system...
  if(exists("OLD_SEAS_GEAR_CATCH")){
        OLD_SEAS_GEAR_CATCH$GEAR1<-"TRAWL"
        OLD_SEAS_GEAR_CATCH$GEAR1[OLD_SEAS_GEAR_CATCH$GEAR=="POT"]<-"POT"
        OLD_SEAS_GEAR_CATCH$GEAR1[OLD_SEAS_GEAR_CATCH$GEAR=="LONGLINE"]<-"LONGLINE"
        OLD_SEAS_GEAR_CATCH$GEAR1[OLD_SEAS_GEAR_CATCH$GEAR=="OTHER"]<-"LONGLINE"
        OLD_GEAR_CATCH<-aggregate(list(TONS=OLD_SEAS_GEAR_CATCH$TONS),by=list(YEAR=OLD_SEAS_GEAR_CATCH$YEAR,GEAR=OLD_SEAS_GEAR_CATCH$GEAR1),FUN=sum)
        CATCH2<-rbind(OLD_GEAR_CATCH,CATCH_GEAR)
        CATCH2<-CATCH2[order(CATCH2$GEAR,CATCH2$YEAR),]
    }else{
          print("Warning: No old catch information provided")
          CATCH2<-CATCH_GEAR
         }


    CATCH2<-CATCH2[order(CATCH2$GEAR,CATCH2$YEAR),]


## check that all gears have the same number of years covered; add zeros if necessary
  c_y <- sort(unique(CATCH2$YEAR))

  grid<-expand.grid(YEAR=c(min(c_y):max(c_y)))
  CATCH2<-merge(CATCH2,grid,all=T)
  CATCH2$TONS[is.na(CATCH2$TONS)]<-0.0

 
## sort CATCH by gear and year
  CATCH <- CATCH2[order(CATCH2$GEAR,CATCH2$YEAR),]
  CATCH<-data.table(CATCH)
  CATCH$fleet= 1
  CATCH[GEAR=="LONGLINE"]$fleet<- 2
 CATCH[GEAR=="POT"]$fleet<- 3
 CATCH<-CATCH[order(fleet,YEAR),]

catch<-data.frame(year=CATCH$YEAR,seas=1,fleet=CATCH$fleet,catch=CATCH$TONS,catch_se=0.05)

x<- data.frame(year=c(-999,-999,-999),seas=c(1,1,1),fleet=c(1,2,3),catch=c(0,0,0),catch_se=rep(0.05,3))
x2<-data.frame(year=-9999,seas=0,fleet=0,catch=0,catch_se=0)

catch<-rbind(x,catch)
catch<-catch[order(catch$fleet,catch$year),]
#catch<-rbind(catch,x2)

## write catch data into new data files
  new_data$N_catch<-nrow(catch)
  new_data$catch<-catch


## ----- Get survey shelf biomass estimates -----
 
  GOA_BIOM <- GET_GOA_BIOM(srv_sp_str)
  GOA_BIOM$index <- 4

  BIOM <- rbind(GOA_BIOM)
 
  BIOM$CV <- sqrt(BIOM$POPVAR)/BIOM$POP
  BIOM$se_log <- sqrt(log(1.0 + (BIOM$CV^2)))

  CPUE<-data.frame(year=BIOM$YEAR,seas=7,index=BIOM$index,obs=BIOM$POP/1000,se_log=BIOM$se_log)

  gridc<-expand.grid(year=min(CPUE$year):max(CPUE$year))
  CPUE<-merge(CPUE,gridc,by="year",all=T)
  CPUE$seas<- 7
  CPUE$index<- 4
  CPUE[is.na(CPUE)]<- 1

  CPUE$index[CPUE$year<1990]<- -4
  CPUE$index[CPUE$obs==1]<- -4


## pulling in LL survey RPN data from Dana's csv files.
 LL_RPN<-GET_GOA_LL_RPN(species=srv_sp_str,FYR=LLsrv_start_yr )
 LL_RPN<-LL_RPN[year>=LLsrv_start_yr]
 LL_CPUE<-data.frame(year=LL_RPN$year,seas=7,index=5,obs=LL_RPN$rpn,se_log=LL_RPN$se/LL_RPN$rpn)
 CPUE<-rbind(CPUE,LL_CPUE)


## ADF&G and IPHC survey files included here
  if(exists("ADFG_IPHC")){ 
       names(ADFG_IPHC)<-names(CPUE)
       CPUE<-rbind(CPUE,ADFG_IPHC)
     }else {print("Warning:  no ADFG_IPHC file appears to exist here")}

## Larval survey indices included here
  if(exists("Larval_indices")){ 
       names(Larval_indices)<-names(CPUE)
       CPUE<-rbind(CPUE,Larval_indices)
     }else {print("Warning:  no larval indices file appears to exist here")}

## write to new data file
  new_data$N_cpue<-nrow(CPUE)
  new_data$CPUE<-CPUE



## ----- get size composition data -----
 
## Gulf of Alaska bottom trawl survey size comp
  SRV_LCOMP_SS <- data.frame(GET_GOA_LCOMP1(species=srv_sp_str,bins=len_bins,bin=TRUE,SS=TRUE,seas=7,flt=4,gender=0,part=0,Nsamp=100))
  names(SRV_LCOMP_SS) <- c("Year","Seas","FltSrv","Gender","Part","Nsamp",len_bins)


## ----- Get Fishery catch at size composition data -----
 

 FISHLCOMP<-data.frame(GET_GOA_LENCOMP2(fsh_sp_str1=202, len_bins1=len_bins, fsh_start_yr1=fsh_start_yr, new_SS_dat_year1= new_year, seas=1,gender=0,part=0,Nsamp=-1)) 
 names(FISHLCOMP) <- c("Year","Seas","FltSrv","Gender","Part","Nsamp",len_bins)



if(AUXFCOMP > 0){
 auxFLCOMP<-LENGTH_BY_CATCH_GOA(fsh_sp_str=fsh_sp_str ,fsh_sp_label = fsh_sp_label,ly=new_year)
 if(AUXFCOMP==1)auxFLCOMP<-auxFLCOMP[[1]]
 if(AUXFCOMP==2)auxFLCOMP<-auxFLCOMP[[2]]
 if(AUXFCOMP==3)auxFLCOMP<-auxFLCOMP[[3]]


 auxFLCOMP$FltSrv<-1
 auxFLCOMP$FltSrv[auxFLCOMP$GEAR=="LONGLINE"]<-2
 auxFLCOMP$FltSrv[auxFLCOMP$GEAR=="POT"]<-3

auxflCOMP1=data.frame(Year=auxFLCOMP$YEAR,Seas=rep(1, nrow(auxFLCOMP)),FltSrv=auxFLCOMP$FltSrv,gender=rep(0, nrow(auxFLCOMP)),Part=rep(0, nrow(auxFLCOMP)),Nsamp=auxFLCOMP$Nsamp,auxFLCOMP[,4:(ncol(auxFLCOMP)-1)])
names(auxflCOMP1) <- c("Year","Seas","FltSrv","Gender","Part","Nsamp",len_bins)

    fishLCOMP=subset(FISHLCOMP,FISHLCOMP$Year<1991)
    fishLCOMP<-rbind(fishLCOMP,auxflCOMP1)
    FISHLCOMP<-fishLCOMP[order(fishLCOMP$FltSrv,fishLCOMP$Year),]

  }

print("Fisheries LCOMP2 done")
       
## combine all the length comp data
  LCOMP<-rbind(FISHLCOMP,SRV_LCOMP_SS)

## pulling in longline survey length composition data from Dana's csv files 
  
  LL_length<-GET_GOA_LL_LENGTH(species=srv_sp_str,FYR=LLsrv_start_yr)
  
  names(LL_length)<-c("year","length","FREQ")

  LL_LENGTHY <- LL_length[,list(TOT=sum(FREQ)),by="year"]
  LL_LENGTH  <- merge(LL_length,LL_LENGTHY,by="year")
  LL_LENGTH$PROP <- LL_LENGTH$FREQ/LL_LENGTH$TOT

  grid <- expand.grid(year=sort(unique(LL_LENGTH$year)),length=seq(0,116,by=1))
  LL_LENGTHG <- merge(LL_LENGTH,grid,by=c("year","length"),all=T)
  LL_LENGTHG$PROP[is.na(LL_LENGTHG$PROP)] <- 0

  SS3_LLL <- reshape2::dcast(LL_LENGTHG,formula=year~length,value.var="PROP")
  LL_LENGTH<-data.frame(Year=SS3_LLL$year,Seas=1,FltSrv=5,Gender=0,part=0,Nsamp=100)
  LL_LENGTH<-cbind(LL_LENGTH,SS3_LLL[2:ncol(SS3_LLL)])
  names(LL_LENGTH) <- c("Year","Seas","FltSrv","Gender","Part","Nsamp",len_bins)

  LCOMP<-rbind(LCOMP,LL_LENGTH)
  LCOMP[7:ncol(LCOMP),]<- round(LCOMP[7:ncol(LCOMP),],5)


## write into SS3 files
  new_data$lencomp<-LCOMP
  new_data$lencomp$Nsamp[new_data$lencomp$Nsamp>=200]<-200
  new_data$N_lencomp<-nrow(LCOMP)

  print("All LCOMP done")


## get age comp
      GOA_ACOMP<-GET_GOA_ACOMP1(srv_sp_str=srv_sp_str, max_age=max_age,Seas=7,FLT=-4,Gender=0,Part=0,Ageerr=1,Lgin_lo=-1,Lgin_hi=-1,Nsamp=100)
      print("Survey agecomp done")

      GOA_ACOMPF<-LENGTH4AGE_BY_CATCH_GOA(fsh_sp_str=202 ,fsh_sp_label = "'PCOD'",ly=new_year, STATE=3, max_age=max_age)

      ## Note that these aren't used in the current model so are turned off here...
      GOA_ACOMPF$FltSrv<-GOA_ACOMPF$FltSrv*-1 

      names(GOA_ACOMPF)<-names(GOA_ACOMP)
      print("Fisheries agecomp done")
      

      cond_age_length<-data.frame(cond_length_age_cor(max_age1=max_age)$norm)
      names(cond_age_length)<-names(GOA_ACOMP)
      #cond_age_length$FltSvy<- 4
      print("Conditional survey age length done")      

      cond_age_lengthFISH<-data.frame(cond_length_age_corFISH(max_age1=max_age)$norm)
      
## negating the older fish ages from the file
      cond_age_lengthFISH<-data.table(cond_age_lengthFISH)
      cond_age_lengthFISH[X1<2007]$X3 = cond_age_lengthFISH[X1<2007]$X3 * -1
      cond_age_lengthFISH<-data.frame(cond_age_lengthFISH)
      names(cond_age_lengthFISH)<-names(GOA_ACOMP)
      print("Conditional fisheries age length done")     
      
      ACOMP<-rbind(GOA_ACOMPF,GOA_ACOMP,cond_age_lengthFISH,cond_age_length)
      ACOMP[10:ncol(ACOMP),]<- round(ACOMP[10:ncol(ACOMP),],5)

      new_data$agecomp<-ACOMP
      new_data$N_agecomp<-nrow(ACOMP)

      ## Get all survey Age Data

      Age<-GET_SURV_AGE_cor(sp_area=sp_area,srv_sp_str=srv_sp_str,start_yr=srv_start_yr,max_age=max_age)
      print("GET_SURV_AGE done")

      Age$Sur <- 4          #Survey 4 is bottom trawl
      Age_w <- rbind(Age)
 

## format survey mean size-at-age data for SS3
  AGE_LENGTH_SS <- data.frame(FORMAT_AGE_MEANS1(srv_age_samples=Age_w,max_age=max_age,type="L",seas=1,flt=-4,gender=0,part=0))
  
  if (is_new_SS_DAT_file)
  {
      names(AGE_LENGTH_SS) <- c("Year","Seas","FltSrv","Gender","Part","Ageerr","Ignore",rep(seq(0,max_age,1),2))
  } else
  {
      names(AGE_LENGTH_SS) <- names(old_data$MeanSize_at_Age_obs)
  }

## write size at age to new data file
  new_data$MeanSize_at_Age_obs<-AGE_LENGTH_SS
  new_data$N_MeanSize_at_Age_obs<-nrow(AGE_LENGTH_SS)


## format survey mean weight-at-age data for SS3
  AGE_WEIGHT_SS <- data.frame(FORMAT_AGE_MEANS1(srv_age_samples=Age_w,max_age=max_age,type="W",seas=1,gender=3,growpattern=1,birthseas=1,flt=-4))
print("Formatting AGE Means done")
  # Fleet = -1 indicates that this is the population weight-at-age in the middle of the season
 #AGE_WEIGHT_SS<-data.frame(FORMAT_AGE_WEIGHT(data=AGE_WEIGHT,seas=1,gender=3,growpattern=1,birthseas=1,flt=-1))
  names(AGE_WEIGHT_SS) <- c("#Year","Seas","Gender","GrowPattern","Birthseas","Fleet",seq(0,max_age,1))

# write out empirical/survey mean weight-at-age data to file wtatage.ss
waa.ss <- file("wtatage.ss","w")
write(paste(nrow(AGE_WEIGHT_SS)," #N rows"),file=waa.ss,append=TRUE)
write(paste(max_age," #N ages"),file=waa.ss,append=TRUE)
write(paste0(names(AGE_WEIGHT_SS),collapse=" "),file=waa.ss,append=TRUE)
write(t(AGE_WEIGHT_SS),file=waa.ss,ncolumns=ncol(AGE_WEIGHT_SS),append=TRUE)
close(waa.ss)


## fill in a bunch of stuff in the new_data structure
  if (is_new_SS_DAT_file)
  {

  } else
  {            
        new_data$agebin_vector = seq(1,(max_age),1)
      	error<-matrix(ncol=(max_age+1),nrow=2)
	error[1,]<-rep(-1,max_age+1)
	error[2,]<-rep(-0.001,max_age+1)
	#error[3,]<-seq(0.5,(max_age+0.5),by=1)
        #error[4,]<-c( 0.096, 0.210583, 0.325167, 0.43975, 0.554333, 0.668917, 0.7835, 0.898083, 1.01267, 1.12725, 1.471)

	#error[4,]<-c( 0.096, 0.210583, 0.325167, 0.43975, 0.554333, 0.668917, 0.7835, 0.898083, 1.01267, 1.12725, 1.24183, 1.35642, 1.471, 1.471, 1.471, 1.471, 1.471, 1.471, 1.471, 1.471, 1.471)
	new_data$ageerror<-data.frame(error)
  }

  new_data
}