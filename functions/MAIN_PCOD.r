# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2021-10-07, R version 4.05.01 64 bit
### GOA Pacific cod

## write SS3 files for stock assessment

libs <- c("tidyverse", "RODBC","mgcv","FSA","nlstools","data.table","ggplot2","sizeMat","devtools","r4ss","lubridate","rgdal")

if(length(libs[which(libs %in% rownames(installed.packages()) == FALSE )]) > 0) {
  install.packages(libs[which(libs %in% rownames(installed.packages()) == FALSE)])}
lapply(libs, library, character.only = TRUE)


afsc_user="xxxx"   ## enter afsc username
afsc_pass="xxxx" ## enter afsc password
akfin_user="xxxx"  ## enter AKFIN username
akfin_pass="xxxx" ## enter AKFIN password


AFSC=odbcConnect("AFSC",afsc_user,afsc_pass,believeNRows=FALSE)
CHINA=odbcConnect("AKFIN",akfin_user,akfin_pass,believeNRows=FALSE)


## DEFINE ALL CONSTANTS FOR THIS RUN

# is this a new SS DAT file
is_new_SS_DAT_file <- FALSE

# this assumes that the FUNCTIONS subdirectory is in the working directory
working_dir <- "C:/WORKING_FOLDER/2021 Stock Assessments/2021 Pacific cod/DATA"

# previous SS DAT filename, if it exists
old_SS_dat_filename <- "GOAPcod2021SEP28_10P.dat"

# current SS DAT filename
new_SS_dat_filename <- "GOAPcod2021OCT1_10P.dat"

# the most recent year of data to be used
new_SS_dat_year <- 2021
final_year <- new_SS_dat_year

# the FMP area for this stock
sp_area <- "'GOA'"

# the GOA FMP sub-areas in the COUNCIL.COMPREHENSIVE_BLEND_CA database table
fsh_sp_area <- "'CG','PWSI','SE','SEI','WG','WY'"

# species label for AKFIN
fsh_sp_label <- "'PCOD'"

# the fishery species code(s) for this stock/these stocks
fsh_sp_str <- "202"

# year in which to start the fishery data
fsh_start_yr <- 1977

# fraction of the year that the fishery length- and weight-at-age calculations are done
fsh_frac <- 0.5

# the survey species code(s) for this stock/these stocks
srv_sp_str <- "21720"

# year in which to start the bottom trawl survey data
srv_start_yr <- 1984

# year in which to start the LL survey data
LLsrv_start_yr <- 1990

# fraction of the year that the survey takes place
srv_frac <- 0.5833333333

# length bins to use for fsh and srv length comp data
bin_width <- 1
min_size <- 0.5
max_size <- 116.5  # less than 1% of the fish in each year are 105 cm or larger (max less than 0.6%)
len_bins <- seq(min_size,max_size,bin_width)

# maximum age
max_age <- 10


## Get all the functions for pulling GOA Pcod data

setwd(paste(working_dir,"\\Functions",sep=""))

source_files=c("BIN_LEN_DATA.r", "cond_length_age_corFISH.r","conditional_Length_AGE_cor.r","FIND_AGE_LENGTH_KEY.r", "find_AL_map.r",                
     "find_ALF.r", "FISH_AGE_COMP.r", "FORMAT_ACOMP.r", "FORMAT_AGE_LENGTH.r", "FORMAT_AGE_MEANS1.r",    
     "FORMAT_AGE_WEIGHT.r", "FORMAT_FISH_LCOMP.r", "FORMAT_LL_LCOMP.r", "FORMAT_SUR_LCOMP.r", "GET_CATCH.r",                  
     "GET_CATCH_AT_SIZE.r", "GET_DOM_AGE.r", "GET_DOM_LEN.r", "GET_DOM_SPCOMP.r", "GET_FOR_AGE.r", "GET_FOR_LEN.r",               
     "GET_FOR_SPCOMP.r", "GET_GOA_ACOMP1.r", "GET_GOA_BIOM.r", "GET_GOA_LCOMP1.r",           
     "GET_GOA_LENCOM2.r", "GET_LENGTH_BY_CATCH_GOA.R", "GET_GOA_LL_RPN.r",            
     "GET_SURV_AGE.r", "GET_SURV_AGE_cor.r", "GET_SURV_LEN.r") 


lapply(source_files, source)


## Get all the alternative data that isn't in AKFIN or AFSC databases
setwd(paste(working_dir,"\\functions\\ALT_DATA",sep=""))

test_file <- "OLD_SEAS_GEAR_CATCH.csv"
if (!file.access(test_file,mode=4))
   {
    OLD_SEAS_GEAR_CATCH<-read.csv("OLD_SEAS_GEAR_CATCH.csv",header=T)
   }


test_file <- "Larval_indices.csv"
if (!file.access(test_file,mode=4))
{
    Larval_indices <- read.csv(test_file,header=T)
}


test_file <- "Aging_error.csv"
if (!file.access(test_file,mode=4))
{
    AGING_ERROR_CSV <- read.csv(test_file,header=T)
}

test_file <- "ADFG_IPHC.csv"
  if (!file.access(test_file,mode=4))
 {
    ADFG_IPHC <- read.csv(test_file,header=T)
 }

test_file <- "ALL_STATE_LENGTHS.csv"
  if (!file.access(test_file,mode=4))
 {
    ALL_STATE_LENGTHS <- read.csv(test_file,header=T)
 }


## get all data for data file
setwd(working_dir)
source("SBSS_GET_ALL_DATA_GOA_PCOD_cor.r")


 if (!is_new_SS_DAT_file && !file.access(old_SS_dat_filename,mode=4))
  {
    old_data <- SS_readdat_3.30(old_SS_dat_filename)
    new_data <- old_data
  }else{print(" Warning:  Need to enter old SS data file name")}

new_data <- SBSS_GET_ALL_DATA(new_data           = new_data,
                              new_file           = new_SS_dat_filename,
                              LL_length          = LL_LENGTH_FILE,
                              new_year           = new_SS_dat_year,
                              sp_area            = sp_area,
                              fsh_sp_label       = fsh_sp_label,
                              fsh_sp_area        = fsh_sp_area,
                              fsh_sp_str         = fsh_sp_str,
                              fsh_start_yr       = fsh_start_yr,
                              srv_sp_str         = srv_sp_str,
                              srv_start_yr       = srv_start_yr,
                              len_bins           = len_bins,
                              max_age            = max_age,
                              is_new_SS_DAT_file = is_new_SS_DAT_file,
		 AUXFCOMP             = 3)


# write out SS DAT file

SS_writedat_3.30(new_data,new_SS_dat_filename,overwrite=T)


Add_climate(Old_datafile=new_SS_dat_filename, New_datafile=new_SS_dat_filename, dir1=paste0(working_dir,"/functions/ALT_DATA",dir2=working_dir)



# test that the new file is readable
test_dat <- SS_readdat_3.30(new_SS_dat_filename,verbose=TRUE)

## ctrl file needs to be edited manually due to complexity at this time.

close(AFSC)
close(CHINA)

