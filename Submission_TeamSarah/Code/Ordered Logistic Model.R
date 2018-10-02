## 2017 NHTS Data Challenge 
## DRAFT Sarah Grajdura 9.26.2018

## This file loads, merges, and cleans the data
## from the files "hhpub.csv" and "perpub.csv" 
## from Download Now (https://nhts.ornl.gov/)

## Set working directory 
working <-"/Users/sgrajdu2/Documents/GitHub/NHTSDataChallenge"
setwd(working)


install.packages("MASS")
#install.packages("brant")
library(MASS)
#library("brant")
install.packages("fastDummies")
library("fastDummies")
install.packages("rtf")
library(rtf)



### 1. Load data ###

# HH File
households <- read.csv("hhpub.csv", sep=",")
# Person File
persons <- read.csv("perpub.csv", sep = ",")



### 2. Merging raw data ###

# merge persons and households 
data <- merge(persons, households, "HOUSEID")
# save the file 
write.csv(data, file = "dataraw.csv")



### 3. Limit data to variables of interest ###
## according to VariableSelection.xlsx tab 2 ###

# remove household and person files
remove(households)
remove(persons)

# subset full dataset
data1 <- cbind(data$ALT_16, data$ALT_23, data$ALT_45, data$BIKE, data$BIKE_DFR, data$BIKE_GKP, data$BIKE4EX, data$BIKESHARE, data$BORNINUS, data$BUS, data$CAR, data$CARSHARE, data$CDIVMSAR.x, data$CNTTDHH, data$CNTTDTR, data$CONDNIGH, data$CONDPUB, data$CONDRIDE, data$CONDRIVE, data$CONDSPEC, data$CONDTAX, data$CONDTRAV, data$DELIVER, data$DRVRCNT.x, data$EDUC, data$GT1JBLWK, data$HBHTNRNT.x, data$HBPPOPDN.x, data$HEALTH, data$HH_HISP.x, data$HH_RACE.x, data$HHFAMINC.x, data$HHSIZE.x, data$HHSTATE.x, data$HHVEHCNT.x, data$HOMEOWN.x, data$HTEEMPDN.x, data$LIF_CYC.x, data$LPACT, data$MCUSED, data$MEDCOND, data$MSACAT.x, data$MSASIZE.x, data$NBIKETRP, data$NUMADLT.x, data$NWALKTRP, data$OCCAT, data$PC, data$PHYACT, data$PLACE, data$PRICE, data$PRMACT, data$PTRANS, data$PTUSED, data$R_AGE, data$R_HISP, data$R_RACE, data$R_SEX, data$RESP_CNT, data$SPHONE, data$TAXI, data$TIMETOWK, data$TRAIN, data$URBRUR.x, data$VPACT, data$W_CANE, data$W_CHAIR, data$W_CRUTCH, data$W_DOG, data$W_MTRCHR, data$W_NONE, data$W_SCOOTR, data$W_WHCANE, data$W_WLKR, data$WALK, data$WALK_DEF, data$WALK_GKQ, data$WALK2SAVE, data$WALK4EX, data$WEBUSE17, data$WKFTPT, data$WORKER, data$WRK_HOME, data$WRKCOUNT.x, data$YOUNGCHILD)

colnames(data1) <- c("ALT_16", "ALT_23", "ALT_45", "BIKE", "BIKE_DFR", "BIKE_GKP", "BIKE4EX", "BIKESHARE", "BORNINUS", "BUS", "CAR", "CARSHARE", "CDIVMSAR", "CNTTDHH", "CNTTDTR", "CONDNIGH", "CONDPUB", "CONDRIDE", "CONDRIVE", "CONDSPEC", "CONDTAX", "CONDTRAV", "DELIVER", "DRVRCNT", "EDUC", "GT1JBLWK", "HBHTNRNT", "HBPPOPDN", "HEALTH", "HH_HISP", "HH_RACE", "HHFAMINC", "HHSIZE", "HHSTATE", "HHVEHCNT", "HOMEOWN", "HTEEMPDN", "LIF_CYC", "LPACT", "MCUSED", "MEDCOND", "MSACAT", "MSASIZE", "NBIKETRP", "NUMADLT", "NWALKTRP", "OCCAT", "PC", "PHYACT", "PLACE", "PRICE", "PRMACT", "PTRANS", "PTUSED", "R_AGE", "R_HISP", "R_RACE", "R_SEX", "RESP_CNT", "SPHONE", "TAXI", "TIMETOWK", "TRAIN", "URBRUR", "VPACT", "W_CANE", "W_CHAIR", "W_CRUTCH", "W_DOG", "W_MTRCHR", "W_NONE", "W_SCOOTR", "W_WHCANE", "W_WLKR", "WALK", "WALK_DEF", "WALK_GKQ", "WALK2SAVE", "WALK4EX", "WEBUSE17", "WKFTPT", "WORKER", "WRK_HOME", "WRKCOUNT", "YOUNGCHILD")




### 4. Clean the data: Remove missing values ###

## -9 = Not Ascertained, 
## -7 = Prefer not to Answer (available when no answer given),
## -77 = Prefer not to Answer (always available), 
## -8 = I don't know (available when no answer given), 
## -88 = I don't know (always available)

# make logical matrix if cell < -1 
tmp <- data1 < -1

# sum across rows of matrix, (TRUE=1)
a <- apply(tmp, 1, sum)

# see distribution of missing values
table(a)

# make variable where a > 0 
b <- a > 0

# delete values for which a > 0 
data2 <- data1[!b,]
data2 <- data.frame(data2)




### 5. Clean the data: Account for  "Appropriate Skips" ###

# Recode W_ variables: appropriate skips = 0, yes = 1
data2$W_CANE <- ifelse(data2$W_CANE == -1, 0, 1)
data2$W_CHAIR <- ifelse(data2$W_CHAIR == -1, 0, 1)
data2$W_CRUTCH <- ifelse(data2$W_CRUTCH == -1, 0, 1)
data2$W_DOG <- ifelse(data2$W_DOG == -1, 0, 1)
data2$W_MTRCHR <- ifelse(data2$W_MTRCHR == -1, 0, 1)
data2$W_NONE <- ifelse(data2$W_NONE == -1, 0, 1)
data2$W_SCOOTR <- ifelse(data2$W_SCOOTR == -1, 0, 1)
data2$W_WHCANE <- ifelse(data2$W_WHCANE == -1, 0, 1)
data2$W_WLKR <- ifelse(data2$W_WLKR == -1, 0, 1)

# Recode COND variables: appropriate skips & no = 0, yes = 1
data2$CONDNIGH <- ifelse(data2$CONDNIGH==1, 1, 0)
data2$CONDPUB <- ifelse(data2$CONDPUB==1, 1, 0)
data2$CONDRIDE <- ifelse(data2$CONDRIDE==1, 1, 0)
data2$CONDRIVE <- ifelse(data2$CONDRIVE==1, 1, 0)
data2$CONDSPEC <- ifelse(data2$CONDSPEC==1, 1, 0)
data2$CONDTAX <- ifelse(data2$CONDTAX==1, 1, 0)
data2$CONDTRAV <- ifelse(data2$CONDTRAV==1, 1, 0)

# Recode MCUSED: Appropriate skip = 0 
data2$MCUSED <- ifelse(data2$MCUSED== -1, 0, data2$MCUSED)

# Recode: Appropriate skip = 0 (make new factor level of 0)
# (no bike trip in the past 7 days)
data2$BIKE_DFR <- ifelse(data2$BIKE_DFR== -1, 0, data2$BIKE_DFR)
data2$BIKE_GKP <- ifelse(data2$BIKE_GKP== -1, 0, data2$BIKE_GKP)

# Recode: Appropriate skip = 0 (no bike trip in the past 7 days)
data2$BIKE4EX <- ifelse(data2$BIKE4EX== -1, 0, data2$BIKE4EX)
data2$BIKESHARE <- ifelse(data2$BIKESHARE== -1, 0, data2$BIKESHARE)

# Recode: Appropriate skip = 0 (make new factor level of 0)
# (no walk trip in the past 7 days)
data2$WALK_DEF <- ifelse(data2$WALK_DEF== -1, 0, data2$WALK_DEF)
data2$WALK_GKQ <- ifelse(data2$WALK_GKQ== -1, 0, data2$WALK_GKQ)

# Recode VPACT: Appropriate skip = 0 (doesn't do vigorous physical activity)
data2$VPACT <- ifelse(data2$VPACT == -1, 0, data2$VPACT)

# Recode: Appropriate skip = 0 (doesn't work or works from home) 
data2$TIMETOWK <- ifelse(data2$TIMETOWK == -1, 0, data2$TIMETOWK)

# Recode: Appropriate skip = 0 (make new factor level)
# 0 = Non worker
data2$WKFTPT <- ifelse(data2$WKFTPT == -1, 0, data2$WKFTPT)
data2$OCCAT <- ifelse(data2$OCCAT == -1, 0, data2$OCCAT)
data2$GT1JBLWK <- ifelse(data2$GT1JBLWK == -1, 0, data2$GT1JBLWK)
data2$WRK_HOME <- ifelse(data2$WRK_HOME == -1, 0, data2$WRK_HOME)

# Recode: Appropriate skip = 0 (doesn't do moderate physical activity)
data2$LPACT <- ifelse(data2$LPACT == -1, 0, data2$LPACT)

# Recode: Appropraite skip = 0 (make new factor level, no vehicle)
data2$ALT_16 <- ifelse(data2$ALT_16 == -1, 0, data2$ALT_16)
data2$ALT_23 <- ifelse(data2$ALT_23 == -1, 0, data2$ALT_23)
data2$ALT_45 <- ifelse(data2$ALT_45 == -1, 0, data2$ALT_45)

# Recode: Appropriate skip = 0 (didn't take a walk, so none for exercise)
data2$WALK4EX <- ifelse(data2$WALK4EX == -1, 0, data2$WALK4EX)

# Recode: Appropraite skip = 0 (make new factor level, less that 16 years old)
data2$PRMACT <- ifelse(data2$PRMACT == -1, 0, data2$PRMACT)

# Recode: Appropriate skiip = 0 (Assume <16 yrs buy nothing online)
data2$DELIVER <- ifelse(data2$DELIVER == -1, 0, data2$DELIVER)

# Recode: Appropriate skiip = 0 (Assume <16 yrs can't carshare)
data2$CARSHARE <- ifelse(data2$CARSHARE== -1, 0, data2$CARSHARE)

# Recode: Appropriate skip = 0 (Assume <16 yrs don't work)
data2$WORKER <- ifelse(data2$WORKER== 0, 2, data2$WORKER)

# Recode: Appropriate skip =0 (assume those < 16 yrs have less than HS educ)
data2$EDUC <- ifelse(data2$EDUC == -1, 1, data2$EDUC)

# Recode: Appropriate skip = 5 (assume those who don't have a car can never make car trips)
data2$CAR <- ifelse(data2$CAR == -1, 5, data2$CAR)


# Generate Average HH Income variable 
data2$AVGHHINC <- (data2$HHFAMINC/data2$HHSIZE)


write.csv(data2, file="cleaneddataset.csv")
# 199,489 observations and 86 variables



# import string variables as characters.
data <- read.csv('F:/study/NHTS/DATA/cleaneddataset.csv')

test <- dummy_cols(data$CDIVMSAR)
test <- test[2:35]
data <- cbind(data, test)

# Make histograms 
library(ggplot2)
library(RColorBrewer)
library(scales)
data$HEALTH <- as.factor(data$HEALTH)

health <- ggplot(data, aes(HEALTH, fill=data$HEALTH)) + geom_bar(colour="black") + 
         scale_x_discrete(labels=c( "1" ="Excellent", "2" ="Very Good", "3" = "Good", "4" = "Fair", "5" = "Poor")) +
      labs(title="Self-Reported Health Status in Study Sample", caption= "N=199,489", x= "Health Status", y= "Number of Individuals") + 
      scale_y_continuous(label=comma, breaks=seq(0,80000,10000)) + 
      scale_fill_brewer(direction = -1, palette = "Oranges") + 
  theme_classic() + 
  theme(legend.position="none", plot.title = element_text(hjust = 0.5))  
health

ggsave("/Users/sgrajdu2/Desktop/NHTS/health.png")


# Reorder
data$HEALTH <- factor(data$HEALTH, levels=c("1", "2", "3", "4","5"), ordered=TRUE)
data$BIKE <- factor(data$BIKE, levels=c("1", "2", "3", "4","5"), ordered=TRUE)
data$TAXI <- factor(data$TAXI, levels=c("1", "2", "3", "4","5"), ordered=TRUE)
data$TRAIN <- factor(data$TRAIN, levels=c("1", "2", "3", "4","5"), ordered=TRUE)
data$BUS <- factor(data$BUS, levels=c("1", "2", "3", "4","5"), ordered=TRUE)
data$WALK <- factor(data$WALK, levels=c("1", "2", "3", "4","5"), ordered=TRUE)
data$CAR <- factor(data$CAR, levels=c("1", "2", "3", "4","5"), ordered=TRUE)
data$EDUC <- factor(data$EDUC, levels=c("1", "2", "3","4","5"), ordered=TRUE)
data$PHYACT <- factor(data$PHYACT, levels=c("1", "2", "3"), ordered=TRUE)
data$MSASIZE <- factor(data$MSASIZE, levels=c("1", "2", "3","4","5","6"), ordered=TRUE)
data$WALK2SAVE <- factor(data$WALK2SAVE, levels=c("1", "2", "3","4","5"), ordered=TRUE)
data$PLACE <- factor(data$PLACE, levels=c("1", "2", "3","4","5"), ordered=TRUE)

#data$R_AVGHHINC <- factor(data$R_AVGHHINC, levels=c("1", "2", "3","4", "5", "6","7","8","9","10","11"), ordered=TRUE)


# Prepare Training and Test Data
# set.seed(100)
# trainingRows <- sample(1:nrow(data), 0.7 * nrow(data))
# trainingData <- data[trainingRows, ]
# testData <- data[-trainingRows, ]

### Build ordered logistic regression model
options(contrasts = c("contr.treatment", "contr.poly"))

polrMod <- polr(HEALTH ~ BIKE+TAXI+TRAIN+BUS+WALK+CAR+EDUC+PHYACT+NWALKTRP+R_AGE+
                  DELIVER+R_HISP+PTUSE+R_SEX+TIMETOWK+NBIKETRP+CARSHARE+BIKESHARE+
                  CNTTDHH+HBPPOPDN+HHVEHCNT+URBRUR+WRKCOUNT+YOUNGCHILD+CNTTDTR +
                  PLACE+LPACT+WALK2SAVE+AVGHHINC+MSASIZE+ .data_32 + .data_23 + 
                  .data_93 + .data_74 + .data_92 + .data_73 + .data_33 + .data_72 + 
                  .data_13 + .data_22 + .data_31 + .data_34 + .data_91 + 
                  .data_54 + .data_21 + .data_43 + .data_52 + .data_94 + 
                  .data_11 + .data_42 + .data_51 + .data_44 + .data_83 + .data_24 + 
                  .data_82 + .data_84 ,data=data)
summary(polrMod)


