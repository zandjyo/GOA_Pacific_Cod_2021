# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

GET_DOM_AGE<-function(fsh_sp_str="99999",sp_area="'foo'",max_age=30)
{
    incl_str <- ""
    if(sp_area=="'AI'")
    {
        region<-"539 and 544"
    }
    if(sp_area=="'GOA'")
    {
        region<-"600 and 699"
        incl_str <- "AND OBSINT.DEBRIEFED_AGE.NMFS_AREA != 670\n "
    }
    if(sp_area=="'BS'")
    {
        region<-"500 and 539"
    }

    test <- paste("SELECT OBSINT.DEBRIEFED_AGE.YEAR,\n ",
                  "OBSINT.DEBRIEFED_AGE.NMFS_AREA,\n ",
                  "OBSINT.DEBRIEFED_AGE.SPECIES,\n ",
                  "OBSINT.DEBRIEFED_AGE.HAUL_OFFLOAD,\n ",
                  "OBSINT.DEBRIEFED_AGE.SEX,\n ",
                  "OBSINT.DEBRIEFED_AGE.LENGTH,\n ",
                  "OBSINT.DEBRIEFED_AGE.AGE,\n ",
                  "OBSINT.DEBRIEFED_AGE.WEIGHT,\n ",
                  "OBSINT.DEBRIEFED_AGE.LATDD_END,\n ",
                  "OBSINT.DEBRIEFED_AGE.LONDD_END,\n ",
                  "CONCAT('P',TO_CHAR(OBSINT.DEBRIEFED_AGE.PORT_JOIN)) AS PORT_JOIN,\n ",
                  "CONCAT('H',TO_CHAR(OBSINT.DEBRIEFED_AGE.HAUL_JOIN)) AS HAUL_JOIN,\n ",
                  "OBSINT.DEBRIEFED_AGE.GEAR\n ",
                  "FROM OBSINT.DEBRIEFED_AGE\n ",
                  "WHERE OBSINT.DEBRIEFED_AGE.NMFS_AREA BETWEEN ",region,"\n ",
                  incl_str,
                  "AND OBSINT.DEBRIEFED_AGE.SPECIES in (",fsh_sp_str,")\n ",
                  "ORDER BY OBSINT.DEBRIEFED_AGE.YEAR",sep="")

    Dage=sqlQuery(AFSC,test)

    Dage$AGE1<-Dage$AGE
    Dage$AGE1[Dage$AGE >= max_age]=max_age

    Dage
}
