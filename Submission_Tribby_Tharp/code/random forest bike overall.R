setwd("H:/NCI_research/Data/NHTravelSurvey/Submission_working")
bike <- read.csv("data4xport.csv")
attach(bike)


library(rpart)

summary(bike)
head(bike)

length(biketyp2)
length(hispanic)

tree1 <- rpart(biketyp2~  busever
               + carever
               + carshare2
               + children
               + delivery
               + female
               + health2
               + hhactive
               + hhtrips
               + hispanic,
               method = "class", data = bike)
printcp(tree1) #display output
plotcp(tree1) #visualize cross-validation results
summary(tree1)
#detailed output of thresholds selected to transform to binary
#plot tree
plot(tree1, uniform = TRUE, main = "Bike Binary Tree")
text(tree1, use.n=TRUE, all=TRUE, cex=1.5)
#comment - pluck variables of interest
# select variables v1, v2, v3




myvars <- c("HOMEOWN","HHSIZE","HHVEHCNT","PC", "SPHONE", "TAB","PERSONID","rentpcnt","popdensity", "houseunits","hhtrips",
"active","hhactive","modecount","delivery", "carshare2","carever","walkever","busever", "taxiever","paraever","trainever","age",
"biketyp2", "mileyear","workhome", "workft", "walksafety","walkinfra","WALK4EX2", "female","white", "hispanic","PTUSED2","PRMACT2",
"PHYACT2","OCCAT2","NWALKTRP2","children","HTEEMPDN2", "HTPPOPDN2","HHFAMINC2", "health2","HBRESDN2","ALT_16_r","ALT_23_r" ,"BIKE_DFR_r", 
"BIKE_GKP_r","BORNINUS_r", "DELIVER_r", "Distance",  "DRIVER_r", "DRVRCNT_r","EDUC_r",    "FLEXTIME_r", "TravDayHM" ,"GT1JBLWK_r", 
"HBHTNRNT_r", "HBRESDN_r")
bike2 <- bike[myvars]



library(randomForest)


## This will create train and test datasets for random forest work.
## Set the seed to make your partition reproductible.  
set.seed(42)
samp <- sample(nrow(bike2), 0.6 * nrow(bike2))
train <- bike2[samp, ]
test <- bike2[-samp, ]
summary (train)



###==============================================================================
#This gets rid of rows with NA/missing so it retains complete cases
trainfinal <- train[complete.cases(train),]
summary(trainfinal)
testfinal <- test[complete.cases(test),]
summary(testfinal)
## how do i count cases?
n_cases <- table(trainfinal$biketyp2)
print(n_cases)
n_cases2 <- table(testfinal$biketyp2)
print(n_cases2)
dim(testfinal)



#comment  nulls in the person id imply different row counts, non-rectangular dataframe matrix
require(reshape2)
test$personid <- rownames(test) 
melt(test)

require(reshape2)
train$personid <- rownames(train) 
melt(train)


library(randomForest)
names(train)
summary(trainfinal)

trainfinal$biketyp2 <- as.character(trainfinal$biketyp2)
trainfinal$biketyp2 <- as.factor(trainfinal$biketyp2)


testfinal$biketyp2 <- as.character(testfinal$biketyp2)
testfinal$biketyp2 <- as.factor(testfinal$biketyp2)

fit <- randomForest((biketyp2) ~ HOMEOWN + HHSIZE + HHVEHCNT + PC + SPHONE + TAB + popdensity 
                    + hhtrips + active + hhactive + modecount + delivery + carshare2 + carever + walkever + busever
                    + taxiever + paraever + trainever + age + mileyear + workhome + workft + walksafety
                    + walkinfra + WALK4EX2 + female + white + hispanic + PTUSED2 + PRMACT2 + PHYACT2 + OCCAT2 + NWALKTRP2
                    + children + HTEEMPDN2 + HHFAMINC2 + health2 + ALT_16_r + ALT_23_r + BORNINUS_r + DELIVER_r + Distance + DRIVER_r + DRVRCNT_r + EDUC_r + FLEXTIME_r + TravDayHM
                    + GT1JBLWK_r + HBHTNRNT_r + HBRESDN_r,
                    data=trainfinal, 
                    importance=TRUE, 
                    ntree=100)

varImpPlot(fit)

## There're two types of importance measures shown above. The accuracy one 
## tests to see how worse the model performs without each variable, so a high 
## decrease in accuracy would be expected for very predictive variables. The 
## Gini one digs into the mathematics behind decision trees, but essentially 
## measures how pure the nodes are at the end of the tree. Again it tests to 
## see the result if each variable is taken out and a high score means the
## variable was important.

summary(fit)

#write random forest out
#not curently working  - - -end of Sept30 2018 workfa
Prediction <- predict(fit, testfinal)
submit <- data.frame(personid = testfinal$personid, biketyp2 = Prediction)
write.csv(submit, file = "firstforest.csv", row.names = FALSE)
summary(submit)


#partial dependence plots
imp <- importance(fit)
impvar <- rownames(imp)[order(imp[, 1], decreasing=TRUE)]
op <- par(mfrow=c(2, 3))
# for loop to generate all plots
for (i in seq_along(impvar)) {
  partialPlot(fit, trainfinal, impvar[i], which.class=1, xlab=impvar[i],
              main=paste("Partial Dependence on", impvar[i]))
}


