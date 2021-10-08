# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

GET_CATCH <- function(fsh_sp_area="'foo'",fsh_sp_label="'foo'",final_year=9999,ADD_OLD_FILE=FALSE,OLD_FILE="OLD_CATCH.csv")
{
    test <- paste("SELECT SUM(COUNCIL.COMPREHENSIVE_BLEND_CA.WEIGHT_POSTED)AS TONS,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_SUBAREA AS ZONE,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_GEAR AS GEAR,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.RETAINED_OR_DISCARDED AS TYPE,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR AS YEAR,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.SPECIES_GROUP_CODE AS SPECIES_GROUP\n ",
                  "FROM COUNCIL.COMPREHENSIVE_BLEND_CA\n ",
                  "WHERE COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_SUBAREA in (",fsh_sp_area,")\n ",
                  "AND COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR <= ",final_year,"\n ",
                  "AND COUNCIL.COMPREHENSIVE_BLEND_CA.SPECIES_GROUP_CODE in (",fsh_sp_label,")\n ",
                  "GROUP BY COUNCIL.COMPREHENSIVE_BLEND_CA.SPECIES_GROUP_CODE,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_SUBAREA,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.FMP_GEAR,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.RETAINED_OR_DISCARDED,\n ",
                  "COUNCIL.COMPREHENSIVE_BLEND_CA.YEAR\n ", sep="")


    CATCH<-sqlQuery(CHINA,test)

    CATCH$GEAR1<-"TRAWL"

    # CATCH$GEAR1[CATCH$GEAR=="POT"]<-"FIXED"
    # CATCH$GEAR1[CATCH$GEAR=="HAL"]<-"FIXED"
    # CATCH$GEAR1[CATCH$GEAR=="JIG"]<-"FIXED"

    CATCH$GEAR1[CATCH$GEAR=="POT"]<-"POT"
    CATCH$GEAR1[CATCH$GEAR=="HAL"]<-"LONGLINE"
    CATCH$GEAR1[CATCH$GEAR=="JIG"]<-"OTHER"

    CATCH_TOTAL<-aggregate(list(TONS=CATCH$TONS),by=list(YEAR=CATCH$YEAR,GEAR=CATCH$GEAR1),FUN=sum)

    if(ADD_OLD_FILE)
    {
        OLD_CATCH<-read.csv(OLD_FILE,header=T)
        CATCH_TOTAL<-rbind(OLD_CATCH,CATCH_TOTAL)
    }

    CATCH<-list(CATCH_TOTAL=CATCH_TOTAL,CATCH=CATCH)
    CATCH
}



