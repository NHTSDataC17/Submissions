library("magrittr")
library("plyr")
library("dplyr")
library("stringr")
library("reshape")
library("tidyr")
library("zoo")
library("ggplot2")


#### read file ####
library(summarizeNHTS)
nhts_data <- read_data("2017", "./data")
per<-read.csv("./data/csv/2017/person.csv",header = TRUE)
trip<-read.csv("./data/csv/2017/trip.csv",header = TRUE)


## link files
data_trip<-data.frame(trip[,c(46,1:8,18,27,32,59,60,70,76)])


###########################################################################
## Data Processing
###########################################################################
## re-define the priority of trips -- home1-mandatory2-flexible3-optional4-transfer5-other97 ####
data_trip$WHYFROM<-as.character(data_trip$WHYFROM)
data_trip$WHYTO<-as.character(data_trip$WHYTO)
data_trip$WHYFROM<-revalue(data_trip$WHYFROM, c("-9"="-9","-8"="-8", "-7"="-7","1"="1","3"="2", "4"="2","8"="2","9"="2","10"="2", 
                                                "11"="3","12"="3","13"="3","14"="3",
                                                "15"="4","16"="4","17"="4","18"="4","19"="4","5"="4",
                                                "7"="5","6"="5",
                                                "97"="97"))
data_trip$WHYTO<-revalue(data_trip$WHYTO, c("-9"="-9","-8"="-8", "-7"="-7","1"="1","3"="2", "4"="2","8"="2","9"="2","10"="2", 
                                            "11"="3","12"="3","13"="3","14"="3",
                                            "15"="4","16"="4","17"="4","18"="4","19"="4","5"="4",
                                            "7"="5","6"="5",
                                            "97"="97"))
table(data_trip$WHYTO)
# change mode -- new mobility(tnc), motor(mo), Public Transportation(pt), Active Transportation (bw), Airport Transportation(at)
data_trip$TRPTRANS<-as.character(data_trip$TRPTRANS)
data_trip$TRPTRANS<-revalue(data_trip$TRPTRANS, c("-9"="-9","-8"="-8", "-7"="-7",
                                                  "1"="bw","2"="bw", 
                                                  "3"="mo","4"="mo","5"="mo","6"="mo","7"="mo","8"="mo","9"="mo",
                                                  "10"="pt","11"="pt","12"="pt","13"="pt","14"="pt","15"="pt","16"="pt",
                                                  "17"="tnc","18"="tnc","19"="at","20"="pt",
                                                  "97"="97"))


# chain ID & O_mode_D 
data_trip$hhperID<-paste0 (data_trip$HOUSEID,sep = "", data_trip$PERSONID,collapse = NULL)
data_trip$WHYOD<-paste0(data_trip$WHYFROM,sep = "_", data_trip$WHYTO,collapse = NULL)
data_trip$WHYO_mode_D<-paste0(data_trip$WHYFROM,sep = "_",data_trip$TRPTRANS,sep = "_", data_trip$WHYTO,collapse = NULL)
data_trip$WHYO_<-paste0(data_trip$WHYFROM,sep = "_",data_trip$TRPTRANS,sep = "_",collapse = NULL)

#### fist/last trip from/to Home ####
first<-as.data.frame(unique(filter(data_trip, (TDTRPNUM==1 & WHYFROM=="1"))[,which(colnames(data_trip)=="hhperID")]))
colnames(first)<-c("hhperID")
first_trip<-nrow(subset(data_trip, TDTRPNUM==1 & WHYFROM==1))/nrow(subset(data_trip, TDTRPNUM==1))

person_num_trip<-as.data.frame(table(data_trip$hhperID))
colnames(person_num_trip)<-c("hhperID","fre")
last_trip<-filter(merge(data_trip,person_num_trip,by="hhperID"),TDTRPNUM==fre)
last<-as.data.frame(unique(a<-filter(last_trip, (TDTRPNUM==fre & WHYTO=="1"))[,which(colnames(last_trip)=="hhperID")]))
colnames(last)<-c("hhperID")
last_trip<-nrow(subset(last_trip, TDTRPNUM==fre & WHYTO==1))/nrow(subset(last_trip, TDTRPNUM==fre))
# majority of travel commenced (0.904184 of initial trips) and ended (0.9213153 per cent of final trips) at home
## trip OD==home
OD_home<-merge(first, last, by = "hhperID") #185871
data_trip<-merge(x=OD_home,y=data_trip, by = "hhperID", all.x =TRUE) #807447


###########################################################################
## persons who use TNC at least once
###########################################################################
#### select trip chain related to TNC ####
TNCtrip<-subset(data_trip,data_trip$TRPTRANS=="tnc")
TNCperson<-TNCtrip %>%
  filter(TRPTRANS=="tnc") %>% 
  group_by(hhperID) %>%
  summarise(numtrip = n())
TNCperson_trip<-merge(x = TNCperson, y = data_trip, by = "hhperID", all.x = TRUE)


###########################################################################
## Trip Chain
###########################################################################

### get trip chain O_mode_D ###
trip_chain_o_m_d<- TNCperson_trip %>%
  arrange(TDTRPNUM,hhperID)%>%
  group_by(hhperID) %>%
  summarise(WHYO_=paste(WHYO_,collapse = ""),numtrip = n()) %>%
  arrange(hhperID)
trip_chain_o_m_d$O_mode_D<-with(trip_chain_o_m_d,paste0(WHYO_,"1"))

## Search for the number of occurance of trip chain for first/mile transfer
trip_chain_o_m_d$numTNC <- str_count(trip_chain_o_m_d$O_mode_D, "_tnc_")

### get trip chain OD ###
trip_chain_o_d<- TNCperson_trip %>%
  arrange(TDTRPNUM,hhperID)%>%
  group_by(hhperID) %>%
  summarise(OD=paste(WHYFROM,collapse = "_"),numtrip = n()) %>%
  arrange(hhperID)
trip_chain_o_d$O_D<- with(trip_chain_o_d,paste0(OD,"_1"))

### categorize trip chain typology ###
trip_chain_o_d$type<-"other"
i<-1
for (i in (1:nrow(trip_chain_o_d))){
  if ((str_detect(trip_chain_o_d[i,4], "2")==FALSE) & (str_detect(trip_chain_o_d[i,4], "3")==TRUE) & (str_detect(trip_chain_o_d[i,4], "4")==FALSE)){
    trip_chain_o_d[i,5] <-"h-f-h"
  } else if ((str_detect(trip_chain_o_d[i,4], "2")==FALSE) & (str_detect(trip_chain_o_d[i,4], "3")==FALSE) & (str_detect(trip_chain_o_d[i,4], "4")==TRUE)){
    trip_chain_o_d[i,5] <-"h-o-h"
  } else if ((str_detect(trip_chain_o_d[i,4], "2")==FALSE) & ((str_detect(trip_chain_o_d[i,4], "3")==TRUE) | (str_detect(trip_chain_o_d[i,4], "4")==TRUE)) ){
    trip_chain_o_d[i,5] <-"h-(f+o)-h"
  }
}


for (i in (1:nrow(trip_chain_o_d))){
  if (str_detect(trip_chain_o_d[i,4], "2")==TRUE){
    if (str_count(trip_chain_o_d[i,4], "_2_")==1){
      if (str_detect(trip_chain_o_d[i,4], "1_2")==TRUE | str_detect(trip_chain_o_d[i,4], "2_1")==TRUE){
        trip_chain_o_d[i,5] <-"h-p-h"
        } else if (str_detect(trip_chain_o_d[i,4], "1_2")==FALSE | str_detect(trip_chain_o_d[i,4], "2_1")==FALSE){
        trip_chain_o_d[i,5] <-"h-(s)-p-(s)-h"
      }
    }
  }
}

for (i in (1:nrow(trip_chain_o_d))){
  if (str_detect(trip_chain_o_d[i,4], "2")==TRUE){
    if (str_count(trip_chain_o_d[i,4], "_2_")>=2){
      if ((str_detect(trip_chain_o_d[i,4], "1_2")==TRUE) & (str_detect(trip_chain_o_d[i,4], "2-1")==TRUE)){
        trip_chain_o_d[i,5] <-"h-(s)-p-s-p-(s)-h"
      } else if ((str_detect(trip_chain_o_d[i,4], "1_2")==FALSE) & (str_detect(trip_chain_o_d[i,4], "2-1")==FALSE)){
        trip_chain_o_d[i,5] <-"h-(s)-p-s-p-(s)-h"
      } else if ((str_detect(trip_chain_o_d[i,4], "1_2")==TRUE) & (str_detect(trip_chain_o_d[i,4], "2-1")==FALSE)){
        trip_chain_o_d[i,5] <-"h-(s)-p-s-p-(s)-h"
      } else if ((str_detect(trip_chain_o_d[i,4], "1_2")==FALSE) & (str_detect(trip_chain_o_d[i,4], "2-1")==TRUE)){
        trip_chain_o_d[i,5] <-"h-(s)-p-s-p-(s)-h"
      }
    }
  }
}

#### Weighted distribution of trip chain typology
trip_chain_o_d$type<-as.factor(trip_chain_o_d$type)
trip_chain_o_d$HOUSEID<- as.character(str_sub(trip_chain_o_d$hhperID,1,8))
trip_chain_o_d$PERSONID<- str_sub(trip_chain_o_d$hhperID,-1,-1)
trip_chain_o_d$PERSONID<-paste0("0",sep = "",trip_chain_o_d$PERSONID,collapse = NULL)
person_weight<-as.data.frame(nhts_data$weights$person)[,c(1:3)]
trip_chain_o_d<-merge(trip_chain_o_d,person_weight,by=c("HOUSEID","PERSONID"))
trip_chain_o_d$count_weight<-trip_chain_o_d$WTPERFIN/360

o_d_per<-trip_chain_o_d %>% 
  group_by(type) %>% 
  summarise(Frequency = sum(count_weight)) %>%
  mutate(perc = Frequency / sum(Frequency))
o_d_per$category<-c("Nonwork Based","Work Based","Work Based","Nonwork Based","Nonwork Based","Work Based","Other")
ggplot(o_d_per, aes(x = reorder(type, -perc), y = perc, fill=category))+
  geom_bar(stat = "identity")+
  labs(x="Trip Chain Typology")+
  labs(y="Percentage")+
  scale_fill_manual(values=c("#E69F00","#999999", "#56B4E9"))+
  theme_classic()+
  theme(text = element_text(family="Times", face="bold", size=15,vjust = 0.5))
  










