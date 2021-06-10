##########################################################
# Name of script - APICombineVacancyFiles
# Original author: Csilla Scharle
# Original date: May 2021
# Type of script: extraction of filtered open data
# Version of R that the script was most recently run on: 3.6.1
# Description of content: Using API to extract subset of resource based on Date column. 
# Can be generalised to other resources containing Date information. 
# Approximate run time - depends on size of data extracted

#############################################################
### Housekeeping ----
#############################################################

# empty workspace

rm(list=ls())

library(dplyr)
library(glue)
library(readr)
library(ckanr)
library(lubridate)

# set dates for filtering

date_today <- strftime(Sys.Date(), format = "%Y%m%d")
date_3m_ago <- strftime(Sys.Date() %m-% months(3), format = "%Y%m%d")

# set filepath to where the csv file should be saved
path_to_write_file <- ""


#############################################################
### Extract data from CKAN ----
#############################################################

# depending on firewall settings, may need to configure proxy to access CKAN 
# using the below with proxy details specified
# library(httr)
# set_config(use_proxy(url = "",  port = ))

# set ckan connection
ckan <- src_ckan("https://www.opendata.nhs.scot")

#set resource id-s to use - this example features Covid Case Data
res_id <- "427f9a25-db22-4014-a3bc-893b68243055"

# extract & filter data for last 3 months:
# select() here is optional, and included to ensure desired order of columns

filtered_data <- dplyr::tbl(src = ckan$con, from = res_id) %>% 
  as_tibble() %>%
  filter(date_3m_ago < Date & Date < date_today)%>%
  select("Date","CA", "CAName", "DailyPositive", "CumulativePositive", "CrudeRatePositive", "CrudeRate7DayPositive",
         "DailyDeaths", "CumulativeDeaths", "CrudeRateDeaths", "DailyNegative", "CumulativeNegative", "CrudeRateNegative",
         "TotalTests", "PositivePercentage", "PositivePercentage7Day", "TotalPillar1", "TotalPillar2", "PositivePillar1",
         "PositivePillar2")%>%
  arrange(Date, CAName)


write_csv(case_trends_la, path = path_to_write_file)
