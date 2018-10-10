mydata<- read.csv("FinalWorkingData17.csv", header = TRUE)
#Outlier Removal
std <- sd(mydata$WTTRDFIN)
meanvalue <- mean(mydata$WTTRDFIN)
difference <- abs(mydata$WTTRDFIN - meanvalue)

mydata <- subset(mydata, mydata$WTTRDFIN <= 3*std)
#States Selection
mydata<- subset(mydata, mydata$HHSTATE =="TX" | mydata$HHSTATE =="CA" | mydata$HHSTATE =="NY" | mydata$HHSTATE =="WI" | mydata$HHSTATE =="GA" | mydata$HHSTATE == "NC" | mydata$HHSTATE =="SC" | mydata$HHSTATE == "IA" | mydata$HHSTATE =="AZ" | mydata$HHSTATE =="MD")
#CSV File for statistical
write.csv(mydata, "data17.csv", row.names = FALSE)

rm(std)
rm(difference)
rm(meanvalue)
rm(del.row)
mydata<- mydata[,-c(1:9,12:16,18,26:32)]
str(mydata)
#Data factorization
i <- c(1:2, 5:10)
for (i in i){
  mydata[,i]<- as.factor(mydata[,i])
}
str(mydata)
#Multinomial Logistic regression
library(nnet)

#Setting the base
mydata$out<-relevel(mydata$TRPTRANS, ref="Car")

mydata <- mydata[,-1]
str(mydata)
#Model training
mymodel<-multinom(out~., data=mydata, MaxNWts = 10000,maxit = 500, model = TRUE )
summary(mymodel)
#Data Prediction
predict<- predict(mymodel,mydata,type="prob")
#confusion Matrix
cm <- table(predict(mymodel),mydata$out)
print(cm)
error<- 1-sum(diag(cm))/sum(cm)
# Evaluation of significant variables
library(stargazer)
stargazer(mymodel, type="text", out="NHTSData17.htm")
mymodel.exp = exp(coef(mymodel))
stargazer(mymodel, type="text", coef=list(mymodel.exp), p.auto=FALSE, out="NHTSData17exp.htm")

