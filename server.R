server <- function(input, output, session) {
  
  dataset <- read.csv("./www/used-car.csv")
  
  source("company_info.R", local = TRUE)
  source("function.R", local =TRUE)
  source("car_info.R", local = TRUE)
  source("prediction.R", local = TRUE)
  load("www/simplerModel.RData")
  
  model_labels <- LabelEncoder.fit(dataset$model)
  car_labels <- LabelEncoder.fit(dataset$vehicleType)
  brand_labels <- LabelEncoder.fit(dataset$brand)
  
  # abtest_levels <- levels(dataset$abtest)
  # gearbox_levels <- levels(dataset$gearbox)
  # fuel_levels <- levels(dataset$fuelType)
  # damage_levels <- levels(dataset$notRepairedDamage)

  initCompanyInfo(session, dataset)
  
  observeEvent(input$selected_tab, {
    if (input$selected_tab == "Car" && is.null(input$car_type2))
      initCarInfo(session, dataset)
    if (input$selected_tab == "Prediction" && is.null(input$car_type3))
      initPrediction(session, dataset)
  })
  
  observeEvent(input$price_input, {
    if (input$price_input[1] < input$price_input[2]) {
      updateSliderInput(session = session, inputId = "price", value = c(input$price_input[1], input$price_input[2]))
    }
  })
  
  observeEvent(input$price, {
    if (input$price_input[1] != input$price[1] | input$price_input[2] != input$price[2])
      updateNumericRangeInput(session = session, inputId = "price_input", "Input Price", value = c(input$price[1], input$price[2]))
  })
  
  observeEvent(input$brand3, {
    d <- dataset[dataset$brand == input$brand3, ]
    updatePickerInput(session = session, inputId = "model", choices = levels(factor(d$model)))
  })
  
  observeEvent(input$submit, {
    p <- predict_price(rf, input, model_labels, car_labels, brand_labels)
    output$predict_price <- renderText({
      paste(as.integer(p), " $")
    })
  })
  
  company_data <- reactive({
    d <- dataset[dataset$brand == input$brand, ]
    if (input$car_type != "All")
      d <- d %>% filter(vehicleType == input$car_type)
    if (input$gearbox_type != "All")
      d <- d %>% filter(gearbox == input$gearbox_type)
    if (input$fuel_type != "All")
      d <- d %>% filter(fuelType == input$fuel_type)
    d
    })
  car_data <- reactive({
    d <- dataset %>% filter(price >= input$price[1] & price <= input$price[2])
    if (input$car_type2 != "All")
      d <- d %>% filter(vehicleType == input$car_type2)
    if (input$gearbox_type2 != "All")
      d <- d %>% filter(gearbox == input$gearbox_type2)
    if (input$fuel_type2 != "All")
      d <- d %>% filter(fuelType == input$fuel_type2)
    
    # car <- event_data("plotly_relayout", source = "car")
    # fuel <- event_data("plotly_relayout", source = "fuel")
    # car_hidden_labels <- car$hiddenlabels
    # fuel_hidden_labels <- fuel$hiddenlables
    # 
    # if (!is_empty(car_hidden_labels))
    #   d <- d[!(d$vehicleType %in% car_hidden_labels), ]
    # if (!is_empty(fuel_hidden_labels))
    #   d <- d[!(d$fuelType %in% car_hidden_labels), ]
    
    d
    })
  pie_show <- reactive({
    switch (input$pie,
            "Gear Box" = "gearbox", 
            "Car Type" = "cartype", 
            "Fuel Type" = "fueltype"
  )})
  
  output$sell_number <- renderText({
    sell_number(company_data())
  })
  
  output$company_all <- renderPlotly({
    rship_graph(company_data())
  })
  
  output$price_dist <- renderPlotly({
    price_dist(company_data())
  })
  
  output$car_age_dist <- renderPlotly({
    car_age_dist(company_data())
  })
  
  output$change_pie <- renderPlotly({
    pie(company_data(), pie_show())
  })
  
  # output$text <- renderText({
  #   event_data("plotly_click", source = "car")
  # })
  # 
  output$sell_each_company <- renderPlotly({
    sell_each_company(car_data(), input)
  })
  
  output$power_dist <- renderPlotly({
    power_dist(car_data())
  })
  
  output$car_age_dist2 <- renderPlotly({
    car_age_dist(car_data())
  })
  
  output$car_type_dist <- renderPlotly({
    pie(car_data(), "cartype")
  })
  
  output$fuel_type_dist <- renderPlotly({
    pie(car_data(), "fueltype")
  })

}