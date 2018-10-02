#data
library(summarizeNHTS)
nhts_data <- read_data("2017", "../data")
df_trip <- as.data.frame(nhts_data$data$trip)
df_person <- as.data.frame(nhts_data$data$person)

#tnc data
df_tnc_person <- df_person[df_person$USES_TNC==1,]
df_tnc_trip <- merge(df_trip,df_tnc_person,by=c("HOUSEID","PERSONID"))
df_tnc_trip <- merge(df_tnc_trip,as.data.frame(nhts_data$weights$person),by=c("HOUSEID","PERSONID"))
df <- data.frame(hid=df_tnc_trip$HOUSEID,
                 pid=df_tnc_trip$PERSONID,
                 w=df_tnc_trip$WTPERFIN*365,
                 t=df_tnc_trip$STRTTIME,
                 edu=df_tnc_trip$EDUC,
                 mode=df_tnc_trip$TRPTRANS)

#cleaning
lambda <- function(x) as.numeric(as.character(x)) > 0
df <- df[complete.cases(df)&lambda(df$edu)&lambda(df$mode),]
df$mode <- factor(as.character(df$mode))
df$edu <- factor(as.character(df$edu))
df <- df[order(df$hid,df$pid,df$t),]

library(dplyr)
#marginal distribution
mode <- df %>% group_by(edu,mode) %>% summarise(total=sum(w))
mode <- data.frame(mode)
mode$edu <- as.numeric(as.character(mode$edu))
mode$mode <- as.numeric(as.character(mode$mode))
#conditional distribution
df_pairs <- data.frame()
for(i in 1:nrow(df)){
  if(i==nrow(df)){
    df_pairs <- rbind(df_pairs,data.frame(hid=df[i,]$hid,pid=df[i,]$pid,w=df[i,]$w,edu=df[i,]$edu,m1=as.character(df[i,]$mode),m2='0'))
  }
  else{
    if(df[i,]$hid==df[i+1,]$hid&df[i,]$pid==df[i+1,]$pid){
      df_pairs <- rbind(df_pairs,data.frame(hid=df[i,]$hid,pid=df[i,]$pid,w=df[i,]$w,edu=df[i,]$edu,m1=as.character(df[i,]$mode),m2=as.character(df[i+1,]$mode)))
    }
    else{
      df_pairs <- rbind(df_pairs,data.frame(hid=df[i,]$hid,pid=df[i,]$pid,w=df[i,]$w,edu=df[i,]$edu,m1=as.character(df[i,]$mode),m2='0'))
    }
  }
}
pairs <- df_pairs %>% group_by(edu,m1,m2) %>% summarise(total=sum(w))
pairs <- data.frame(pairs)
pairs$edu <- as.numeric(as.character(pairs$edu))
pairs$m1 <- as.numeric(as.character(pairs$m1))
pairs$m2 <- as.numeric(as.character(pairs$m2))

#1-gram model
fully_pooling <- function(mode,pairs){
  temp <- as.data.frame(table(pairs$m1,pairs$m2))
  temp <- data.frame(temp[temp$Freq>0,1:2])
  res <- c()
  for(i in 1:nrow(temp)){
    res <- c(res,sum(pairs[pairs$m1==temp[i,1]&pairs$m2==temp[i,2],]$total)/sum(mode[mode$mode==temp[i,1],]$total))
  }
  temp <- cbind(temp,res=res)
  return(temp)
}
no_pooling <- function(mode,pairs){
  temp <- data.frame(pairs[,1:3])
  res <- c()
  for(i in 1:nrow(temp)){
    res <- c(res,pairs[pairs$edu==temp[i,1]&pairs$m1==temp[i,2]&pairs$m2==temp[i,3],]$total/mode[mode$edu==temp[i,1]&mode$mode==temp[i,2],]$total)
  }
  temp <- cbind(temp,res=res)
  return(temp)
}
partial_pooling <- function(mode,pairs){
  temp <- pairs[,1:3]
  temp1 <- data.frame(no_pooling(mode,pairs))
  k <- c()
  for(i in unique(mode$edu)){
    temp2 <- temp[temp$edu==i,]
    a <- c()
    b <- c()
    p <- c()
    for(j in 1:nrow(temp2)){
      p <- c(p,temp1[temp1[,1]==temp2[j,1]&temp1[,2]==temp2[j,2]&temp1[,3]==temp2[j,3],4])
      a <- c(a,sum(pairs[pairs$m1==temp2[j,2]&pairs$m2==temp2[j,3],]$total))
      b <- c(b,sum(mode[mode$mode==temp2[j,2],]$total))
    }
    k <- c(k,mean(p-a/b))
  }
  res <- c()
  for(i in 1:nrow(temp)){
    res <- c(res,k[temp[i,1]]+(sum(pairs[pairs$m1==temp[i,2]&pairs$m2==temp[i,3],]$total))/sum(mode[mode$mode==temp[i,2],]$total))
  }
  temp <- cbind(temp,res=res)
  return(temp)
}
#results of partial-pooling model
res <- data.frame(partial_pooling(mode,pairs))
write.csv(res,'transportation_transformation.csv')
