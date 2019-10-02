library(dplyr)
library(nnet)
library(CatEncoders)
setwd("D:/Matertials/data visualization/final project/project")

data <- read.csv("../project/www/used-car.csv")

d <- select(data, -c(yearOfRegistration, gearbox, fuelType, abtest, notRepairedDamage))

model_labelsencoding <- LabelEncoder.fit(d$model)
car_labelsencoding <- LabelEncoder.fit(d$vehicleType)
brand_labelsencoding <- LabelEncoder.fit(d$brand)

d$model <- transform(model_labelsencoding, d$model)
d$vehicleType <- transform(car_labelsencoding, d$vehicleType)
d$brand <- transform(brand_labelsencoding, d$brand)

set.seed(1)
train.index <- sample(c(1:dim(d)[1]), 0.6*dim(d)[1])
valid.index <- setdiff(c(1:dim(d)[1]), train.index)

train.df <- d[train.index, ]
valid.df <- d[valid.index, ]

library(randomForest)
rf <- randomForest(price ~., data = train.df, ntree = 50, importance = TRUE, do.trace = T, nodesize = 35)
plot(rf)

varImpPlot(rf)

rf <- rf1

save(rf, file = "simplerModel.RData")
model <- load("simplerModel.RData")

