# TITLE: Clean Thembisa Data
# DESCRIPTION:  Reads a single Thembisa file (from the Thembisa Project) and outputs a cleaned version of the data
# AUTHOR:  Kirstin Lyon
# LICENSE:  MIT
# DATE: 2025-09-30


library(janitor)
library(readxl)
library(tidyr)
library(dplyr)
library(purrr)
library(stringr)
library(readr)


#options(scipen = 999)  # remove scientific notation
source("Scripts/utils.R") # all functions stored here

FILENAME <- "./Data/Age-specificOutputs4.8_final2.xlsx"

all_data <- read_all_data(FILENAME)
write_csv(all_data, "./Dataout/all_data.csv")


unique(all_data$indicator)
