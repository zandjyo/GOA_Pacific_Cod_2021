# adapted/generalized from Steve Barbeaux' files for
# generating SS files for EBS/AI Greenland Turbot
# ZTA, 2013-05-08, R version 2.15.1, 32-bit

GET_GOA_BIOM <- function(srv_sp_str="99999")
{
    test<-paste("SELECT GOA.BIOMASS_TOTAL.YEAR as YEAR,\n ",
                "GOA.BIOMASS_TOTAL.TOTAL_BIOMASS as BIOM,\n ",
                "GOA.BIOMASS_TOTAL.TOTAL_POP as POP,\n ",
                "GOA.BIOMASS_TOTAL.BIOMASS_VAR as BIOMVAR,\n ",
                "GOA.BIOMASS_TOTAL.POP_VAR as POPVAR,\n ",
                "GOA.BIOMASS_TOTAL.HAUL_COUNT as NUMHAULS,\n ",
                "GOA.BIOMASS_TOTAL.CATCH_COUNT as NUMCAUGHT\n ",
                "FROM GOA.BIOMASS_TOTAL\n ",
                "WHERE GOA.BIOMASS_TOTAL.SPECIES_CODE in (",srv_sp_str,")\n ",
                "ORDER BY GOA.BIOMASS_TOTAL.YEAR",sep="")

    biom <- sqlQuery(AFSC,test)

    # this calculation assumes that YEAR is the first column for biom
    sum.biom <- aggregate(biom[,-1],by=list(YEAR=biom$YEAR),FUN=sum)
    sum.biom

}

