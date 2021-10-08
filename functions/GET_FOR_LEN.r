# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

GET_FOR_LEN<-function(fsh_sp_str="99999",start_yr=1977,sp_area="'foo'")
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
        region<-"500 and 539"
    }

    test<-paste("SELECT TO_CHAR(NORPAC.FOREIGN_HAUL.HAUL_JOIN) AS HAUL_JOIN,\n ",
                "NORPAC.FOREIGN_HAUL.YEAR,\n ",
                "NORPAC.FOREIGN_HAUL.GENERIC_AREA,\n ",
                "NORPAC.FOREIGN_HAUL.HOOKS_PER_SKATE,\n ",
                "NORPAC.FOREIGN_HAUL.NUMBER_OF_POTS,\n ",
                "NORPAC.FOREIGN_LENGTH.SPECIES,\n ",
                "NORPAC.FOREIGN_LENGTH.HAUL,\n ",
                "NORPAC.FOREIGN_LENGTH.SEX,\n ",
                "NORPAC.FOREIGN_LENGTH.SIZE_GROUP,\n ",
                "NORPAC.FOREIGN_LENGTH.FREQUENCY,\n ",
                "NORPAC.FOREIGN_HAUL.LATITUDE,\n ",
                "NORPAC.FOREIGN_HAUL.E_W,\n ",
                "NORPAC.FOREIGN_HAUL.LONGITUDE \n ",
                "FROM NORPAC.FOREIGN_HAUL\n ",
                "INNER JOIN NORPAC.FOREIGN_LENGTH\n ",
                "ON NORPAC.FOREIGN_HAUL.HAUL_JOIN = NORPAC.FOREIGN_LENGTH.HAUL_JOIN\n ",
                "WHERE NORPAC.FOREIGN_HAUL.YEAR > ",start_yr,"\n ",
                "AND NORPAC.FOREIGN_HAUL.GENERIC_AREA BETWEEN ",region,"\n ",
                incl_str,
                "AND NORPAC.FOREIGN_LENGTH.SPECIES in (",fsh_sp_str,")\n ",
                "ORDER BY NORPAC.FOREIGN_HAUL.YEAR",sep="")

    Flength=sqlQuery(AFSC,test)
    Flength$GEAR<-1
    Flength$GEAR[Flength$HOOKS_PER_SKATE > 0]  <- 8
    Flength$GEAR[Flength$NUMBER_OF_POTS > 0]<-6
    Flength<-subset(Flength,select=-c(HOOKS_PER_SKATE,NUMBER_OF_POTS))

    Flength
}

