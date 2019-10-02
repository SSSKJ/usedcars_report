output$car_info <- renderUI(fluidPage(
  column(2, 
         fluidRow(numericRangeInput("price_input", "Input Price", value = c(0, 1))),
         fluidRow(sliderInput("price", "Price:", min = 0, max = 1, value = c(0, 1))), 
         fluidRow(pickerInput("car_type2", label = "Car Type", choices = "")),
         fluidRow(pickerInput("gearbox_type2", label = "Gear Box Type", choices = "")),
         fluidRow(pickerInput("fuel_type2", label = "Fuel Type", choices = "")),
         fluidRow(textOutput("text"))
         ),
  column(8, 
         fluidRow(
           column(10, plotlyOutput("sell_each_company")), 
           column(2, plotlyOutput("power_dist"))
         ),
         fluidRow(
           column(4, plotlyOutput("car_age_dist2")),
           column(4, plotlyOutput("car_type_dist")),
           column(4, plotlyOutput("fuel_type_dist"))
         ))
))
