# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

GET_FOR_AGE<-function(fsh_sp_str="99999",start_yr=1977,sp_area="'foo'",max_age=30)
{
    incl_str <- ""
    if(sp_area=="'AI'")
    {
        region<-"539 and 544"
    }
    if(sp_area=="'GOA'")
    {
        region<-"600 and 699"
        incl_str <- "AND NORPAC.FOREIGN_HAUL.GENERIC_AREA != 670\n "
    }
    if(sp_area=="'BS'")
    {
        region <-"500 and 539"
    }

    test <- paste("SELECT NORPAC.FOREIGN_HAUL.YEAR,\n ",
                  "NORPAC.FOREIGN_HAUL.GENERIC_AREA,\n ",
                  "NORPAC.FOREIGN_HAUL.HOOKS_PER_SKATE,\n ",
                  "NORPAC.FOREIGN_HAUL.NUMBER_OF_POTS,\n ",
                  "NORPAC.FOREIGN_AGE.SPECIES,\n ",
                  "NORPAC.FOREIGN_AGE.HAUL,\n ",
                  "NORPAC.FOREIGN_AGE.SEX,\n ",
                  "NORPAC.FOREIGN_AGE.LENGTH,\n ",
                  "NORPAC.FOREIGN_AGE.AGE,\n ",
                  "NORPAC.FOREIGN_AGE.INDIV_WEIGHT,\n ",
                  "TO_CHAR(NORPAC.FOREIGN_AGE.HAUL_JOIN) AS HAUL_JOIN,\n ",
                  "NORPAC.FOREIGN_HAUL.LATITUDE,\n ",
                  "NORPAC.FOREIGN_HAUL.E_W,\n ",
                  "NORPAC.FOREIGN_HAUL.LONGITUDE\n ",
                  "FROM NORPAC.FOREIGN_HAUL\n ",
                  "INNER JOIN NORPAC.FOREIGN_AGE\n ",
                  "ON NORPAC.FOREIGN_HAUL.HAUL_JOIN = NORPAC.FOREIGN_AGE.HAUL_JOIN\n ",
                  "WHERE NORPAC.FOREIGN_HAUL.YEAR > ",start_yr,"\n",
                  "AND NORPAC.FOREIGN_HAUL.GENERIC_AREA BETWEEN ",region,"\n",
                  incl_str,
                  "AND NORPAC.FOREIGN_AGE.SPECIES in (",fsh_sp_str,")\n",
                  "ORDER BY NORPAC.FOREIGN_HAUL.YEAR",sep="")

    Fage=sqlQuery(AFSC,test)
    Fage$GEAR<-1
    Fage$GEAR[Fage$HOOKS_PER_SKATE > 0]  <- 8
    Fage$GEAR[Fage$NUMBER_OF_POTS > 0]<-6
    Fage<-subset(Fage,select=-c(HOOKS_PER_SKATE,NUMBER_OF_POTS))

    Fage$AGE1<-Fage$AGE
    Fage$AGE1[Fage$AGE >= max_age]=max_age

    Fage
}

