# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

GET_DOM_LEN<-function(fsh_sp_str="99999",sp_area="'foo'")
{
    incl_str <- ""
    if(sp_area=="'AI'")
    {
        region<-"539 and 544"
    }
    if(sp_area=="'GOA'")
    {
        region<-"600 and 699"
        incl_str <- "AND OBSINT.DEBRIEFED_LENGTH.NMFS_AREA != 670\n "
    }
    if(sp_area=="'BS'")
    {
        region<-"500 and 539"
    }

    test<-paste("SELECT OBSINT.DEBRIEFED_LENGTH.YEAR,\n ",
                "OBSINT.DEBRIEFED_LENGTH.NMFS_AREA,\n ",
                "OBSINT.DEBRIEFED_LENGTH.SPECIES,\n ",
                "OBSINT.DEBRIEFED_LENGTH.HAUL_OFFLOAD,\n ",
                "OBSINT.DEBRIEFED_LENGTH.SEX,\n ",
                "OBSINT.DEBRIEFED_LENGTH.LENGTH,\n ",
                "OBSINT.DEBRIEFED_LENGTH.FREQUENCY,\n ",
                "OBSINT.DEBRIEFED_LENGTH.LATDD_END,\n ",
                "OBSINT.DEBRIEFED_LENGTH.LONDD_END,\n ",
                "TO_CHAR(OBSINT.DEBRIEFED_LENGTH.PORT_JOIN) AS PORT_JOIN,\n ",
                "TO_CHAR(OBSINT.DEBRIEFED_LENGTH.HAUL_JOIN) AS HAUL_JOIN,\n ",
                "OBSINT.DEBRIEFED_LENGTH.VESSEL_TYPE,\n ",
                "OBSINT.DEBRIEFED_LENGTH.GEAR\n ",
                "FROM OBSINT.DEBRIEFED_LENGTH\n ",
                "WHERE OBSINT.DEBRIEFED_LENGTH.NMFS_AREA BETWEEN ",region,"\n",
                incl_str,
                "AND OBSINT.DEBRIEFED_LENGTH.SPECIES in (",fsh_sp_str,")\n ",
                "ORDER BY OBSINT.DEBRIEFED_LENGTH.YEAR",sep="")

    Dlength=sqlQuery(AFSC,test)
    Dlength
}

