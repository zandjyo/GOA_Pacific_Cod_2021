# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

## get domestic species comp data

GET_DOM_SPCOMP<-function(fsh_sp_str="99999",sp_area="'foo'")
{
    incl_str <- ""
    if(sp_area=="'AI'")
    {
        region<-"539 and 544"
    }
    if(sp_area=="'GOA'")
    {
        region<-"600 and 699"
        incl_str <- "AND OBSINT.DEBRIEFED_HAUL.NMFS_AREA != 670\n "
    }
    if(sp_area=="'BS'")
    {
        region<-"500 and 539"
    }

    test <- paste("SELECT TO_CHAR(OBSINT.DEBRIEFED_SPCOMP.HAUL_JOIN) AS HAUL_JOIN,\n ",
                  "OBSINT.DEBRIEFED_SPCOMP.SPECIES,\n ",
                  "OBSINT.DEBRIEFED_SPCOMP.EXTRAPOLATED_NUMBER,\n ",
                  "OBSINT.DEBRIEFED_SPCOMP.EXTRAPOLATED_WEIGHT\n ",
                  "FROM OBSINT.DEBRIEFED_HAUL\n ",
                  "INNER JOIN OBSINT.DEBRIEFED_SPCOMP\n ",
                  "ON OBSINT.DEBRIEFED_HAUL.HAUL_JOIN = OBSINT.DEBRIEFED_SPCOMP.HAUL_JOIN\n ",
                  "WHERE OBSINT.DEBRIEFED_HAUL.NMFS_AREA between ",region,"\n",
                  incl_str,
                  "AND OBSINT.DEBRIEFED_SPCOMP.SPECIES in (",fsh_sp_str,")",sep="")

    Dspcomp=sqlQuery(AFSC,test)
    Dspcomp
}

