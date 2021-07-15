##########################################################
# Name of script - Access opendata.nhs.scot with ckanr
# Original author: Csilla Scharle
# Original date: June 2021
# Latest update author:
# Latest update date:
# Type of script: extraction data & metadata from CKAN
# Version of R that the script was most recently run on: 3.6.1
# Description of content: Using API to connect to https://www.opendata.nhs.scot/,
# extract lists of packages, resources and metadata info
# Approximate run time - 2 mins
##########################################################


### 1 - Housekeeping ----

library(ckanr)
library(dplyr)



### 2 - Set connection to CKAN instance ---- 

ckanr_setup(url = "https://www.opendata.nhs.scot/")



### 3 - List datasets ---- 

# note: default limit is 31 datasets, so to capture all this needs to be set as higher. 
#Currently there are 87 datasets on opendata.nhs.scot

package_list(as = "table", limit = 100)

# Alternative option - list all datasets with metadata information included

package_list_current(as = "table", limit = 100)



### 4 - List tags ----  
#Get list of tags used on nhs.opendata.scot

tags <- tag_list(as = "table")



### 5 - List groups ----  
#Get list of groups used on nhs.opendata.scot

groups <- group_list(all_fields = T, as = "table")



### 6 - List datasets by theme, group, tag ---- 

##basic query searching datasets by keyword

query_datasets <- package_search(q = "covid-19", as = "table")

##tags - tags can be listed using tag_list as in section 4

query_datasets <- package_search(fq = 'tags:covid-19', as = "table")

##groups - note this uses the name of the group, not display_name. 
#these can be listed using group_list as in section 5

query_datasets <- package_search(fq = 'groups:waiting-times', as = "table")

#all three queries return results in a list
#need to extract results to view as table of datasets + metadata information

query_datasets[["results"]]         



### 7 - Get dataset metadata ----  

metadata <- package_show(id = "covid-19-vaccination-in-scotland", as = "table")



### 8 - List resources in a dataset ----

metadata <- package_show(id = "covid-19-vaccination-in-scotland", as = "table")

res_list <- metadata$resources %>% 
  as_tibble() %>%
  select(name, id, size, mimetype, last_modified, url, description)



### 9 - Get resource metadata ---- 

res_metadata <- resource_show(id = "42f17a3c-a4db-4965-ba68-3dffe6bca13a", as = "table")


### END OF SCRIPT ###