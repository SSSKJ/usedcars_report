# **Rshiny App for Used Car**

## **Description**

[Rshiny App for Used Car](https://skjguan.shinyapps.io/project/) aims to build a R shinyApp for users to get information about used cars. The mainly objectives are to show the used car sale condition of different brands, to show the used car sale condition in different price range and to predict the price of a used car.The data is based on the dataset from kaggle called ["Used cars database"](https://www.kaggle.com/orgesleka/used-cars-database/kernels). The dataset contains over 370,000 used cars scraped from Ebay Kleinanzeigen in 2016. 

## **File Structure**

```{}
project
|   server.R
|   ui.R
|   global.R
|   car_info.R
|   company_info.R
|   prediction.R
|   function.R
|   processing.R
|   generate model.R
|
|-- www
|   |   rfModel.RData
|   |   simplerModel.RData
|   |   user-car.csv

```

## **File Introduction**

### server.R, ui.R, global.R

Basis Rshiny structure

### car_info.R, company.R, prediction.R

Generate 3 tabs of the App dynamically

### function.R

Include all functions used by the App

### processing.R

Process the raw data. If you don't have the file user-car.csv, please download the raw data from kaggle first and then run this script to generate the data for the App.

### generate model.R

Train random forest model with user-car.csv. If you don't have the file simplerModel.RData, please run this script first to generate a model for the App.

## Environmental Requirement



## How to Run

Run ./server.R with R studio




## **Functions Introduction**

### **rship_graph**

#### Description

This function generates the scatter plot with the car registration year as x and price as y. It can show the details of each point when hover on the point

#### Usage

```{}
rship_graph(data)
```

#### Argument

```{}
data   a data frame containing the variables as user-car.csv
```

#### Code Chunk

```{}
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
  
  company_data %>% 
    plot_ly(x = ~yearOfRegistration, y = ~price, color = ~model, size = ~powerPS, 
            text = ~paste("Price:", price, "<br>Year Of Registration:", 
            yearOfRegistration, "<br>Power(PS):", powerPS, "<br>GearBox:", 
            gearbox, "<br>Model:", model, "<br>Fuel Type:", fuelType)) %>% 
    layout(xaxis = list(title = "Year Of Registration"), yaxis = list(title = "Price"))
  
}
```



### **price_dist**

#### Description

This function generates the box plot with the vehicle type as x and price as y and zoom in to show the graph clearly

#### Usage

```{}
price_dist(data)
```

#### Argument

```{}
data   a data frame containing the variables as user-car.csv
```

#### Code Chunk

```{}
price_dist <- function(company_data) {
  
  Q3 <- quantile(company_data$price, probs = 0.75)
  Q1 <- quantile(company_data$price, probs = 0.25)
  IQR <- Q3 - Q1
  outliers <- 1.5 * Q3 + 2.5 * IQR
  
  company_data %>% plot_ly(x = ~vehicleType, y = ~price, type = "box") %>% 
    layout(yaxis = list(range = c(0, outliers[[1]]))) %>% 
    layout(xaxis = list(title = "Car Type"), yaxis = list(title = "Price"))
  
}
```



### **car_age_dist**

#### Description

This function generates the line plot with the car registration year as x and number of car which were registered at that year as y

#### Usage

```{}
car_age_dist(data)
```

#### Argument

```{}
data   a data frame containing the variables as user-car.csv
```

#### Code Chunk

```{}
car_age_dist <- function(data) {
  
  year_list <- data %>% count(yearOfRegistration)
  year_list %>% 
    plot_ly(x = ~yearOfRegistration, y = ~n, type = 'scatter', mode = 'lines') %>% 
    layout(xaxis = list(title = "Year Of Registration"), yaxis = list(title = "Sells"))
  
}
```



### **pie**

#### Description

This function generates the pie plot

#### Usage

```{}
pie(data, var)
```

#### Argument

```{}
data   a data frame containing the variables as user-car.csv

var    a string specifying what kind of label should be used to generate the pie chart. 
       "gearbox", "cartype" or "fueltype"
```

#### Code Chunk

```{}
pie <- function(data, var) {
  
  switch(var,
         "gearbox" = data %>% 
            count(gearbox) %>% complete(gearbox, fill = list(n = 0)) %>% 
            plot_ly(labels = ~gearbox, values = ~n, source = "gearbox") %>% 
            add_pie(hole = 0.6) %>% layout(title = "Gear Box Dist"),
         "cartype" = data %>% 
            count(vehicleType) %>% complete(vehicleType, fill = list(n = 0)) %>% 
            plot_ly(labels = ~vehicleType, values = ~n, source = "car") %>% 
            add_pie(hole = 0.6) %>% layout(title = "Car Type Dist"),
         "fueltype" = data %>% 
            count(fuelType) %>% complete(fuelType, fill = list(n = 0)) %>% 
            plot_ly(labels = ~fuelType, values = ~n, source = "fuel") %>% 
            add_pie(hole = 0.6) %>% layout(title = "Fuel Type Dist")
  )
  
}
```



### **sell_each_company**

#### Description

This function generates the stack bar plot with brand as x and the number of car of each brand as y and automatik and manuel as stack

#### Usage

```{}
sell_each_company(data, input)
```

#### Argument

```{}
data   a data frame containing the variables as user-car.csv

input  the input object from server
```

#### Code Chunk

```{}
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
  
  d %>% 
    plot_ly(x = ~factor(brand), y = ~automatik, type = "bar", name = "Automatik") %>% 
    add_trace(y = ~manuell, name = "Manuell") %>% layout(barmode = "stack") %>% 
    layout(xaxis = list(title = "Brand"), yaxis = list(title = "Sells"))
  
}
```



### **power_dist**

#### Description

This function generates the box plot with power of the cars as y and zoom in to show the graph clearly

#### Usage

```{}
power_dist(data)
```

#### Argument

```{}
data   a data frame containing the variables as user-car.csv
```

#### Code Chunk

```{}
power_dist <- function(car_data) {
  
  Q3 <- quantile(car_data$powerPS, probs = 0.75)
  Q1 <- quantile(car_data$powerPS, probs = 0.25)
  IQR <- Q3 - Q1
  outliers <- Q3 + 2.5 * IQR
  
  car_data %>% plot_ly(y = ~powerPS, type = "box") %>% 
    layout(yaxis = list(range = c(0, outliers[[1]]))) %>% 
    layout(yaxis = list(title = "Power/S"))
  
}
```



### **predict_price**

#### Description

This function predict the price of a used car based on the input information in the Prediction tab

#### Usage

```{}
predict_price(rfmodel, input, model_labels, car_labels, brand_labels)
```

#### Argument

```{}
rfmodel           a trained random forest model

input             the input object from server

model_labels      labels of models of cars in the original dataset.
                  Generated by LabelEncoder.fit
                  
car_labels        labels of vehicle types of car in the original dataset.
                  Generated by LabelEncoder.fit
                  
brand_labels      labels of brands of car in the original dataset.
                  Generated by LabelEncoder.fit
```

#### Code Chunk

```{}
predict_price <- function(rfmodel, input, model_labels, car_labels, brand_labels) {
  
  d <- data.frame(vehicleType = input$car_type3, powerPS = input$power, 
            model = input$model, kilometer = input$km, brand = input$brand3, year = input$year)
  
  d$model <- transform(model_labels, d$model)
  d$vehicleType <- transform(car_labels, d$vehicleType)
  d$brand <- transform(brand_labels, d$brand)
  
  predict(rf, d)
  
}
```



### **initCompanyInfo**

#### Description

This function initializes the Company tab

#### Usage

```{}
initCompanyInfo(session, data)
```

#### Argument

```{}
session   the session object from server

data      a data frame containing the variables as user-car.csv
```

#### Code Chunk

```{}
initCompanyInfo <- function(session, dataset) {
  
  updatePickerInput(session = session, 
                    inputId = "brand", choices = levels(dataset$brand))
  updatePickerInput(session = session, 
                    inputId = "car_type", choices = c("All", levels(dataset$vehicleType)))
  updatePickerInput(session = session, 
                    inputId = "gearbox_type", choices = c("All", levels(dataset$gearbox)))
  updatePickerInput(session = session, 
                    inputId = "fuel_type", choices = c("All", levels(dataset$fuelType)))
  
}
```



### **initCarInfo**

#### Description

This function initializes the Car tab

#### Usage

```{}
initCarInfo(session, data)
```

#### Argument

```{}
session   the session object from server

data      a data frame containing the variables as user-car.csv
```

#### Code Chunk

```{}
initCarInfo <- function(session, dataset) {
  
  sary <- summary(dataset$price)
  
  updateNumericRangeInput(session = session, 
                          inputId = "price_input", "Input Price", value = c(1600, 8750))
  updateSliderInput(session = session, 
                    inputId = "price", min = sary[[1]], max = sary[[6]], value = c(1600, 8750))
  updatePickerInput(session = session, 
                    inputId = "car_type2", choices = c("All", levels(dataset$vehicleType)))
  updatePickerInput(session = session, 
                    inputId = "gearbox_type2", choices = c("All", levels(dataset$gearbox)))
  updatePickerInput(session = session, 
                    inputId = "fuel_type2", choices = c("All", levels(dataset$fuelType)))
  
}
```



### **initPrediction**

#### Description

This function initializes the Prediction tab

#### Usage

```{}
initPrediction(session, data)
```

#### Argument

```{}
session   the session object from server

data      a data frame containing the variables as user-car.csv
```

#### Code Chunk

```{}
initPrediction <- function(session, dataset) {
  
  updatePickerInput(session = session, 
                    inputId = "brand3", choices = levels(dataset$brand))
  updatePickerInput(session = session, 
                    inputId = "car_type3", choices = levels(dataset$vehicleType))
  updatePickerInput(session = session, 
                    inputId = "gearbox_type3", choices = levels(dataset$gearbox))
  updatePickerInput(session = session, 
                    inputId = "fuel_type3", choices = levels(dataset$fuelType))
  updatePickerInput(session = session, 
                    inputId = "abtest", choices = levels(dataset$abtest))
  updatePickerInput(session = session, 
                    inputId = "damage", choices = c("Yes" = "ja", "No" = "nein"))
  
  output$predict_price <- renderText({
    paste(0 , " $")
  })
  
}
```