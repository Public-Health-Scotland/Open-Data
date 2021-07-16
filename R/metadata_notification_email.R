### Script to query changes to metadata for a CKAN dataset & send conditional email notification

## need to set up a gmail account and a google project to use gmailr - see https://github.com/r-lib/gmailr for Setup instructions

# Housekeeping
# empty workspace

rm(list=ls())

library(dplyr)
library(stringr)
library(glue)
library(ckanr)
library(readr)
library(berryFunctions)
library(gmailr)


# Setup connection
ckanr_setup(url = "https://www.opendata.nhs.scot")

# set dataset - this example uses COVID-19 Vaccination in Scotland
dataset_id <- "6dbdd466-45e3-4348-9ee3-1eac72b5a592"
dataset <- "covid-19-vaccination-in-scotland"

# pull metadata
metadata <- package_show("covid-19-vaccination-in-scotland")
tmp <- tempfile()
write_file(metadata$notes, tmp)

tempfile(fileext = ".csv")
write.csv(metadata$notes, file = paste0(tempdir(), "/metadata", ".csv"))

### authorize gmailr - need to click through set up on first run, automatic afterwards
#config path pointing to gmailr json credentials
gm_auth_configure(path = "")
#set gmail account to use
gm_auth(email = "")

### creat emails on update result for Daily COVID
notification_email <-
  gm_mime() %>%
  gm_to("") %>% # email address you want notifications sent to
  gm_from("") %>% # gmail address set above in authorisation step to send email from
  gm_subject(glue("Changes to ", {dataset}, " open data")) %>%
  gm_text_body(glue("Changes have been made to the ", {dataset}, " open dataset metadata description. Please check the updated description on the open data site."))

#condition for detecting changes to metadata description
#commonly notes will begin with `Please note` for notes added with updates
if(str_detect(metadata$notes, "Please note")) {gm_send_message(notification_email)}

