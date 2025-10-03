library(thembisaR)
library(dplyr) #only for the 1 sheet cleaned example
library(readxl) #only for the 1 sheet cleaned example



# point to where your file is stored
my_file <- "Data/Age-specificOutputs4.8_final2.xlsx"


# Read and clean all sheets EXCEPT notes
my_data <- thembisaR::read_sex_age_specific_file(my_file)


# Read one sheet

my_data_original <-readxl::read_xlsx(my_file, sheet = "SA")

my_data_clean <- my_data_original |> 
    thembisaR::clean_sex_age_specific()
