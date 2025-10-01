# TITLE: Clean Thembisa Data
# DESCRIPTION:  Reads a single Thembisa file (from the Thembisa Project) and outputs a cleaned version of the data
# AUTHOR:  Kirstin Lyon
# LICENSE:  MIT
# DATE: 2025-09-30

library(thembisaR)

FILENAME <- "./Data/Age-specificOutputs4.8_final2.xlsx"
sheets_to_exclude <- c("Notes")

all_data <- thembisaR::read_sex_age_specific_file(FILENAME, sheets_to_exclude)





