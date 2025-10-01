library(bslib)
library(dplyr)
library(DT)
library(rsconnect)
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(thembisaR)


#Fixed file
FILENAME <- "./Data/Age-specificOutputs4.8_final2.xlsx"


#Dataset function
get_data <- function(filename){
  
  indicator_whole <- c("Population", "On art", "Diagnosed with hiv",
                       "Aids deaths (by age last birthday at start of year)",
                       "Births to hiv-positive mothers, by maternal age at start of year"
  )
  
  thembisaR::read_sex_age_specific_file(filename) |> 
    rename(Age = age,
           Indicator = indicator,
           Sex = sex,
           Year = year,
           Location_id = country_province,
           Location = country_province_name, 
           Value = value) |> 
    select(Indicator, Year, Age, Sex, Location, Value) |> 
    mutate(
      Value = case_when(
        Indicator %in% indicator_whole ~ format(round(Value, 0), scientific = FALSE, trim = TRUE),
        TRUE ~ format(round(Value, 10), scientific = FALSE, trim = TRUE)
      )
    )
  
}


# Define UI for application
ui <- page_fillable(
  theme = bs_theme(bootswatch = "yeti"),
  
  # Top "header" row
  fluidRow(
    column(
      width = 12,
      style = "text-align: right; padding: 10px;",
      tags$a(
        href = "https://www.mltwelve.com",
        icon("globe"),  # pick any Font Awesome icon
        " About me",
        target = "_blank",
        style = "font-size: 16px; text-decoration: none; margin-right: 15px;"
      )
    )
  ),
  
  # Full-page flex column
  div(
    style = "display: flex; flex-direction: column; height: 100vh;",
    
    # Header (fixed height)
    div(
      style = "background-color: #2C5364; color: white; text-align: center; padding: 20px;",
      h1("Thembisa Data (Version 4.8)")
    ),
    
    # Intro text + indicators in a row separated by dots
    div(
      style = "padding: 10px; color: #1B3A4B; font-size: 14px; line-height: 2;",
      HTML(
        paste0(
          "<strong>The following indicators are available:</strong><br> ",
          paste(
            c(
              "Population",
              "HIV Prevalence",
              "HIV Incidence",
              "Mortality Probability",
              "Diagnosed with HIV",
              "On ART",
              "AIDS deaths (by age last birthday at start of year)",
              "Births to HIV positive mothers (by maternal age at start of year)"
            ),
            collapse = " &bull; "
          )
        )
      )
    ),
    
    div(
      style = "padding: 10px; color: #1B3A4B; font-size: 14px; line-height: 2;",


      HTML(
        "The default download buttons export <strong>the visible data</strong>. To download everything, please use the
    <strong> Download All as CSV </strong> button. <br>"
      )
    ),
    # Button aligned to the top-right
    div(
      style = "display: flex; justify-content: flex-end; margin-bottom: 10px;",
      downloadButton(
        outputId = "download_all",
        label = "Download All as CSV",
        class = "btn btn-warning"  # Yeti primary, small button
      )
    ),

    


    # Table (fills remaining space)
    div(
      style = "flex: 1; display: flex; flex-direction: column; overflow: hidden;",
      DTOutput("indicator_metadata_table", width = "100%", height = "100%")
    ),
    
    helpText(
      HTML(
        paste0(
          "Data source: <strong>Thembisa Project</strong> - ",
          "Age-specificOutputs4.8_final2. ",
          "For more information, visit ",
          "<a href='https://thembisa.org/' target='_blank'>thembisa.org</a>."
        )
      )
    )
    

))


# Define server logic
server <- function(input, output, session) {
  
  output$download_all <- downloadHandler(
    filename = function() {
      paste0("thembisa_all_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      readr::write_csv(get_data(FILENAME), file)  # writes CSV without row names
    }
  )
  
  
  output$indicator_metadata_table <- DT::renderDT({
    get_data(FILENAME) %>%
      DT::datatable(
        extensions = "Buttons",
        fillContainer = TRUE,  # makes table fill its container
        filter = "top",
        options = list(
          pageLength = 10,
          lengthMenu = list(
            c(5, 10, 25, 50, 100, 500, 1000, 2500, 5000),
            c("5", "10", "25", "50", "100", "500", "1000", "2500", "5000")
          ),
          scrollX = TRUE,
          dom = "lBfrtip",
          buttons = list(
            list(
              extend = "csv",
              filename = paste0("thembisa_data_", Sys.Date())#,
              # Include today's date
        #           exportOptions = list(modifier = list(page = "all"))
            ),
            list(
              extend = "excel",
              filename = paste0("thembisa_data_", Sys.Date())#,
              # Include today's date
         #         exportOptions = list(modifier = list(page = "all"))
            )#,

          ),
          class = "stripe hover" ,
          columnDefs = list(list(
            className = "dt-left top-align", targets = "_all"
          ))  # Center-align all columns
        ),
        callback = JS("
      $('td, th').css('vertical-align', 'top'); 
      $('th').css({'background-color': '#2C5364', 'color': 'white'});
    ")
      )
  }, server = TRUE)
  
  
  
}

# this is how you run your app
shinyApp(ui, server)
