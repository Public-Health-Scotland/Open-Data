##########################################################
# Name of script - APICombineVacancyFiles
# Original author: Stefan Teufl
# Original date: September 2019
# Latest update author: 04/10/2019
# Latest update date: 04/10/2019
# Type of script: extraction and joining of data
# Version of R that the script was most recently run on: 3.5.1
# Description of content: Using API to extract all resources from a dataset on 
# https://www.opendata.nhs.scot/ and merging/joining files together and attach 
# lookups. DATAFRAME MANIPULATION IS NOT GENERALISED -> future work: Section 3/4 
# generalise to work with other dataset; currently trimmed to consultant-vacancies
# Approximate run time
##########################################################

# start from empty workspace
rm(list=ls())

### 1 - Housekeeping ----

#   loading packages
library(httr) #Version 1.4.0
library(jsonlite) #Version 1.6
library(dplyr) #Version 
library(tidyr)

# Define Variables
# Dataset ID from URL - opendata.nhs.scot/dataset/datasetID or find all with 
# "package_list" API call
datasetID = "consultant-vacancies"

### 2 - Calls to API ----
# Extract all data from dataset and combine to one dataframe (DF)
# Pending on Server/Firewall settings API calls may need to use_proxy
url  <- "https://www.opendata.nhs.scot"

# First call to API to get all resource ID's for a package/dataset
path <- paste0("/api/3/action/package_show?id=",datasetID)
raw.result <- GET(url = url, path = path)

# A value of 200 means the server has received the request
raw.result$status_code

# Translates it into text and parse character string containing JSON file into 
# something R can work with
this.content <- fromJSON(rawToChar(raw.result$content))

# create a list of IDs and an empty list to save data to
vac_id_list <- this.content[[3]]$resources$id
consultant_vacancies_list <- vector("list", length(vac_id_list))

# Loop through ID list to call API for each and save DFs into list
# This is an example of using a set limit of rows from a dataset - if more rows
# are present it will cut off -> therefore proper Version below
# Simplified Version

#for (i in 1:length(vac_id_list)){
#  path <- paste0("/api/3/action/datastore_search?id=",vac_id_list[i],
#                 "&limit=10000")
#  raw.result <- GET(url = url, path = path)
#  this.content <- fromJSON(rawToChar(raw.result$content))
#  consultant_vacancies_list[[i]] <- data.frame(this.content[[3]]$records)
#}

# Proper generalised loop reading out number of records for each resource 
# (default for limit is 100values-read out 1 row to get total number of records)

for (i in 1:length(vac_id_list)){
  path <- paste0("/api/3/action/datastore_search?id=", vac_id_list[i],
                 "&limit=1")
  raw.result <- GET(url = url, path = path)
  this.content <- fromJSON(rawToChar(raw.result$content))
  Totalrecords <- this.content[[3]]$total
  path <- paste0("/api/3/action/datastore_search?id=", vac_id_list[i],
                 "&limit=", Totalrecords)
  raw.result <- GET(url = url, path = path)
  this.content <- fromJSON(rawToChar(raw.result$content))
  consultant_vacancies_list[[i]] <- data.frame(this.content[[3]]$records)
}

# Collapse list of DFs into one DF
consultant_vacancies <- do.call(bind_rows, consultant_vacancies_list)

### 3 - Extract reference data for code lookups ----

# download lookup for healthboards and special boards, as well as Specialties
healthboard <- read.csv(paste0("https://www.opendata.nhs.scot/dataset/",
                               "9f942fdb-e59e-44f5-b534-d6e17229cc7b/",
                               "resource/652ff726-e676-4a20-abda-435b98dd7bdc/",
                               "download/geography_codes_and_labels_hb2014.csv"),
                       stringsAsFactors = FALSE)
specialboard <- read.csv(paste0("https://www.opendata.nhs.scot/dataset/",
                                "65402d20-f0f1-4cee-a4f9-a960ca560444/resource/",
                                "0450a5a2-f600-4569-a9ae-5d6317141899/download/",
                                "special-health-boards.csv"),
                        stringsAsFactors = FALSE)
specialities <- read.csv(paste0("https://www.opendata.nhs.scot/dataset/",
                                "688c7ea0-4845-4b03-9df0-4149c72cb7f0/resource/", 
                                "6f2e3da0-b1b5-46cc-ac04-78495daedfa3/download/",
                                "specialty-reference.csv"),
                        stringsAsFactors = FALSE)

## create one lookup for geographies
# rename columns in specialboard file, combine and add Scotland code to lookup
specialboard <- specialboard %>% 
  rename(HB2014 = SHB2014, HB2014Name = SHB2014Name)
scotland <- data.frame(HB2014 = "S92000003", HB2014Name = "Scotland")
geographies <- bind_rows(healthboard,specialboard,scotland) %>% 
  select(HB2014, HB2014Name)

### 4 - Join Data and Lookups ----
# join file with lookups retaining all records in Vacancy data frame
new <- consultant_vacancies %>% left_join(geographies, by="HB2014") %>% 
  left_join(specialities, by="Specialty")

# Re-order columns and replace 'NAs' with blanks
vacancy_out <- new %>% 
  select(Date, HB2014, HB2014Name, HB2014QF:SpecialtyQF, SpecialtyName, 
         Establishment, EstablishmentQF, StaffInPost, TotalVacancies,
         TotalVacanciesQF,VacanciesGreater6Months,VacanciesGreater6MonthsQF) %>% 
  replace(is.na(.), "") 

# save vacancies file as CSV
write.csv(vacancy_out, file = file.choose(new = TRUE), row.names = FALSE)

### END OF SCRIPT ###