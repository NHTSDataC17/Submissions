mydata<- read.csv("FinalWorkingData9.csv", header = TRUE)

std <- sd(mydata$WTTRDFIN)
meanvalue <- mean(mydata$WTTRDFIN)
difference <- abs(mydata$WTTRDFIN - meanvalue)

mydata <- subset(mydata,  mydata$WTTRDFIN <= 3*std)
mydata<- subset(mydata, mydata$HHSTATE =="AZ" | mydata$HHSTATE =="CA" | mydata$HHSTATE =="GA" | mydata$HHSTATE =="IA" | mydata$HHSTATE =="MD" | mydata$HHSTATE == "NC" | mydata$HHSTATE =="NY" | mydata$HHSTATE == "SC" | mydata$HHSTATE =="TX" | mydata$HHSTATE =="WI")

mydata = na.omit(mydata)
del.row= na.action(mydata)
write.csv(mydata, "data9.csv", row.names = FALSE)
rm(std)
rm(difference)
rm(meanvalue)
mydata<- mydata[,-c(1:10,13:17,19,27:32)]
str(mydata)
#Data factorization
i <- c(1:2,5:10)
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
mymodel<-multinom(out~., data=mydata, MaxNWts = 10000,maxit = 500,model = TRUE )

summary(mymodel)
#2-tailed z test
z <- summary(mymodel)$coefficients/summary(mymodel)$standard.errors
p <- (1 - pnorm(abs(z), 0, 1)) * 2
p=(round(p,4))
print(summary(mymodel))
#Data Prediction
predict<- predict(mymodel,mydata,type="prob")
print(predict(mymodel,mydata,type="prob"))
#confusion Matrix
cm <- table(predict(mymodel),mydata$out)
mean(as.character(predict)!= as.character(mydata$out))
print(cm)
error<- 1-sum(diag(cm))/sum(cm)
# Evaluation of significant variables
library(stargazer)
stargazer(mymodel, type="text", out="Data9.htm")
mymodel.exp = exp(coef(mymodel))
stargazer(mymodel, type="text", coef=list(mymodel.exp), p.auto=FALSE, out="Data9exp.htm")

