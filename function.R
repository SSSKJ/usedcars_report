sell_number <- function(company_data) {

  count(company_data)[[1]]
  
}

rship_graph <- function(company_data) {
  
  if (nrow(company_data) == 0) {
    showModal(modalDialog(
      title = "Data Not Found",
      paste0("No such data"),
      easyClose = TRUE,
      footer = NULL
    ))
    return()
  }
  
  # year_list <- as.data.frame(table(dataset$yearOfRegistration))
  company_data %>% 
    plot_ly(x = ~yearOfRegistration, y = ~price, color = ~model, size = ~powerPS, text = ~paste("Price:", price, "<br>Year Of Registration:", yearOfRegistration, "<br>Power(PS):", powerPS, "<br>GearBox:", gearbox, "<br>Model:", model, "<br>Fuel Type:", fuelType)) %>% 
    layout(xaxis = list(title = "Year Of Registration"), yaxis = list(title = "Price"))
    # add_lines(x = ~year_list$Var1, y = ~year_list$Freq)
  
}

price_dist <- function(company_data) {
  
  Q3 <- quantile(company_data$price, probs = 0.75)
  Q1 <- quantile(company_data$price, probs = 0.25)
  IQR <- Q3 - Q1
  outliers <- 1.5 * Q3 + 2.5 * IQR
  
  company_data %>% plot_ly(x = ~vehicleType, y = ~price, type = "box") %>% layout(yaxis = list(range = c(0, outliers[[1]]))) %>% 
    layout(xaxis = list(title = "Car Type"), yaxis = list(title = "Price"))
  
}

car_age_dist <- function(data) {
  
  year_list <- data %>% count(yearOfRegistration)
  year_list %>% plot_ly(x = ~yearOfRegistration, y = ~n, type = 'scatter', mode = 'lines') %>% 
    layout(xaxis = list(title = "Year Of Registration"), yaxis = list(title = "Sells"))
  
}

pie <- function(data, var) {
  
  switch(var,
         "gearbox" = data %>% count(gearbox) %>% complete(gearbox, fill = list(n = 0)) %>% plot_ly(labels = ~gearbox, values = ~n, source = "gearbox") %>% add_pie(hole = 0.6) %>% layout(title = "Gear Box Dist"),
         "cartype" = data %>% count(vehicleType) %>% complete(vehicleType, fill = list(n = 0)) %>% plot_ly(labels = ~vehicleType, values = ~n, source = "car") %>% add_pie(hole = 0.6) %>% layout(title = "Car Type Dist"),
         "fueltype" = data %>% count(fuelType) %>% complete(fuelType, fill = list(n = 0)) %>% plot_ly(labels = ~fuelType, values = ~n, source = "fuel") %>% add_pie(hole = 0.6) %>% layout(title = "Fuel Type Dist")
  )
  
}

sell_each_company <- function(car_data, input) {
  
  if (nrow(car_data) == 0) {
    showModal(modalDialog(
      title = "Data Not Found",
      paste0("No such data between ", input$price[1], "$ and ", input$price[2], "$"),
      easyClose = TRUE,
      footer = NULL
    ))
    return()
  }
  
  d <- car_data %>% count(brand, gearbox) %>% spread(key = gearbox, value = n)
  
  if (!("manuell" %in% colnames(d)))
    d$manuell <- 0
  if (!("automatik" %in% colnames(d)))
    d$automatik <- 0
  
  d$automatik[is.na(d$automatik)] <- 0
  d$manuell[is.na(d$manuell)] <- 0
  
  d %>% plot_ly(x = ~factor(brand), y = ~automatik, type = "bar", name = "Automatik") %>% 
    add_trace(y = ~manuell, name = "Manuell") %>% layout(barmode = "stack") %>% 
    layout(xaxis = list(title = "Brand"), yaxis = list(title = "Sells"))
  
}

power_dist <- function(car_data) {
  
  Q3 <- quantile(car_data$powerPS, probs = 0.75)
  Q1 <- quantile(car_data$powerPS, probs = 0.25)
  IQR <- Q3 - Q1
  outliers <- Q3 + 2.5 * IQR
  
  car_data %>% plot_ly(y = ~powerPS, type = "box") %>% layout(yaxis = list(range = c(0, outliers[[1]]))) %>% 
    layout(yaxis = list(title = "Power/S"))
  
}

predict_price <- function(rfmodel, input, model_labels, car_labels, brand_labels) {
  
  d <- data.frame(vehicleType = input$car_type3, powerPS = input$power, model = input$model, kilometer = input$km, brand = input$brand3, year = input$year)
  
  d$model <- transform(model_labels, d$model)
  d$vehicleType <- transform(car_labels, d$vehicleType)
  d$brand <- transform(brand_labels, d$brand)
  
  # levels(d$abtest) <- abtest_levels
  # levels(d$gearbox) <- gearbox_levels
  # levels(d$fuelType) <- fuel_levels
  # levels(d$notRepairedDamage) <- damage_levels
  
  predict(rf, d)
}

initCompanyInfo <- function(session, dataset) {
  
  updatePickerInput(session = session, inputId = "brand", choices = levels(dataset$brand))
  updatePickerInput(session = session, inputId = "car_type", choices = c("All", levels(dataset$vehicleType)))
  updatePickerInput(session = session, inputId = "gearbox_type", choices = c("All", levels(dataset$gearbox)))
  updatePickerInput(session = session, inputId = "fuel_type", choices = c("All", levels(dataset$fuelType)))
  
}

initCarInfo <- function(session, dataset) {
  
  sary <- summary(dataset$price)
  
  updateNumericRangeInput(session = session, inputId = "price_input", "Input Price", value = c(1600, 8750))
  updateSliderInput(session = session, inputId = "price", min = sary[[1]], max = sary[[6]], value = c(1600, 8750))
  updatePickerInput(session = session, inputId = "car_type2", choices = c("All", levels(dataset$vehicleType)))
  updatePickerInput(session = session, inputId = "gearbox_type2", choices = c("All", levels(dataset$gearbox)))
  updatePickerInput(session = session, inputId = "fuel_type2", choices = c("All", levels(dataset$fuelType)))
  
}

initPrediction <- function(session, dataset) {
  
  updatePickerInput(session = session, inputId = "brand3", choices = levels(dataset$brand))
  updatePickerInput(session = session, inputId = "car_type3", choices = levels(dataset$vehicleType))
  updatePickerInput(session = session, inputId = "gearbox_type3", choices = levels(dataset$gearbox))
  updatePickerInput(session = session, inputId = "fuel_type3", choices = levels(dataset$fuelType))
  updatePickerInput(session = session, inputId = "abtest", choices = levels(dataset$abtest))
  updatePickerInput(session = session, inputId = "damage", choices = c("Yes" = "ja", "No" = "nein"))
  
  output$predict_price <- renderText({
    paste(0 , " $")
  })
  
}