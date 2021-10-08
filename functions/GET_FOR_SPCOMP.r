# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

GET_FOR_SPCOMP <- function(fsh_sp_str="99999",sp_area="'foo'")
{
    incl_str <- ""

    if(sp_area=="'AI'")
    {
        region <- "539 and 544"
    }
    if(sp_area=="'GOA'")
    {
        region <- "600 and 699"
        incl_str <- "AND NORPAC.FOREIGN_HAUL.GENERIC_AREA != 670\n "
    }
    if(sp_area=="'BS'")
    {
        region <- "500 and 539"
    }

    test <- paste("SELECT TO_CHAR(NORPAC.FOREIGN_SPCOMP.HAUL_JOIN) AS HAUL_JOIN,\n ",
                  "NORPAC.FOREIGN_SPCOMP.SPECIES,\n ",
                  "NORPAC.FOREIGN_SPCOMP.SPECIES_HAUL_NUMBER,\n ",
                  "NORPAC.FOREIGN_SPCOMP.SPECIES_HAUL_WEIGHT\n ",
                  "FROM NORPAC.FOREIGN_HAUL\n ",
                  "INNER JOIN NORPAC.FOREIGN_SPCOMP\n ",
                  "ON NORPAC.FOREIGN_HAUL.HAUL_JOIN = NORPAC.FOREIGN_SPCOMP.HAUL_JOIN\n ",
                  "WHERE NORPAC.FOREIGN_HAUL.GENERIC_AREA between ",region,"\n ",
                  incl_str,
                  "AND NORPAC.FOREIGN_SPCOMP.SPECIES in (",fsh_sp_str,")",sep="")

    Fspcomp=sqlQuery(AFSC,test)
    Fspcomp
}

