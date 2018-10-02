setwd("F:/UCI/Research/My Papers/Transit")
library(readr)
library(plyr)

# Computes time2 - time1
circular.difftime <- function(time1, time2) {
  time1 = as.numeric(time1)
  time2 = as.numeric(time2)
  h1 = time1 %/% 100
  m1 = time1 %% 100
  h2 = time2 %/% 100
  m2 = time2 %% 100
  
  h2 = 24 + h2
  (h2 - h1) * 60 + m2 - m1
}

# Compute time2 - time1
difftime <- function(time1, time2) {
  time1 = as.numeric(time1)
  time2 = as.numeric(time2)
  h1 = time1 %/% 100
  m1 = time1 %% 100
  h2 = time2 %/% 100
  m2 = time2 %% 100
  
  diff = (h2 - h1) * 60 + m2 - m1
  max(diff, 0)
}

get_trip_purpose <- function(p) {
  trip.purpose = 1
  if (p <= 4)
    trip.purpose = p
  else if (p == 7)
    trip.purpose = 7
  else if (p %in% c(8,9, 19))
    trip.purpose = 20
  else if (p == 18)
    trip.purpose = 30
  else if (p %in% c(11, 12, 14))
    trip.purpose = 40
  else if (p %in% c(15, 17))
    trip.purpose = 50
  else if (p == 6)
    trip.purpose = 70
  else if (p == 13)
    trip.purpose = 80
  else if (p %in% c(5, 10, 16, 97))
    trip.purpose = 97
  else
    stop('Unknow trip purpose type', p)
}

# Trip mode type
get_trip_mode <- function(trip.mode) {
  if (trip.mode == 3) {
    mtype = 'C'
  }
  else if (trip.mode == 1) {
    mtype = 'W'
  }
  else if (trip.mode %in% c(11, 13, 14, 15, 16)) {
    mtype = 'PT'
  }
  else if (trip.mode == 17)
    mtype = 'T'
  else 
    mtype = 'O'
}

# Compute all tours 
find_all_tours <- function(houseid, personid) {
  mytrips = trips[trips$HOUSEID == houseid & trips$PERSONID == personid, ]
  act.string = c()
  
  trip.purposes = sapply(mytrips$WHYTO, get_trip_purpose)
  trip.modes = sapply(mytrips$TRPTRANS, get_trip_mode)
  trip.start.times = c(mytrips$STRTTIME, NA)
  trip.end.times = c(mytrips$ENDTIME, NA)
  
  trip.traveltimes = mytrips$TRVLCMIN
  trip.dwelltimes = mytrips$DWELTIME
  
  for (k in 1:nrow(mytrips)) {
    src.purpose = mytrips[k, 'WHYFROM']
    dst.purpose = mytrips[k, 'WHYTO']
    trip.mode = mytrips[k, "TRPTRANS"] 
    
    start.time = mytrips[k, 'STRTTIME']
    end.time  =  mytrips[k, 'ENDTIME']
    
    # Activity location: home, work and non-work
    act = 'N'
    if (src.purpose %in% c(1, 2))
      act = 'H'
    else if (src.purpose %in% c(3, 4))
      act = 'W'
    act.string = c(act.string, act)
  }
  
  # Add the last destination activity
  act = 'N'
  if (dst.purpose %in% c(1, 2))
    act = 'H'
  else if (dst.purpose %in% c(3, 4))
    act = 'W'
  act.string = c(act.string, act)
  
  #cat(act.string, '\n')
  
  # If the last purpose is WORK (3) and its matches with the first purpose 
  # and dwell time is negative, compute from start, end time
  # if (nrow(mytrips) > 1 & dst.purpose == 3 & dst.purpose == mytrips[1, 'WHYFROM'] & dwelltime < 0) {
  #   day.start = mytrips[1, "STRTTIME"]
  #   day.end = mytrips[nrow(mytrips), "ENDTIME"]
  #   #cat(sum(c(mytrips$TRVLCMIN, mytrips[mytrips$DWELTIME > 0, 'DWELTIME'])), '\n')
  #   #cat(houseid, personid, day.end, '----', day.start, circular.difftime(day.end, day.start), '\n')
  #   work.duration = work.duration + circular.difftime(day.end, day.start)
  # }
  
  # Scan the act.string for detecting tours
  inside.tour = FALSE
  tour.act = c()
  trip.purposes.pertour = c()
  trip.mode.pertour = c()
  tours = list()
  ntour = 1
  
  for (m in 1:(length(act.string)-1)) {
    act1 = act.string[m]
    act2 = act.string[m + 1]
    trip.purpose = trip.purposes[m]
    trip.mode = trip.modes[m]
    trip.start = trip.start.times[m]
    trip.end = trip.end.times[m]
    traveltime = trip.traveltimes[m]
    dwelltime = trip.dwelltimes[m]
    
    if (dwelltime > 0 & traveltime > 0) {
      if (act2 == 'W')
        work.duration = work.duration + dwelltime
      else if (act2 =='N') {
        if (trip.mode == 'PT') {
          transit.duration = transit.duration + traveltime
          transit.act.duration = transit.act.duration + dwelltime
        }
        else {
          nontransit.duration = nontransit.duration + traveltime
          nontransit.act.duration = nontransit.act.duration + dwelltime
        }
      }
      if (act2 == 'N') {
        nonwork.travel.duration = nonwork.travel.duration + traveltime
        nonwork.act.duration = nonwork.act.duration + dwelltime
      }
    }
    
    if (act1 != 'H' & act2 == 'H' & inside.tour) { 
      # Tour ends 
      inside.tour = FALSE
      tour.act = c(tour.act, act2)
      trip.mode.pertour = c(trip.mode.pertour, trip.mode)
      full.tour.act = tour.act
      tour.end = trip.end
      #cat('Got a tour', tour.act, tour.start, tour.end, '\n')
      
      tour.type = NA
      tour.act = full.tour.act[-c(1, length(tour.act))]
      if (length(tour.act) > 0) {
        # New tour types
        # HBSimple: HW+H
        # HBOnly: HN*W+N*H
        # HBandWB: HN*W+N+W+N*H
         
        tour.string = paste(full.tour.act, collapse = '')
        pattern.strings = list(
          HBSimple = 'HWH',
          HBOnly= 'HN*WN*H',
          HBandWB = 'HN*W+N+W+N*H'
        )
        
        if (grepl(pattern.strings$HBOnly, tour.string)) {
          if (grepl('N', tour.string))
            tour.type = 'HBOnly'
          else
            tour.type = 'HBSimple'
        }
        else if (grepl(pattern.strings$HBandWB, tour.string))
          tour.type = 'HBandWB'
        else
          tour.type = 'OTHER'
        
        # Old tour type
        # if (all(tour.act == 'W')){
        #   work.only.tour = 1
        #   tour.type = 'WO'
        # }
        # else if (any(tour.act == 'W') & any(tour.act == 'N')){
        #   work.nonwork.tour = 1
        #   tour.type = 'WNW'
        # }
        # else if (all(tour.act == 'N')) {
        #   if (length(tour.act) == 1){
        #     simple.nonwork.tour = 1
        #     tour.type = 'SNW'
        #   }
        #   else{
        #     complex.nonwork.tour = 1
        #     tour.type = 'CNW'
        #   }
        # }
        tentry = list(wholeacstring = paste(act.string, collapse = ''),
                              trip.purposes = trip.purposes,
                              trip.modes = trip.modes,
                              trip.mode.pertour = trip.mode.pertour,
                              touract = full.tour.act, 
                              tour.string = tour.string,
                              trip.purposes.pertour = trip.purposes.pertour,
                              starttime = tour.start,
                              endtime = tour.end,
                              duration = difftime(tour.start, tour.end),
                              type = tour.type,
                              work.duration = work.duration,
                              transit.duration = transit.duration,
                              transit.act.duration = transit.act.duration,
                              nontransit.act.duration = nontransit.act.duration,
                              nontransit.duration = nontransit.duration,
                              nonwork.act.duration= nonwork.act.duration,
                              nonwork.travel.duration = nonwork.travel.duration
                              )
        tours[[ntour]] = tentry
        ntour = ntour + 1
      }
    }
    else if (act1 == 'H' & act2 != 'H' & !inside.tour) {
      # Start of a tour
      inside.tour = TRUE
      transit.duration = 0
      nontransit.duration = 0
      work.duration = 0
      transit.act.duration = 0
      nontransit.act.duration = 0
      nonwork.travel.duration = 0
      nonwork.act.duration = 0
      
      tour.start = trip.start
      trip.purposes.pertour = c()
      tour.act = c(act1)
      
      if (trip.purpose == 7){ # Connecting trips
        trip.mode.pertour = c(trip.mode, '->')
      }
      else {
        trip.mode.pertour = c(trip.mode)
      }
      
      if (trip.purpose != 7) {
        tour.act = c(tour.act, act2)
        if (act2 == 'N')
          trip.purposes.pertour = c(trip.purpose)
      }
      
      if (dwelltime > 0 & traveltime > 0) {
        if (act2 == 'W')
          work.duration = work.duration + dwelltime
        else if (act2 == 'N') {
          if (trip.mode  == 'PT') {
            transit.duration = transit.duration + traveltime
            transit.act.duration = transit.act.duration + dwelltime
          }
          else {
            nontransit.duration = nontransit.duration + traveltime
            nontransit.act.duration = nontransit.act.duration + dwelltime
          }
        }
        
        if (act2 == 'N') {
          nonwork.travel.duration = nonwork.travel.duration + traveltime
          nonwork.act.duration = nonwork.act.duration + dwelltime
        }
      }
    }
    else if (inside.tour) {
      if (trip.purpose == 7) 
        trip.mode.pertour = c(trip.mode.pertour, trip.mode, '->')
      else 
        trip.mode.pertour = c(trip.mode.pertour, trip.mode)
      
      if (trip.purpose != 7){
        tour.act = c(tour.act, act2)
        if (act2 == 'N') 
          trip.purposes.pertour = c(trip.purposes.pertour, trip.purpose)
      }
    }
  }
  tours
}


persons <- read.csv('NHTS 2017/Csv/perpub.csv')
households <- read.csv('NHTS 2017/Csv/hhpub.csv')
trips <- read.csv('NHTS 2017/Csv/trippub.csv')
vehicles <- read.csv('NHTS 2017/Csv/vehpub.csv')

nrow(households)
nrow(persons)
nrow(trips)
nrow(vehicles)

ncol(households)
ncol(persons)
ncol(trips)
ncol(vehicles)


length(unique(persons$HOUSEID))
length(unique(households$HOUSEID))
length(unique(trips$HOUSEID))

cand.ids <- persons[persons$WRKTRANS %in% c(11, 13, 14, 15, 16) & persons$R_AGE >= 18, c('HOUSEID', 'PERSONID')]
cand.trips <- merge(cand.ids, trips)
cand.work.trips <- ddply(cand.trips, c('HOUSEID','PERSONID'), summarise, 
                         WORK = any(WHYTO == 3), TRANSIT = any(TRPTRANS %in% c(11, 13:16)))
cand.ids <- cand.work.trips[cand.work.trips$WORK & cand.work.trips$TRANSIT, c('HOUSEID', 'PERSONID')]
  
nrow(cand.work.trips)
nrow(cand.ids)       

candidates <- merge(x = cand.ids, y = persons)
nrow(candidates)       
candidates <- merge(x = candidates, y = households)
nrow(candidates)


table(candidates$HHFAMINC)
table(candidates$R_SEX)
table(candidates$HHVEHCNT)
table(candidates$PLACE)

table(candidates$HHSIZE)

# Child counts: age groups (0-5), (6-17)
children.per.household <- ddply(persons[persons$HOUSEID %in% candidates$HOUSEID, c('HOUSEID', 'R_AGE', 'R_RELAT'), ], c('HOUSEID'), summarize,
                               NCHILD0TO5 = sum(R_RELAT == 3 & R_AGE > 0 & R_AGE <= 5),
                               NCHILD6TO17 = sum(R_RELAT == 3 & R_AGE >= 6 & R_AGE <= 17)
)

table(children.per.household$NCHILD0TO5)

head(children.per.household[children.per.household$NCHILD0TO5 == 0, "HOUSEID"])
persons[persons$HOUSEID == 30001409, c("PERSONID", "R_RELAT")]

table(candidates$HHSIZE)

table(children.per.household$NCHILD0TO5)
table(children.per.household$NCHILD6TO17)
hist(candidates$R_AGE)

nrow(children.per.household)
length(unique(candidates$HOUSEID))


length(unique(candidates[candidates$HHFAMINC == 11, 'HOUSEID']))
hist(candidates$HHFAMINC, probability = T)

candidates <- merge(x = candidates, y = children.per.household)
nrow(candidates)
table(candidates$NCHILD6TO17)

ncol(candidates)


# trip related attributes

head(candidates[, c("HOUSEID", "PERSONID")])
trips[trips$HOUSEID == 30001109 & trips$PERSONID == 1, c("TDTRPNUM", "STRTTIME", "ENDTIME", "TRVLCMIN", "TRPTRANS", "WHYFROM","WHYTO", "DWELTIME")]

#trip.per.person <- ddply(merge(x = candidates, y = trips), c('HOUSEID', 'PERSONID'), summarise, NTRIP = length(TDTRPNUM))
#trip.per.person[trip.per.person$NTRIP > 10, ]
#trips[trips$HOUSEID == 40441708 & trips$PERSONID == 1, c("TDTRPNUM", "STRTTIME", "ENDTIME", "TRVLCMIN", "TRPTRANS", "WHYFROM","WHYTO", "DWELTIME")]
mytrips = trips[trips$HOUSEID == 40441708 & trips$PERSONID == 1, ]
mytrips = trips[trips$HOUSEID == 30000341 & trips$PERSONID == 2, ]
mytrips = trips[trips$HOUSEID == 30002316 & trips$PERSONID == 2, ]

mytrips[, c("TDTRPNUM", "STRTTIME", "ENDTIME", "TRVLCMIN", "TRPTRANS", "WHYFROM","WHYTO", "WHYTRP1S", "DWELTIME")]
find_all_tours(40240410, 1)


for(i in 1:nrow(candidates)) {
  houseid = candidates[i, "HOUSEID"]
  personid = candidates[i, "PERSONID"]
  candidates[i, 'UNIQUEID'] = paste(houseid, personid, sep = '_')
  
  work.duration = 0
  transit.duration = 0
  transit.act.duration = 0
  nontransit.act.duration = 0
  nontransit.duration = 0
  nonwork.act.duration = 0
  nonwork.travel.duration = 0
  
  if (candidates[i, "TIMETOWK"] > 0)
    work.travel.duration = candidates[i, "TIMETOWK"]
  else
    work.travel.duration = NA
  
  mytours = find_all_tours(houseid, personid)

  candidates[i, 'NTOUR'] = length(mytours)
  
  if (length(mytours) == 0)
    next
  
  all.transit = FALSE
  mixed.transit = FALSE
  no.transit = FALSE
  for (t in mytours) {
    if (t$type != 'OTHER' & length(t$trip.mode.pertour) > 0) {
      all.transit = all.transit | any(t$trip.mode.pertour == 'PT') & all(t$trip.mode.pertour %in% c('PT', 'W'))
      mixed.transit = mixed.transit | any(t$trip.mode.pertour == 'PT') & any(t$trip.mode.pertour %in% c('C', 'T', 'O'))
      no.transit = no.transit | !any(t$trip.mode.pertour == 'PT')
      
      work.duration = work.duration + t$work.duration
      transit.duration = transit.duration + t$transit.duration
      transit.act.duration = transit.act.duration + t$transit.act.duration
      nontransit.act.duration = nontransit.act.duration + t$nontransit.act.duration
      nontransit.duration = nontransit.duration + t$nontransit.duration
      nonwork.act.duration = nonwork.act.duration + t$nonwork.act.duration
      nonwork.travel.duration = nonwork.travel.duration + t$nonwork.travel.duration
    }
  }  
  ttype = sapply(mytours, function(x){x$type})
  
  for(tt in c('HBSimple', 'HBOnly', 'HBandWB', 'OTHER'))
    candidates[i, tt] = ifelse(any(ttype == tt), 1, 0)
  
  candidates[i, 'MODEALLTRANSIT'] = ifelse(all.transit, 1, 0)
  candidates[i, 'MODEMIXED'] = ifelse(mixed.transit, 1, 0)
  candidates[i, 'MODENOTRANSIT'] = ifelse(no.transit, 1, 0)
  
  
  candidates[i, 'WORKACTDUR'] = work.duration
  candidates[i, 'WORKTRAVELDUR'] = work.travel.duration
  candidates[i, 'WORKACTTRAVELDUR'] = work.duration + work.travel.duration 
  
  candidates[i, 'TRANSITACTDUR'] = transit.act.duration
  candidates[i, 'TRANSITTRAVELDUR'] = transit.duration
  candidates[i, 'TRANSITACTTRAVELDUR'] = transit.duration + transit.act.duration
  
  candidates[i, 'NONTRANSITACTDUR'] = nontransit.act.duration
  candidates[i, 'NONTRANSITTRAVELDUR'] = nontransit.duration
  candidates[i, 'NONTRANSITACTTRAVELDUR'] = nontransit.duration + nontransit.act.duration
  
  candidates[i, 'NONWORKACTDUR'] = nonwork.act.duration
  candidates[i, 'NONWORKTRAVELDUR'] = nonwork.travel.duration
  candidates[i, 'NONWORKACTTRAVELDUR'] = nonwork.act.duration + nonwork.travel.duration
  
  # candidates[i, 'WORKONLYTOUR'] = ifelse(any(ttype == 'WO'), 1, 0)
  # candidates[i, 'WORKNONWORKTOUR'] = ifelse(any(ttype == 'WNW'), 1, 0)
  # candidates[i, 'SIMPLENWTOUR'] = ifelse(any(ttype == 'SNW'), 1, 0)
  # candidates[i, 'COMPLEXNWTOUR'] = ifelse(any(ttype == 'CNW'), 1, 0)
     
  if (candidates[i, "R_SEX"] == 1)
    candidates[i, 'MALE'] = 1
  else if (candidates[i, "R_SEX"] == 2)
    candidates[i, 'MALE'] = 0
  
  if (candidates[i, "R_HISP"] == 1)
    candidates[i, 'HISPANIC'] = 1
  else if (candidates[i, "R_HISP"] == 2)
    candidates[i, 'HISPANIC'] = 0
  
  if (candidates[i, "GT1JBLWK"] == 1)
    candidates[i, 'MULTIJOB'] = 1
  else if (candidates[i, "GT1JBLWK"] == 2)
    candidates[i, 'MULTIJOB'] = 0
  
  if (candidates[i, "WKFTPT"] == 1)
    candidates[i, 'FULLTIME'] = 1
  else if (candidates[i, "WKFTPT"] == 2)
    candidates[i, 'FULLTIME'] = 0
  
  if (candidates[i, "FLEXTIME"] == 1)
    candidates[i, 'FLEXIBLE'] = 1
  else if (candidates[i, "FLEXTIME"] == 2)
    candidates[i, 'FLEXIBLE'] = 0
  
  # INCOME: low, mid, high
  hhincome = candidates[i, "HHFAMINC"]
  if (hhincome > 0) {
    candidates[i, 'LOWINCOME'] = 0
    candidates[i, 'MIDINCOME'] = 0
    candidates[i, 'HIGHINCOME'] = 0
    
    if (hhincome %in% c(1:4)){
      candidates[i, 'LOWINCOME'] = 1
    }
    else if (hhincome %in% c(5:7)){
      candidates[i, 'MIDINCOME'] = 1
    }
    else if (hhincome %in% c(8:11)){
      candidates[i, 'HIGHINCOME'] = 1
    } 
  }
  
  # MSA
  msa = candidates[i, "MSACAT"]
  if (msa %in% c(1:4)) {
    candidates[i, 'MSA1MILWITHRAIL'] = 0
    candidates[i, 'MSA1MILWITHOUTRAIL'] = 0
    candidates[i, 'MSALESS1MIL'] = 0
    candidates[i, 'NOTMSA'] = 0
    
    if (msa == 1)
      candidates[i, 'MSA1MILWITHRAIL'] = 1
    else if (msa == 2)
      candidates[i, 'MSA1MILWITHOUTRAIL'] = 1
    else if (msa == 3)
      candidates[i, 'MSALESS1MIL'] = 1
    else if (msa == 4)
      candidates[i, 'NOTMSA'] = 1
  }
  
  candidates[i, 'PCHILD0TO5'] = ifelse(candidates[i, "NCHILD0TO5"] > 0, 1, 0)
  candidates[i, 'PCHILD6TO17'] = ifelse(candidates[i, "NCHILD6TO17"] > 0, 1, 0)

}

hist(candidates$WORKACTDUR)
table(candidates$WEBUSE17)
table(candidates$HBSimple, useNA = 'ifany')
candidates = candidates[candidates$NTOUR > 0, ]
nrow(candidates)


write.csv(candidates, file = 'dataset.csv')

find_all_tours(30002316, 2)

candidates[candidates$MODENOTRANSIT == 1, c("MODENOTRANSIT", "HOUSEID", "PERSONID")]
table(candidates$MODENOTRANSIT, useNA = 'ifany')

mytrips[, c("TDTRPNUM", "STRTTIME", "ENDTIME", "TRVLCMIN", "TRPTRANS", "WHYFROM","WHYTO", "DWELTIME")]

View(candidates[, c('HHFAMINC', "LOWINCOME", "MIDINCOME", "HIGHINCOME")])

table(candidates$WORKONLYTOUR, useNA = 'ifany')
table(candidates$WORKNONWORKTOUR, useNA = 'ifany')
table(candidates$SIMPLENWTOUR, useNA = 'ifany')
table(candidates$COMPLEXNWTOUR, useNA = 'ifany')
