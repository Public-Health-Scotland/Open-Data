library(dplyr)
library(ckanr)

# set ckan connection
ckan <- src_ckan("https://www.opendata.nhs.scot")

#set resource id-s to use
res_id <- "42f17a3c-a4db-4965-ba68-3dffe6bca13a"

# extract data:

case_trends_la <- dplyr::tbl(src = ckan$con, from = res_id) %>% 
  as_tibble()


##DUMP

#set ckan connection
ckan_url <- "https://www.opendata.nhs.scot"

dump_data <- readr::read_csv(glue::glue("{ckan_url}/datastore/dump/{res_id}?bom=true"))%>%
  dplyr::select(-"_id")
