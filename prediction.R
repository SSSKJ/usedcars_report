output$price_prediction <- renderUI(fluidPage(
  fluidRow(
    br(),
    br(),
    br(),
    h1(textOutput("predict_price"), align = "center"),
    br(),
    br(),
    br()),
  fluidRow(column(3, pickerInput("brand3", "Brand", choices = "")),
           column(3, pickerInput("model", "Model", choices = "")),
           column(3, pickerInput("car_type3", "Car Type", choices = "")),
           column(3, numericInput("year", "Years since bought", value = 0))), 
  fluidRow(column(3, numericInput("power", "Power/S", value = 1)),
           column(3, numericInput("km", "Kilometer", value = 0))),
  h1(actionBttn("submit", "Predict"), align = "center")
))