# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

##GOA and AI BT = 172, BS = 44 pollock - 21740 Greenland turbot=10115
GET_SURV_LEN <- function(sp_area="'BS'",srv_sp_str="99999",start_yr=1977)
{

    if(sp_area=="'GOA'"){ survey<- 47
     } else if(sp_area=="'BS'"){ survey<- 98
       } else if(sp_area=="'AI'"){ survey<- 52
         } else if(sp_area=="'SLOPE'"){ survey<- 78
           } else { stop("Not a valid survey")}
    
    test<-paste("SELECT RACEBASE.LENGTH.REGION,\n ",
                "RACE_DATA.V_CRUISES.YEAR AS YEAR,\n ",
                "RACEBASE.LENGTH.CRUISE,\n ",
                "RACEBASE.LENGTH.VESSEL,\n ",
                "RACEBASE.LENGTH.HAULJOIN,\n ",
                "RACEBASE.LENGTH.HAUL,\n ",
                "RACEBASE.LENGTH.SPECIES_CODE,\n ",
                "RACEBASE.LENGTH.SEX,\n ",
                "RACEBASE.LENGTH.LENGTH,\n ",
                "RACEBASE.LENGTH.FREQUENCY,\n ",
                "RACEBASE.HAUL.END_LONGITUDE,\n ",
                "RACEBASE.HAUL.GEAR,\n ",
                "RACEBASE.HAUL.STRATUM,\n ",
                "RACEBASE.HAUL.HAUL_TYPE\n ",
                "FROM RACE_DATA.V_CRUISES \n",
                "INNER JOIN RACEBASE.HAUL \n",
                "ON RACEBASE.HAUL.CRUISEJOIN = RACE_DATA.V_CRUISES.CRUISEJOIN \n",
                "INNER JOIN RACEBASE.LENGTH \n",
                "ON RACEBASE.LENGTH.CRUISEJOIN = RACEBASE.HAUL.CRUISEJOIN \n",
                "AND RACEBASE.LENGTH.HAULJOIN  = RACEBASE.HAUL.HAULJOIN \n",
                "WHERE RACE_DATA.V_CRUISES.SURVEY_DEFINITION_ID = ", survey," \n",
                "AND RACEBASE.HAUL.HAUL_TYPE = 3 \n",
                "AND RACEBASE.HAUL.PERFORMANCE >= 0 \n", 
                "AND RACEBASE.HAUL.STATIONID IS NOT NULL \n",
                "AND RACE_DATA.V_CRUISES.YEAR >=",start_yr,"\n ",sep="")

    Length=sqlQuery(AFSC,test)

    Length
}

