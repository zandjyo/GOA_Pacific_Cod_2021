#
# process GOA Pacific cod survey length-age data
#
# R v3.1.1, ZTA 2014-10-14
#
# adapted from the GOA northern and southern rock sole file, revision 22
# produce 2 tables, one for all cod, and one for M & F cod
#


# SQL query which produced the file
cond_length_age_cor<-function(species=srv_sp_str,area=sp_area,start_year=fsh_start_yr,max_age1=max_age){
    if(area == "'GOA'") survey=47
    if(area == "'AI'") survey=52
    if(area == "'EBS'") survey=98
# 
test<-paste("SELECT s.REGION, TO_CHAR(h.START_TIME, 'yyyy') AS YEAR, s.CRUISEJOIN, s.CRUISE, h.VESSEL, s.HAULJOIN, s.HAUL, s.SPECIES_CODE, s.LENGTH, s.SEX, s.WEIGHT, s.MATURITY, s.AGE, h.END_LATITUDE, h.END_LONGITUDE, h.HAUL_TYPE, h.GEAR, h.PERFORMANCE, s.SPECIMEN_SAMPLE_TYPE, s.SPECIMENID, s.BIOSTRATUM \n",
 "FROM RACEBASE.SPECIMEN s \n ",
 "INNER JOIN RACEBASE.HAUL h \n ",
 "ON s.HAULJOIN = h.HAULJOIN AND s.CRUISEJOIN = h.CRUISEJOIN \n ",
 "JOIN RACE_DATA.V_CRUISES v \n ",
 "ON h.CRUISEJOIN = v.CRUISEJOIN \n ",
 "WHERE v.SURVEY_DEFINITION_ID = ",survey," \n ",
 "AND h.STATIONID IS NOT NULL \n ",
 "AND h.HAUL_TYPE = 3 \n ",
 "AND h.PERFORMANCE >= 0 \n ",
 "AND TO_CHAR(h.START_TIME, 'yyyy') >=",start_year," \n ",
 "AND s.REGION = ", area," \n ",
 "AND s.SPECIES_CODE =",species," \n",
 "ORDER BY s.SPECIES_CODE, TO_CHAR(h.START_TIME, 'yyyy'), s.SEX, s.AGE, s.LENGTH",sep="")

len_age_data<-data.table(sqlQuery(AFSC,test))
len_age_data2<-len_age_data


# age bins to use for srv length age data
bin_width <- 1
min_age <- 1
max_age <- max_age1
age_bins <- seq(min_age,max_age,bin_width)
num.ages <- length(age_bins)

# valid survey years
years <- seq(1984,year(Sys.time()),1)
num.years <- length(years)

# ---!!!---NOTE---!!!---
# In AFSC database, SEX = 1 for MALES, SEX = 2 for FEMALES
# In SS3, SEX = 1 for FEMALES, SEX = 2 for MALES

# convert lengths from mm to cm
len_age_data$LENGTH <- as.integer(len_age_data$LENGTH / 10)

length<-data.frame(LENGTH=c(1:max(len_age_data$LENGTH)))
  length$BIN<-max(len_bins)
  n<-length(len_bins)
  for(i in 2:n-1)
    {
       length$BIN[length$LENGTH < len_bins[((n-i)+1)] ]<-len_bins[n-i]
    }

length2<-merge(len_age_data,length,all.x=T)

# subset of the length-age data where age > 0, length > 0, sex is male or female
# len_age_data.subset <- subset(subset(subset(subset(len_age_data,len_age_data$YEAR %in% years),LENGTH > 0),AGE > 0),SEX %in% c(1,2))
len_age_data.subset <- subset(subset(subset(length2,length2$YEAR %in% years),LENGTH > 0),AGE > 0)
dim(len_age_data.subset)

# change ages larger than max_age into max_age
len_age_data.subset$AGE_FILT <- len_age_data.subset$AGE
len_age_data.subset$AGE_FILT[len_age_data.subset$AGE > max_age] <- max_age

# sort len_age_data.subset by species, year, length, and sex
len_age_data.sort <- len_age_data.subset[ order(len_age_data.subset$YEAR, len_age_data.subset$LENGTH, len_age_data.subset$SEX, len_age_data.subset$AGE), ]
num.rows <- dim(len_age_data.sort)[1]


# For the U/N/S Agecomp_obs table:  concatenate the YEAR and LENGTH together to get the total number of rows
len_age_data.sort$YEAR_LEN <- paste(len_age_data.sort$YEAR,len_age_data.sort$BIN,sep="")

Agecomp_lengths <- sort(unique(len_age_data.sort$YEAR_LEN))
num.lengths <- length(Agecomp_lengths)

# number of samples in row is in column 9
nsamples.col <- 9
num.cols <- nsamples.col + num.ages

Agecomp_obs <- matrix(0,nrow=num.lengths,ncol=num.cols)

# The Year column
Agecomp_obs[,1] <- as.numeric(substr(Agecomp_lengths,1,4))

# The Seas column
Agecomp_obs[,2] <- 1

# The Flt/Svy column
Agecomp_obs[,3] <- 4

# The Sex column
Agecomp_obs[,4] <- 0

# The Ageerr column
Agecomp_obs[,6] <- 1

# The Lbin_lo and Lbin_hi columns
Agecomp_obs[,8] <- Agecomp_obs[,7] <- as.numeric(substr(Agecomp_lengths,5,10))

# go through the dataframe ONCE and do both undifferentiated and species-specific summaries
# column headings of len_age_data(.subset and .sort)
# "REGION","YEAR","CRUISEJOIN",CRUISE","VESSEL","HAULJOIN","HAUL","SPECIES_CODE","LENGTH","SEX","WEIGHT","MATURITY","AGE","END_LATITUDE","END_LONGITUDE","HAUL_TYPE","GEAR","PERFORMANCE","SPECIMEN_SAMPLE_TYPE","SPECIMENID","BIOSTRATUM"
for (i in 1:num.rows)
{
    idx <- which(paste(len_age_data.sort$YEAR[i],len_age_data.sort$BIN[i],sep="") == Agecomp_lengths,arr.ind=TRUE)

    # for U
    if (idx > 0 && idx <= num.lengths)
    {
        # nsamples column
        Agecomp_obs[idx,nsamples.col] <- Agecomp_obs[idx,nsamples.col] + 1

        age.col <- nsamples.col +  len_age_data.sort$AGE_FILT[i]

        Agecomp_obs[idx,age.col] <- Agecomp_obs[idx,age.col] + 1
    }

}
   
# data check; these should equal num.rows
#num.rows
#sum(Agecomp_obs[,nsamples.col])
#sum(Agecomp_obs.sex[,nsamples.col.sex])

# normalize the number of ages per length for each row
for (j in 1:num.lengths)
{
    Agecomp_obs[j,(nsamples.col+1):num.cols] <- Agecomp_obs[j,(nsamples.col+1):num.cols] / Agecomp_obs[j,nsamples.col]
}


Agecomp_obs[,9]<-Agecomp_obs[,9]*0.14

## for GOA Pcod we negate the earlier age data

for(i in 1: nrow(Agecomp_obs)){
    if(Agecomp_obs[i,1]<1990) Agecomp_obs[i,3] <- abs(Agecomp_obs[i,3])*-1
 }


#write.csv(Agecomp_obs,"Agecomp_obs_113.5.csv")
# data check; this should equal num.lengths
#num.lengths
#sum(Agecomp_obs[,(nsamples.col+1):num.cols])

# data check; this should equal num.lengths.sex
#num.lengths.sex
#sum(Agecomp_obs.sex[,(nsamples.col.sex+1):num.cols.sex])

len_data.subset <- subset(subset(len_age_data,len_age_data$YEAR %in% years),LENGTH > 0)
#dim(len_data.subset)

#sort(unique(len_data.subset$HAULJOIN))

# count of number of unique hauls by species/year/sex or year/sex for all
data.yrs <- sort(unique(len_data.subset$YEAR))
num.yrs <- length(data.yrs)

# store number of hauls per year
haul.count <- rep(0,num.yrs)

# store number of samples per year
sample.count <- rep(0,num.yrs)

# get count of number of hauls with lengths per year
for (y in 1:num.yrs)
{
    data.subset <- subset(len_data.subset,len_data.subset$YEAR == data.yrs[y])
    sample.count[y] <- dim(data.subset)[1]
    haul.count[y] <- length(unique(data.subset$HAULJOIN))
}

print(data.yrs)
print(haul.count)
print(sample.count)

output1<-vector("list",length=2)
#output1$sexed<-Agecomp_obs.sex
output1$norm<-Agecomp_obs

return(output1)
}
