## getting AFSC longline survey data


GET_GOA_LL_RPN<-function(species=srv_sp_str,FYR=LLsrv_start_yr){
       
     goarpn <- sqlQuery(CHINA, query = paste0("
                select    *
                from      afsc.lls_area_rpn_all_strata
                where     species_code =",species," and 
                          country = 'United States' and
                          year >=",FYR," and 
                          exploitable = 1 and
                          fmp_management_area = 'GOA'
                order by  year asc
                ")) %>% 
  rename_all(tolower)


     goa_rpn <- goarpn %>% 
       group_by(year) %>% 
       summarize(rpn = sum(rpn, na.rm = TRUE),
                 se = sqrt(sum(rpn_var, na.rm = TRUE)))%>%data.table()
     return(goa_rpn)
}


GET_GOA_LL_LENGTH<-function(species=srv_sp_str,FYR=LLsrv_start_yr){

     lens <- sqlQuery(CHINA, query = paste0("
                select    *
                from      afsc.lls_length_rpn_by_area_all_strata
                where     species_code =",species," and 
                          country = 'United States' and 
                          year >=",FYR," and
                          council_sablefish_management_area not in ('Bering Sea', 'Aleutians') and
                          length < 999
                order by  year asc
                ")) %>% 
      rename_all(tolower)

     areaview <- sqlQuery(CHINA, query = ("
                select distinct   council_sablefish_management_area, council_management_area, 
                                  fmp_management_area, geographic_area_name, 
                                  exploitable, area_code
                from              afsc.lls_area_view
                ")) %>% 
     rename_all(tolower)

     lens <- lens %>% 
          left_join(areaview, by = c("area_code", "geographic_area_name", "council_sablefish_management_area"))

     lens <- lens %>% filter(exploitable == 1)

     # RPN-weighted lengths in the GOA

     lensum <- lens %>% 
       group_by(year, length)%>% 
       summarize(rpn = sum(rpn))%>%data.table()

     return(lensum)  
}




