GET_GOA_LENCOMP2<-function(fsh_sp_str1=202, len_bins1=len_bins, fsh_start_yr1=fsh_start_yr, new_SS_dat_year1= new_SS_dat_year, seas=1,gender=1,part=0,Nsamp=-1) {
   require(data.table)
    
  test <- paste("SELECT CASE  \n", 
      "     when NORPAC.FOREIGN_HAUL.NUMBER_OF_POTS is not NULL then 0 \n",
      "      when NORPAC.FOREIGN_HAUL.NUMBER_OF_SKATES is not NULL then 1 \n",
      "      else 2       \n",
      "     end as GEAR, \n",
      "TO_CHAR(NORPAC.FOREIGN_SPCOMP.HAUL_JOIN) AS HAUL_JOIN,\n ",
      "TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT,'MM') AS MONTH, \n ",
      "CASE \n",
      "    WHEN TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT, 'MM') <= 2 \n",
      "    THEN 1 \n",
      "    WHEN TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT, 'MM') > 2 \n",
      "    AND TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT, 'MM') <= 4 \n",
      "    THEN 2 \n",
      "    WHEN TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT, 'MM') > 4 \n",
      "    AND TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT, 'MM') <= 8 \n",
      "    THEN 3 \n",
      "    WHEN TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT, 'MM') > 8 \n",
      "    AND TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT, 'MM') <= 10 \n",
      "    THEN 4 \n",
      "    WHEN TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT, 'MM') > 10 \n",
      "    THEN 5 \n",
      "  END                                       AS SEASON, \n",
      "TO_CHAR(NORPAC.FOREIGN_SPCOMP.DT,'YYYY') AS YEAR, \n ",
      "NORPAC.FOREIGN_SPCOMP.SPECIES_HAUL_NUMBER AS NUMB,\n ",
      "NORPAC.FOREIGN_SPCOMP.SPECIES_HAUL_WEIGHT/1000 AS WEIGHT,\n ",
      "NORPAC.FOREIGN_LENGTH.SIZE_GROUP AS LENGTH,\n ",
      "NORPAC.FOREIGN_LENGTH.FREQUENCY AS FREQ \n",
      "FROM NORPAC.FOREIGN_HAUL \n ",
      "INNER JOIN NORPAC.FOREIGN_SPCOMP\n ",
      "ON NORPAC.FOREIGN_HAUL.HAUL_JOIN = NORPAC.FOREIGN_SPCOMP.HAUL_JOIN\n ",
      "INNER JOIN NORPAC.FOREIGN_LENGTH ",
      "ON NORPAC.FOREIGN_HAUL.HAUL_JOIN     = NORPAC.FOREIGN_LENGTH.HAUL_JOIN\n ",
      "WHERE NORPAC.FOREIGN_HAUL.GENERIC_AREA between 600 and 699 \n ",
      "AND NORPAC.FOREIGN_HAUL.GENERIC_AREA != 670\n ",
      "AND NORPAC.FOREIGN_SPCOMP.SPECIES in (",fsh_sp_str1,")",
      "AND NORPAC.FOREIGN_LENGTH.SPECIES in (",fsh_sp_str1,")" ,sep="")

  Fspcomp=sqlQuery(AFSC,test)
  Fspcomp$GEAR1<-"TRAWL"
  Fspcomp$GEAR1[Fspcomp$GEAR==0]<-"POT"
  Fspcomp$GEAR1[Fspcomp$GEAR==1]<-"LONGLINE"


## proportion lengths for each gear type based on haul size (extrapolated number of fish in haul) 
  x<-aggregate(list(N1=Fspcomp$NUMB),by=list(YEAR=Fspcomp$YEAR,HAUL_JOIN=Fspcomp$HAUL_JOIN,GEAR1=Fspcomp$GEAR1),FUN=min) ## get individual haul extrapolated numbers of fish
  y<-aggregate(list(N2=x$N1),by=list(YEAR=x$YEAR,GEAR1=x$GEAR1),FUN=sum)                                                 ## get total observed numbers of fish per year and gear
  z<-aggregate(list(HFREQ=Fspcomp$FREQ),by=list(YEAR=Fspcomp$YEAR,HAUL_JOIN=Fspcomp$HAUL_JOIN,GEAR1=Fspcomp$GEAR1),FUN=sum) ## get total number of measured fish by haul, gear, and year


  zz1<-merge(x,z,all=T)
  zz2<-aggregate(list(TFREQ=zz1$HFREQ,TN=zz1$N1),by=list(YEAR=zz1$YEAR,GEAR1=zz1$GEAR1),FUN=sum)  ## Total number of fish measured by gear and year
  zz3<-merge(z,zz2,all=T)
  zz4<-merge(x,zz3)
  z2<-aggregate(list(FREQ=Fspcomp$FREQ),by=list(YEAR=Fspcomp$YEAR,HAUL_JOIN=Fspcomp$HAUL_JOIN,LENGTH=Fspcomp$LENGTH,GEAR1=Fspcomp$GEAR1),FUN=sum) ## number of fish by length bin, haul, gear and year

  zz5<-merge(z2,zz4,all=T)
  zz5$PROP<-((zz5$FREQ/zz5$HFREQ)*zz5$N1)/zz5$TN                                                       ## for each length bin, haul, gear and year  calculated the proportion of fish 

  zz6<-aggregate(list(PROP=zz5$PROP),by=list(YEAR=zz5$YEAR,GEAR=zz5$GEAR,LENGTH=zz5$LENGTH),FUN=sum)  ## add the proportions together for each length bin, year, and gear.
  zz6<-subset(zz6,zz6$YEAR>=1977)
  zz6<-zz6[order(zz6$GEAR,zz6$YEAR,zz6$LENGTH),]
  F_SPCOMP<-zz6


 test <- paste("SELECT \n ",
      "CASE \n ",
      "  WHEN OBSINT.DEBRIEFED_LENGTH.GEAR in (1,2,3,4) \n ",
      "  THEN 0\n ",
      "  WHEN OBSINT.DEBRIEFED_LENGTH.GEAR in 6 \n ",
      "  THEN 2 \n ",
      "  WHEN OBSINT.DEBRIEFED_LENGTH.GEAR in (5,7,9,10,11,68,8) \n ",
      "  THEN 3 \n ",
      "END                                              AS GEAR, \n ",
      "TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_JOIN)       AS HAUL_JOIN, \n ",
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
      "TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_DATE, 'YYYY') AS YEAR, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.EXTRAPOLATED_NUMBER        AS NUMB, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.CRUISE        AS CRUISE, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.PERMIT        AS PERMIT, \n ",
       "OBSINT.DEBRIEFED_SPCOMP.HAUL        AS HAUL, \n ",
      "OBSINT.DEBRIEFED_SPCOMP.EXTRAPOLATED_WEIGHT / 1000 AS WEIGHT, \n ",
      "OBSINT.DEBRIEFED_LENGTH.LENGTH                     AS LENGTH, \n ",
      "OBSINT.DEBRIEFED_LENGTH.FREQUENCY                  AS FREQ \n ",
      "FROM OBSINT.DEBRIEFED_HAUL \n ",
      "INNER JOIN OBSINT.DEBRIEFED_SPCOMP \n ",
      "ON OBSINT.DEBRIEFED_HAUL.HAUL_JOIN = OBSINT.DEBRIEFED_SPCOMP.HAUL_JOIN \n ",
      "INNER JOIN OBSINT.DEBRIEFED_LENGTH \n ",
      "ON OBSINT.DEBRIEFED_HAUL.HAUL_JOIN = OBSINT.DEBRIEFED_LENGTH.HAUL_JOIN \n ",
      "WHERE OBSINT.DEBRIEFED_HAUL.NMFS_AREA BETWEEN 600 AND 699 \n",
      "AND OBSINT.DEBRIEFED_LENGTH.NMFS_AREA != 670 \n",
      "AND OBSINT.DEBRIEFED_SPCOMP.SPECIES  in  (",fsh_sp_str1,")",
      "AND OBSINT.DEBRIEFED_LENGTH.SPECIES    in  (",fsh_sp_str1,")",sep="")

  Dspcomp=sqlQuery(AFSC,test)
  Dspcomp$GEAR1<-"TRAWL"
  Dspcomp$GEAR1[Dspcomp$GEAR==2]<-"POT"
  Dspcomp$GEAR1[Dspcomp$GEAR==3]<-"LONGLINE"
  #Dspcomp$GEAR1[Dspcomp$GEAR==4]<-"OTHER"
  
  Dspcomp$HAUL1<-as.character(paste(Dspcomp$CRUISE,Dspcomp$PERMIT,Dspcomp$HAUL,sep="_"))



## sample size equal to number of hauls sampled by putting a -1 in function input Nsamp  
if (Nsamp==-1){
    FNSAMP<- aggregate(list(HJ=Fspcomp$HAUL_JOIN),by=list(YEAR=Fspcomp$YEAR,HAUL_JOIN=Fspcomp$HAUL_JOIN,GEAR1=Fspcomp$GEAR1),FUN=min)
    FNSAMP2<-aggregate(list(HJN=FNSAMP$HJ), by=list(YEAR=FNSAMP$YEAR,GEAR=FNSAMP$GEAR1),FUN=length) 
    DNSAMP<-aggregate(list(HJ=Dspcomp$YEAR),by=list(YEAR=Dspcomp$YEAR,HAUL_JOIN=Dspcomp$HAUL1,GEAR1=Dspcomp$GEAR1),FUN=length)
    DNSAMP2<-aggregate(list(HJN=DNSAMP$HAUL_JOIN), by=list(YEAR=DNSAMP$YEAR,GEAR=DNSAMP$GEAR1),FUN=length) 
    NSAMP<- rbind(FNSAMP2,DNSAMP2)
    NSAMP<-data.table(aggregate(list(NSAMP=NSAMP$HJN),by=list(YEAR=NSAMP$YEAR,GEAR=NSAMP$GEAR),FUN=sum))
    NSAMP<-data.frame(NSAMP[YEAR>=fsh_start_yr1 & YEAR<=new_SS_dat_year1])
    NSAMP$GEAR1<-1
    NSAMP$GEAR1[NSAMP$GEAR=="LONGLINE"]<-2
    NSAMP$GEAR1[NSAMP$GEAR=="POT"]<-3
    NSAMP<-NSAMP[order(NSAMP$GEAR1,NSAMP$YEAR),]
  }

## proportion lengths for each gear type based on haul size (extrapolated number of fish in haul) 
  x<-aggregate(list(N1=Dspcomp$NUMB),by=list(YEAR=Dspcomp$YEAR,HAUL_JOIN=Dspcomp$HAUL1,GEAR1=Dspcomp$GEAR1),FUN=min) ## get individual haul extrapolated numbers of fish
  y<-aggregate(list(N2=x$N1),by=list(YEAR=x$YEAR,GEAR1=x$GEAR1),FUN=sum)                                                 ## get total observed numbers of fish per year and gear
  z<-aggregate(list(HFREQ=Dspcomp$FREQ),by=list(YEAR=Dspcomp$YEAR,HAUL_JOIN=Dspcomp$HAUL1,GEAR1=Dspcomp$GEAR1),FUN=sum) ## get total number of measured fish by haul, gear, and year

  zz1<-merge(x,z,all=T)
  zz2<-aggregate(list(TFREQ=zz1$HFREQ,TN=zz1$N1),by=list(YEAR=zz1$YEAR,GEAR1=zz1$GEAR1),FUN=sum) ## Total number of fish measured by gear and year
  zz3<-merge(z,zz2,all=T)
  zz4<-merge(x,zz3)
  z2<-aggregate(list(FREQ=Dspcomp$FREQ),by=list(YEAR=Dspcomp$YEAR,HAUL_JOIN=Dspcomp$HAUL1,LENGTH=Dspcomp$LENGTH,GEAR1=Dspcomp$GEAR1),FUN=sum) ## number of fish by length bin, haul, gear and year

  zz5<-merge(z2,zz4,all=T)
  zz5$PROP<-((zz5$FREQ/zz5$HFREQ)*zz5$N1)/zz5$TN   ## for each length bin, haul, gear and year  calculated the proportion of fish 

  zz6<-aggregate(list(PROP=zz5$PROP),by=list(YEAR=zz5$YEAR,GEAR=zz5$GEAR,LENGTH=zz5$LENGTH),FUN=sum)  ## add the proportions together for each length bin, year, and gear.
  zz6<-subset(zz6,zz6$YEAR>=1977)
  zz6<-zz6[order(zz6$GEAR,zz6$YEAR,zz6$LENGTH),]
  D_SPCOMP<-zz6


## bin length composition based on len_bins
  length<-data.frame(LENGTH=c(1:max(F_SPCOMP$LENGTH)))
  length$BIN<-max(len_bins1)
  n<-length(len_bins1)
  for(i in 2:n-1)
    {
       length$BIN[length$LENGTH < len_bins1[((n-i)+1)] ]<-len_bins1[n-i]
    }

  zz11<-merge(F_SPCOMP,length,all.x=T,all.y=F)
  zz11<-aggregate(list(PROP=zz11$PROP),by=list(YEAR=zz11$YEAR,GEAR=zz11$GEAR,BIN=zz11$BIN),FUN=sum)
  grid<-expand.grid(YEAR=sort(unique(zz11$YEAR[zz11$GEAR=="TRAWL"])),GEAR="TRAWL",BIN=len_bins1)
  # grid2<-expand.grid(YEAR=sort(unique(zz11$YEAR[zz11$GEAR=="POT"])),GEAR="POT",BIN=len_bins) ## not foriegn pot data for pcod.
  grid3<-expand.grid(YEAR=sort(unique(zz11$YEAR[zz11$GEAR=="LONGLINE"])),GEAR="LONGLINE",BIN=len_bins1)
  grid<-rbind(grid,grid3)

  zz11<-merge(zz11,grid,all=T)
  zz11$PROP[is.na(zz11$PROP)]<-0
  F_SPCOM<-zz11

## for pcod we have both domestic and foriegn lengths in trawls for years 1988 and 1989
  if(fsh_sp_str1==202){
  F_SPCOM$PROP[F_SPCOM$YEAR>=1987 & F_SPCOM$GEAR=="TRAWL"]<-F_SPCOM$PROP[F_SPCOM$YEAR>=1987 & F_SPCOM$GEAR=="TRAWL"]/2
 }

  length<-data.frame(LENGTH=c(1:max(D_SPCOMP$LENGTH)))
  length$BIN<-max(len_bins1)
  n<-length(len_bins1)
  for(i in 2:n-1)
    {
       length$BIN[length$LENGTH < len_bins1[((n-i)+1)] ]<-len_bins1[n-i]
    }

  zz11<-merge(D_SPCOMP,length,all.x=T,all.y=F)

  zz11<-aggregate(list(PROP=zz11$PROP),by=list(YEAR=zz11$YEAR,GEAR=zz11$GEAR,BIN=zz11$BIN),FUN=sum)

  grid<-expand.grid(YEAR=sort(unique(zz11$YEAR[zz11$GEAR=="TRAWL"])),GEAR="TRAWL",BIN=len_bins1)
  grid2<-expand.grid(YEAR=sort(unique(zz11$YEAR[zz11$GEAR=="POT"])),GEAR="POT",BIN=len_bins1)
  grid3<-expand.grid(YEAR=sort(unique(zz11$YEAR[zz11$GEAR=="LONGLINE"])),GEAR="LONGLINE",BIN=len_bins1)

  grid<-rbind(grid,grid2,grid3)

  zz11<-merge(zz11,grid,all=T)
  zz11$PROP[is.na(zz11$PROP)]<-0
  D_SPCOM<-zz11
  
  ## for pcod we have both domestic and foriegn lengths in trawls for years 1988 and 1989
  if(fsh_sp_str1==202){
  D_SPCOM$PROP[D_SPCOM$YEAR<=1988 & D_SPCOM$GEAR=="TRAWL"]<-D_SPCOM$PROP[D_SPCOM$YEAR<=1988 & D_SPCOM$GEAR=="TRAWL"]/2
  }


  SPCOM<-rbind(F_SPCOM,D_SPCOM)
  SPCOM<-data.table(aggregate(list(PROP=SPCOM$PROP),by=list(YEAR=SPCOM$YEAR,GEAR=SPCOM$GEAR,BIN=SPCOM$BIN),FUN=sum))
  SPCOM<-data.frame(SPCOM[YEAR>=fsh_start_yr1 & YEAR<=new_SS_dat_year1])


## format length composition data for ss3

  num_gears <- length(unique(SPCOM$GEAR))
  got_one <- FALSE
  # bins  <- len_bins

  SPCOM$GEAR1[SPCOM$GEAR=="TRAWL"]<-1
  SPCOM$GEAR1[SPCOM$GEAR=="LONGLINE"]<-2
  #data$GEAR1[data$GEAR=="LONGLIN"]<-2
  SPCOM$GEAR1[SPCOM$GEAR=="POT"]<-3
  #data$GEAR1[data$GEAR=="OTHER"]<-4

  SPCOM<-SPCOM[order(SPCOM$GEAR,SPCOM$YEAR,SPCOM$BIN),]

  y<-vector("list",length=num_gears)

  for (j in 1:num_gears)
    {
        data1<-subset(SPCOM,SPCOM$GEAR1==j)

        if (dim(data1)[1] > 0)
          {
            years <- sort(unique(data1$YEAR))
            nbin<-length(len_bins1)
            nyr<-length(years)

            x_part<-matrix(ncol=((nbin)+6),nrow=nyr)

            x_part[,2]<-seas
            x_part[,3]<-j
            x_part[,4]<-gender
            x_part[,5]<-part
            x_part[,6]<-Nsamp

            for (i in 1:nyr)
              {
                print(paste("Year ",i))

                x_part[i,1]<-years[i]
                if(Nsamp==-1){
                    x_part[i,6]<-NSAMP$NSAMP[NSAMP$YEAR==years[i] & NSAMP$GEAR1==j]
                  }

                x_part[i,7:(nbin+6)]<-data1$PROP[data1$YEAR==years[i]]
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

   return(x_all)

}
