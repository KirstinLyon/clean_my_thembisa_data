#' Read in all data from Thembisa excel file
#'
#' @param filename path to the Thembisa excel file
#'
#' @returns cleaned dataset
#' @export
#'
#' @examples
read_all_data <- function(filename){
    
    sheet_names <- readxl::excel_sheets(filename)
    sheet_names <- setdiff(excel_sheets(filename), "Notes")
    
    all_data <- sheet_names %>%
        set_names() %>%  # keep sheet names as list names
        map(~ {
            df <- read_xlsx(filename, sheet = .x)      # step 1: read sheet
            df <- clean_sex_age_specific(df)                    # step 2: clean the data
            df <- df %>% mutate(sheet_name = .x)       # step 3: store sheet name
            df                                          
        }) %>%
        bind_rows()  |> 
        rename(country_province = sheet_name) |> 
        mutate(country_province_name = case_when(
            country_province == "SA" ~ "South Africa",
            country_province == "EC" ~ "Eastern Cape",
            country_province == "FS" ~ "Free State",
            country_province == "GT" ~ "Gauteng",
            country_province == "KZ" ~ "KwaZulu-Natal",
            country_province == "LM" ~ "Limpopo",
            country_province == "MP" ~ "Mpumalanga",
            country_province == "NC" ~ "Northern Cape",
            country_province == "NW" ~ "North West",
            country_province == "WC" ~ "Western Cape",
            TRUE ~ country_province
        ))
    
}


#' clean data from the sex_age specific file
#'
#' @param excel_tab a tab in excel
#'
#' @returns cleaned dataset
#' @export
#'
#' @examples
clean_sex_age_specific <- function(excel_tab) {
    temp <- excel_tab |>
        janitor::clean_names() |>
        
        #if it's an age it will be less than 4 chars
        dplyr::mutate(type = case_when(str_length(x1) < 4 ~ "age", TRUE ~ "indicator")) |>
        
        # separate age from the generic column
        dplyr::mutate(age = case_when(type == "age" ~ x1, TRUE ~ NA)) |>
        
        #create a separate indicator column
        dplyr::mutate(indicator = case_when(type == "indicator" ~ x1, TRUE ~ NA),
                      indicator = na_if(indicator, "")
        ) |>
        fill(indicator, .direction = "down") |>
        drop_na(age) |>
        
        #Create a separate sex column
        dplyr::mutate(sex = case_when(str_detect(indicator, "\\bMale") ~ "Male", TRUE ~ "Female")) |>
        select(-c(x1, type)) |>
        pivot_longer(cols = starts_with("x"),
                     names_to = "year",
                     values_to = "value") |>
        mutate(year = str_remove(year, "x"), 
               indicator = if_else(
                   str_detect(str_to_lower(indicator), "^(male|female)"),
                   str_remove(indicator, "^\\S+\\s+"),  # drop first word + spaces
                   indicator                            # leave unchanged
               ),
               indicator = str_to_sentence(indicator)
        )
    
    return(temp)
    
}