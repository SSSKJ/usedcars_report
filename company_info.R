output$company_info <- renderUI(fluidPage(
  column(2, 
         fluidRow(pickerInput("brand", label = "Brand", choices = "")), 
         fluidRow(pickerInput("pie", label = "Show in Pie Chart", choices = c("Gear Box", "Car Type", "Fuel Type"))), 
         fluidRow(pickerInput("car_type", label = "Car Type", choices = "")),
         fluidRow(pickerInput("gearbox_type", label = "Gear Box Type", choices = "")),
         fluidRow(pickerInput("fuel_type", label = "Fuel Type", choices = "")),
         fluidRow(p("Total Sells: ", textOutput("sell_number", inline = T)))),
  column(8, 
         fluidRow(plotlyOutput("company_all")), 
         fluidRow(
           column(4, plotlyOutput("price_dist")),
           column(4, plotlyOutput("car_age_dist")),
           column(4, plotlyOutput("change_pie"))
         )
    )
))
