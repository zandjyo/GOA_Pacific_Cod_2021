# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

# 2013-07-16 - per Nancy Roberson, use "RACEBASE.specimen_orig" instead of "RACEBASE.SPECIMEN" for now

##GOA and AI BT = 172, BS = 44 pollock - 21740 Greenland turbot=10115
GET_SURV_AGE <- function(sp_area="'foo'",srv_sp_str="99999",start_yr=1977,max_age=30)
{

    if(sp_area=="'GOA'"){ survey<- 47
     } else if(sp_area=="'BS'"){ survey<- 98
       } else if(sp_area=="'AI'"){ survey<- 52
         } else if(sp_area=="'SLOPE'"){ survey<- 78
           } else { stop("Not a valid survey")}
    
    
    
    test<-paste("SELECT RACEBASE.SPECIMEN.REGION,\n ",
                "RACE_DATA.V_CRUISES.YEAR AS YEAR,\n ",
                "RACEBASE.SPECIMEN.CRUISE,\n ",
                "RACEBASE.HAUL.VESSEL,\n ",
                "RACEBASE.SPECIMEN.HAULJOIN,\n ",
                "RACEBASE.SPECIMEN.HAUL,\n ",
                "RACEBASE.SPECIMEN.SPECIES_CODE,\n ",
                "RACEBASE.SPECIMEN.LENGTH,\n ",
                "RACEBASE.SPECIMEN.SEX,\n ",
                "RACEBASE.SPECIMEN.WEIGHT,\n ",
                "RACEBASE.SPECIMEN.MATURITY,\n ",
                "RACEBASE.SPECIMEN.AGE,\n ",
                "RACEBASE.HAUL.END_LONGITUDE,\n ",
                "RACEBASE.HAUL.HAUL_TYPE,\n ",
                "RACEBASE.HAUL.GEAR,\n ",
                "RACEBASE.HAUL.PERFORMANCE,\n ",
                "RACEBASE.SPECIMEN.SPECIMEN_SAMPLE_TYPE,\n ",
                "RACEBASE.SPECIMEN.SPECIMENID,\n ",
                "RACEBASE.SPECIMEN.BIOSTRATUM\n ",
                "FROM RACE_DATA.V_CRUISES \n",
                "INNER JOIN RACEBASE.HAUL \n",
                "ON RACEBASE.HAUL.CRUISEJOIN = RACE_DATA.V_CRUISES.CRUISEJOIN \n",
                "INNER JOIN RACEBASE.SPECIMEN \n",
                "ON RACEBASE.SPECIMEN.CRUISEJOIN = RACEBASE.HAUL.CRUISEJOIN \n",
                "AND RACEBASE.SPECIMEN.HAULJOIN  = RACEBASE.HAUL.HAULJOIN \n",
                "WHERE RACE_DATA.V_CRUISES.SURVEY_DEFINITION_ID = ", survey," \n",
                "AND RACEBASE.SPECIMEN.SPECIES_CODE in (",srv_sp_str,") \n",
                "AND RACEBASE.HAUL.HAUL_TYPE = 3 \n",
                "AND RACEBASE.HAUL.PERFORMANCE >= 0 \n", 
                "AND RACEBASE.HAUL.STATIONID IS NOT NULL \n",
                "AND RACE_DATA.V_CRUISES.YEAR >=",start_yr,"\n ",
                "ORDER BY RACE_DATA.V_CRUISES.YEAR",sep="")

    Age=sqlQuery(AFSC,test)

    Age$AGE1<-Age$AGE
    Age$AGE1[Age$AGE >= max_age]=max_age

    Age
}
