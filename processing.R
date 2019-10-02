library(dplyr)

data <- read.csv("autos.csv", na.strings = "", quote = "")

dataset <- data[data$price >0, ]
dataset <- dataset[dataset$yearOfRegistration < 2017, ]
dataset$year <- 2016 - dataset$yearOfRegistration
dataset <- select(dataset, -c(dateCrawled, name, seller, offerType, postalCode, nrOfPictures, dateCreated, lastSeen, monthOfRegistration))
dataset <- na.omit(dataset)

write.csv(dataset, "used-car.csv", row.names = FALSE)
