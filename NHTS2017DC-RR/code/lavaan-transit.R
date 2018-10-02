setwd("F:/UCI/Research/My Papers/Transit")
library(lavaan)
library(digest)
library(polycor)

nz <- function(v){
  v[!is.na(v) & v > 0]
}

datatable = read.csv("dataset.csv")
nrow(datatable)

#datatable[, 'WORKMODE'] = ifelse(datatable$WRKTRANS == 3, 1, 2)
datatable[, 'HASRAIL'] = ifelse(datatable$RAIL == 1, 1, 0)
datatable[, 'ISURBAN'] = ifelse(datatable$URBRUR == 1, 1, 0)
datatable[, 'WEBUSE17'] = ifelse(datatable$WEBUSE17 == 1, 1, 0)

endo.variables = c('HASRAIL', 'HTEEMPDN', 'HBPPOPDN', 'HBRESDN','DISTTOWK17', 
                   'RIDESHARE',	'DELIVER', 	'WEBUSE17', 'PLACE',	'PRICE',	'PTRANS', 'WALK2SAVE',
                   'WORKACTDUR',	'WORKTRAVELDUR', 'NONWORKACTDUR', 'NONWORKTRAVELDUR',
                   'MODEALLTRANSIT', 'MODEMIXED', 'HBSimple', 'HBOnly', 'HBandWB')
 
exo.variables = c('HHSIZE',	'HHVEHCNT',	'LOWINCOME',	'MIDINCOME',	'HIGHINCOME',	
                  'DRVRCNT',	'WRKCOUNT',	'PCHILD0TO5',	'PCHILD6TO17',	'R_AGE',	
                  'MALE',	'HISPANIC',	'MULTIJOB',	'FULLTIME',	'FLEXIBLE')

# Reverse the scale of attitude and technology variables: 1 is low and 5 is high
for (var in c('PLACE',	'PRICE',	'PTRANS', 'WALK2SAVE')) {
  datatable[, var] = ifelse(datatable[, var] > 0, 6 - datatable[, var], NA)
}

for (var in c(endo.variables, exo.variables)) {
  datatable[[var]][datatable[[var]] < 0] <- NA
  if (sum(is.na(datatable[[var]])) > 0)
    cat(var, 'NA', sum(is.na(datatable[[var]])), 'NEG', sum(datatable[[var]] < 0, na.rm = T), '\n')
}

# Remove NA rows
datatable <- datatable[complete.cases(datatable), ]
nrow(datatable)


for (var in c(endo.variables, exo.variables)) {
  cat(var, mean(datatable[[var]]), sd(datatable[[var]]), sum(datatable[[var]]), '\n')
}
# Remove outliers: take only 99-percentile values
# for (x in c('work_outhome', 'work_inhome', 'work_travel',
#             'nw_beforework' , 'nw_afterwork',  
#             'nw_travel_beforework' , 'nw_travel_afterwork',
#             'nw_waytowork', 'nw_duringwork', 'nw_waytohome',
#             'nw_travel_waytowork', 'nw_travel_duringwork', 'nw_travel_waytohome')) {
#   maxvalue = quantile(datatable$work_outhome, probs = c(0.99))[[1]]
#   datatable = datatable[datatable$work_outhome <= maxvalue, ]
#   cat(x, nrow(datatable), '\n')
# }


# Taking logs of all durations
for (col in c('WORKACTDUR',	'WORKTRAVELDUR', 	'TRANSITACTDUR',	'TRANSITTRAVELDUR', 'DISTTOWK17',
              'NONTRANSITACTDUR',	'NONTRANSITTRAVELDUR',	'WORKACTTRAVELDUR',	'NONWORKACTDUR', 'NONWORKTRAVELDUR', 'NONWORKACTTRAVELDUR',
              'TRANSITACTTRAVELDUR',	'NONTRANSITACTTRAVELDUR', 'HTEEMPDN', 'HBPPOPDN', 'HBRESDN')){ 
  datatable[, col] <- log(1 + datatable[, col])
}


# Run SEM model
{
  sheet = 47
  #system2(paste('python findpaths.py', sheet))
  model <- readLines(paste('sem-model-', sheet, '.txt', sep = ''))
  digest(model)
    
  cat('Running SEM, dataset size', nrow(datatable), '\n')
  
  fit = sem(model, 
            data = datatable,
            ordered = c('HBSimple', 'HBOnly', 'HBandWB'), #'MODEALLTRANSIT', 'MODEMIXED'),
            verbose = TRUE
            )
  
  fitmeasures = fitmeasures(fit, fit.measures = c('ntotal', 'chisq', 'df', 'pvalue',
                                                                              'rmsea', 'rmsea.pvalue', 'rmsea.ci.lower', 'rmsea.ci.upper',
                                                                              'cfi','tli', 'srmr'))
  cat('Done!\n')
  print(fitmeasures)
}


nrow(datatable)
table(datatable$HBandWB, useNA = 'ifany')

# Find coefficients 
{
  params = parameterestimates(fit)
  tmp = params[!is.na(params$pvalue) & params$op == '~', c('lhs', 'op', 'rhs', 'est', 'pvalue')]
  cat('variable', endo.variables, '\n')
  for(x in c(exo.variables, endo.variables)) {
    cat(x, ' ')
    for (y in endo.variables){
      filter = tmp$lhs == y & tmp$rhs == x & tmp$op == '~'
      stopifnot(sum(filter) <= 1)
      if (sum(filter) == 1) {
        param.value = tmp[filter, c("est")]
        pvalue = tmp[filter, c("pvalue")]
        starmark = if (pvalue <= 0.05) '*' else if (pvalue <= 0.10) '**' else '---'
        if (starmark != '---')
          param.value = sprintf('%0.3f%s', param.value, starmark)
        else
          param.value = starmark
      }
      else 
        param.value = NA
      cat(param.value, ' ')
    }
    cat('\n')
  }
}


# Compute correlation table
cor.table = data.frame()
ordered.endo.variables = c('HASRAIL', 'WEBUSE17', 'SPHONE',	'TAB', 	'PC',	'PLACE',	
                           'PRICE',	'PTRANS', 'WALK2SAVE','BIKE2SAVE',
                           'HBSimple', 'HBOnly', 'HBandWB', 'MODEALLTRANSIT', 'MODEMIXED')

ordered.exo.variables = c('LOWINCOME',	'MIDINCOME',	'HIGHINCOME',	
                  'PCHILD0TO5',	'PCHILD6TO17', 'MALE',	'HISPANIC',	
                  'MULTIJOB',	'FULLTIME',	'FLEXIBLE')

for (vx in c(endo.variables, exo.variables)){
  x = datatable[[vx]]
  if (vx %in% ordered.endo.variables)
    x = ordered(x)
  for(vy in c(endo.variables, exo.variables)){
    y = datatable[[vy]]
    if (vy %in% c(ordered.endo.variables, ordered.exo.variables))
      y = ordered(y)
    
    if (vx %in% ordered.endo.variables)
      cor.table[vx, vy] = polychor(x, y)
    else if (vy %in% c(ordered.endo.variables, ordered.exo.variables))
      cor.table[vx, vy] = polychor(y, x)
    else 
      cor.table[vx, vy] = cor(x, y)
  }
}

cor.table
write.csv(cor.table, file = 'cortable.csv')





# Summary statistics
dataset = read.csv('dataset.csv')
nrow(dataset)

dataset[, 'HASRAIL'] = ifelse(dataset$RAIL == 1, 1, 0)
dataset[, 'ISURBAN'] = ifelse(dataset$URBRUR == 1, 1, 0)
datatable[, 'WEBUSE17'] = ifelse(datatable$WEBUSE17 == 1, 1, 0)

# Summary statistics (endo + exo)
stat.numeric.variables = c('HHSIZE',	'HHVEHCNT', 'DRVRCNT',	'WRKCOUNT',	'R_AGE',	
                           'RIDESHARE',	'DELIVER', 'DISTTTOWK17',	
                           'HTEEMPDN', 'HBPPOPDN', 'HBRESDN',
                           'WORKACTTRAVELDUR',	'TRANSITACTTRAVELDUR',	'NONTRANSITACTTRAVELDUR',
                           'NONWORKACTDUR', 'NONWORKTRAVELDUR', 'NONWORKACTTRAVELDUR', 'WORKACTDUR',	'WORKTRAVELDUR', 'NONWORKACTDUR', 'NONWORKTRAVELDUR')

stat.ordinal.variables = c('HASRAIL', 'ISURBAN', 'WEBUSE17', 'PLACE',	'PRICE',	'PTRANS', 'WALK2SAVE',
                           'LOWINCOME',	'MIDINCOME',	'HIGHINCOME',	'PCHILD0TO5',	'PCHILD6TO17',
                           'MALE',	'HISPANIC',	'MULTIJOB',	'FULLTIME',	'FLEXIBLE',
                           'HBSimple', 'HBOnly', 'HBandWB', 'MODEALLTRANSIT', 'MODEMIXED')

for (var in c(stat.numeric.variables, stat.ordinal.variables)) {
    cat(var, '\n')
    dataset[[var]][!is.na(dataset[[var]]) & dataset[[var]] < 0] <- NA
}

nrow(dataset)
dataset = dataset[complete.cases(dataset), ]

nrow(dataset)


for (x in stat.numeric.variables) {
  y = nz(dataset[[x]])
  cat(x, length(y), mean(y), sd(y), '\n')
}

for (x in stat.ordinal.variables) {
  cat(x, '\n')
  print(table(dataset[[x]]))
}

# Fraction of people made NW tours for different purposes
people.per.purpose = list()
participation = list()
all.tours = data.frame()

for (tt in c('HBSimple', 'HBOnly', 'HBandWB', 'OTHER')) {
  participation[[tt]] = c(0)
  people.per.purpose[[tt]] = list()
  for (p in c(1, 10, 20, 30, 40, 50, 60, 70, 80, 97)){
    people.per.purpose[[tt]][[p]] = c(0)
  }
}

ntour = 1
for (i in 1:nrow(dataset)) {
  houseid = dataset[i, "HOUSEID"]
  personid = dataset[i, "PERSONID"]
  uniqueid = paste(houseid, personid, sep = '_')
  #cat(uniqueid, ' ')
  mytours = find_all_tours(houseid, personid)
  #cat (uniqueid, 'TOURS', length(mytours), '\n')
  for (t in mytours) {
    all.tours[ntour, 'UNIQUEID'] = uniqueid
    all.tours[ntour, 'TTYPE'] = t$type
    all.tours[ntour, 'ACTSTRING'] = paste(t$touract, collapse = '+')
    all.tours[ntour, 'TRIPMODE'] = paste(t$trip.mode.pertour, collapse = '+')
    all.tours[ntour, 'TRIPPURPOSE'] = paste(t$trip.purposes.pertour, collapse = '+')
    ntour = ntour + 1
  
    participation[[t$type]] = c(participation[[t$type]], uniqueid)
    for (p in t$trip.purposes.pertour){
      people.per.purpose[[t$type]][[p]] = c(people.per.purpose[[t$type]][[p]], uniqueid)
    }
  }
}

NN = nrow(dataset)
for(tt in c('HBSimple', 'HBOnly', 'HBandWB')) {
  N = length(unique(participation[[tt]][-1]))
  for(p in c(1, 10, 20, 30, 40, 50, 60, 70, 80, 97)) {
    cat (tt, p, NN, N, 100 * length(unique(people.per.purpose[[tt]][[p]][-1])) / N, '\n')
  }
}



# Process on work tours
all.work.tours = all.tours[all.tours$TTYPE != 'OTHER', ]

head(all.work.tours)


sort(tail(sort(table(all.work.tours$ACTSTRING))), decreasing = T)

N = nrow(all.work.tours)
N
tour.patterns = c('H+W+H', 'H+W+N+H',	'H+W+N+W+H', 'H+N+W+H', 'H+W+N+W+N+H', 'H+W+N+N+H', 'H+N+W+N+H')

for (tp in tour.patterns) {
  tour.takers = c()
  tours = all.work.tours[all.work.tours$ACTSTRING == tp, ]
  mode.count = list()
  for (m in 1:5)
    mode.count[[m]] = list(PT=0, W=0, C=0, T=0, O=0)
  
  purpose.count = list()
  for(n in 1:2) {
    purpose.count[[n]] = list()
    for (p in c(20, 30, 40, 50, 70, 80, 97))
      purpose.count[[n]][[p]] = 0
  }
  
  for (i in 1:nrow(tours)) {
    tour.takers = c(tour.takers, tours[i, 'UNIQUEID'])
    trip.modes = strsplit(tours[i, 'TRIPMODE'], '\\+')[[1]]
    ntrip = 1 
    m = 1
    while (m <= length(trip.modes)) {
      trip.mode = trip.modes[m]
      next.mode = ifelse(m < length(trip.modes), trip.modes[m + 1], '.')
      
      if (next.mode == '->') {
        while(next.mode == '->') {
          mode.count[[ntrip]][[trip.mode]] = mode.count[[ntrip]][[trip.mode]] + 1
          m = m + 2
          trip.mode = trip.modes[m]
          next.mode = ifelse(m < length(trip.modes), trip.modes[m + 1], '.')
        }
      }
      
      mode.count[[ntrip]][[trip.mode]] = mode.count[[ntrip]][[trip.mode]] + 1
      ntrip = ntrip + 1
      m = m + 1
    }
    
    if (!is.na(tours[i, 'TRIPPURPOSE']) & nchar(tours[i, 'TRIPPURPOSE']) > 0) {
      N.purposes = as.numeric(strsplit(tours[i, 'TRIPPURPOSE'], '\\+')[[1]])
      for (n in 1:length(N.purposes)) {
        purpose.count[[n]][[N.purposes[n]]] = purpose.count[[n]][[N.purposes[n]]] + 1
      }
    }
  }
  
  cat('TOUR pattern,', tp, '\n')
  tn = nrow(tours)
  cat('#Tours', tn, 100 *tn / N, '\n')
  cat('#People', length(unique(tour.takers)), 100*length(unique(tour.takers)) / nrow(dataset), '\n')
  
  for(k in 1:length(unlist(gregexpr('\\+', tp))))
    for(m in names(mode.count[[k]]))
      cat(m, 100*mode.count[[k]][[m]]/tn, '\n')
  
  K = length(unlist(gregexpr('N', tp)))
  if (K >= 1) {
    for(n in 1:K){
      for (p in c(20, 30, 40, 50, 70, 80, 97))
        cat(p, 100*purpose.count[[n]][[p]]/tn, '\n')
    }
  }
} 

nrow(all.work.tours)
all.work.tours[sapply(all.tours$TRIPMODE, function(x){any(strsplit(x, '\\+')[[1]] == "\\->")}), "TRIPMODE"]



write.csv(all.work.tours, 'all.work.tours.csv')

#result = lm(log(1+work_outhome)  ~  + xnchild_0to5  + xnchild_6to10  + xnchild_11to18  + xbalance + xnonmetro + xhh_size  + xemp_type  + xworker_type  + xhhown  + xhhincome_low  + xhhincome_high  + xmultijobs  + xgender  + xage  + xmarried_spemp + xmarried_spunemp + xwinter, data = datatable[datatable$year == 3, ])
summary(fit)


options(max.print = 5000)
#sink('sem-output-model-10.txt')
summary(fit)

fitmeasures(fit)
fitmeasures(fit, fit.measures = c('ntotal', 'chisq', 'df', 'pvalue','rmsea', 'rmsea.pvalue', 'rmsea.ci.lower', 'rmsea.ci.upper',
                                  'cfi','tli', 'srmr'))
#sink()

semPaths(fit)

vartable(fit)
hist(datatable$xage)

sum(datatable$xgender == 1 & datatable$year ==1 & datatable$sw == 1)
sum(datatable$xgender == 0 & datatable$year ==1 & datatable$sw == 1)

sum(datatable$xgender == 1 & datatable$year ==1 & datatable$cnw == 1)
sum(datatable$xgender == 0 & datatable$year ==1 & datatable$cnw == 1)

exp(mean(datatable[datatable$year == 1 & datatable$xprincipal & datatable$work_outhome > 0, "work_outhome"]))
exp(mean(datatable[datatable$year == 1 & datatable$xbalance & datatable$work_outhome > 0, "work_outhome"]))
exp(mean(datatable[datatable$year == 1 & datatable$xnonmetro & datatable$work_outhome > 0, "work_outhome"]))

exp(mean(datatable[datatable$year == 1 & datatable$xprincipal & datatable$work_inhome > 0, "work_inhome"]))
exp(mean(datatable[datatable$year == 1 & datatable$xbalance & datatable$work_inhome > 0, "work_inhome"]))
exp(mean(datatable[datatable$year == 1 & datatable$xnonmetro & datatable$work_inhome > 0, "work_inhome"]))

for(x in c('xprincipal', 'xbalance', 'xnonmetro')){
  n = sum(datatable$year == 2 & datatable[[x]] == 1)
  p = sum(datatable$year == 2 & datatable[[x]] == 1 & datatable$work_outhome > 0)
  cat (x, p*100/n, '\n')
}

mean(exp(datatable$work_outhome[datatable$work_outhome > 0]))
hist(exp(datatable$work_inhome))


fit = fit.unconstrained
params = parameterestimates(fit)
tmp = params[!is.na(params$pvalue) & params$pvalue <= 0.1 & params$op == '~', c('lhs', 'op', 'rhs', 'group', 'est', 'se', 'pvalue')]
head(tmp[tmp$pvalue > 0, ])
2*pnorm(-abs(4.152)/2.038)
2*pnorm(-abs(-5.018)/2.790)
2*pnorm(-abs(-1.305)/0.647)

nrow(tmp)
sum(tmp$group == 1)
sum(tmp$group == 2)
sum(tmp$group == 3)

g1 = 2
g2 = 3

{
  g1params = tmp[tmp$group == g1, ]
  g2params = tmp[tmp$group == g2, ]
  
  for (i in 1:nrow(g1params)) {
    y = g1params[i, 'lhs']
    x = g1params[i, 'rhs']
    beta1 = g1params[i, 'est']
    se1 = g1params[i, 'se']
    if (sum(g2params$lhs == y & g2params$rhs == x) > 0) {
      beta2 = g2params[g2params$lhs == y & g2params$rhs == x, 'est']
      se2 = g2params[g2params$lhs == y & g2params$rhs == x, 'se']
      Z = (beta1 - beta2) / sqrt(se1**2 + se2**2)
      pvalue = 2*pnorm(-abs(Z))
      cat(y, x, beta1, beta2, Z, pvalue, '\n')
    }
    else 
      cat(y, x, beta1, 0.0, 0.0, 0.0, '\n')
  }
  
  for (i in 1:nrow(g2params)) {
    y = g2params[i, 'lhs']
    x = g2params[i, 'rhs']
    beta2 = g2params[i, 'est']
    se2 = g2params[i, 'se']
    if (sum(g1params$lhs == y & g1params$rhs == x) == 0) 
      cat(y, x, 0.0, beta2, 0.0, 0.0, '\n')
  }
}


{
  sig.params = params[!is.na(params$pvalue) & params$pvalue <= 0.1 & params$op == '~', c('lhs', 'op', 'rhs', 'group', 'est', 'se', 'pvalue')]  
  g1params = sig.params[sig.params$group == 1, ]
  g2params = sig.params[sig.params$group == 2, ]
  g3params = sig.params[sig.params$group == 3, ]
  for (y in endo.variables)
    for(x in c(endo.variables, exo.variables))
      if (x != y & sum(g2params$lhs == y & g2params$rhs == x) > 0) {
        beta2 = g2params[g2params$lhs == y & g2params$rhs == x, c('est')]
        se2 = g2params[g2params$lhs == y & g2params$rhs == x, c('se')]
        
        beta1 = beta3 = 0
        pvalue1 = pvalue3 = 2
        
        if (sum(g1params$lhs == y & g1params$rhs == x) > 0)  {
          beta1 = g1params[g1params$lhs == y & g1params$rhs == x, c('est')]
          se1 = g1params[g1params$lhs == y & g1params$rhs == x, c('se')]
          Z1 = (beta2 - beta1) / sqrt(se2**2 + se1**2)
          pvalue1 = 2*pnorm(-abs(Z1))
        }
          
        if (sum(g3params$lhs == y & g3params$rhs == x) > 0) {
          beta3 = g3params[g3params$lhs == y & g3params$rhs == x, c('est')]
          se3 = g3params[g3params$lhs == y & g3params$rhs == x, c('se')]
          Z3 = (beta2 - beta3) / sqrt(se2**2 + se3**2)
          pvalue3 = 2*pnorm(-abs(Z3))
        }
        
        s = sprintf('%s %s %.3f%s %.3f %.3f%s %.3f %.3f', y, x, 
                    beta1, if(pvalue1 <= 0.1) '*' else '', 
                    beta2, 
                    beta3, if(pvalue3 <= 0.1) '*' else '', pvalue1, pvalue3)
        cat(s, '\n')
      }
}

params = parameterestimates(fit)
head(params)


# Total effects 
{
  teffects = list()
  fitmeasures(fit, fit.measures = c('ntotal', 'chisq', 'df', 'pvalue','rmsea', 'rmsea.pvalue', 'rmsea.ci.lower', 'rmsea.ci.upper',
                                    'cfi','tli', 'srmr'))
  params = parameterestimates(fit)
  teffects = params[grepl('t_', params$lhs), c('lhs', 'est', 'se', 'pvalue')]
  
  cat('variable', endo.variables, '\n')
  for(v1 in c(exo.variables, endo.variables)) {
    cat(v1, ' ')
    tmp = teffects
    for (v2 in endo.variables){
      vpair = paste('t_', v1, '__', v2, sep = '')
      if (v1 != v2 & vpair %in% tmp$lhs){
        param.value = tmp[tmp$lhs == vpair, c("est")]
        pvalue = tmp[tmp$lhs == vpair, c("pvalue")]
        starmark = if (pvalue <= 0.05) '*' else if (pvalue <= 0.10) '**' else '---'
        if (starmark != '---')
          param.value = sprintf('%0.3f%s', param.value, starmark)
        else
          param.value = starmark
      }
      else 
        param.value = NA
      
      cat(param.value, ' ')
    }
    cat('\n')
  }
}

# Total effects difference
{
  g1params = teffects[[1]]
  g2params = teffects[[2]]
  g3params = teffects[[3]]
  g1params = g1params[g1params$pvalue <= 0.1, ]
  g2params = g2params[g2params$pvalue <= 0.1, ]
  g3params = g3params[g3params$pvalue <= 0.1, ]
  
  for (y in endo.variables)
    for(x in c(endo.variables, exo.variables)) {
      vpair = paste('t_', x, '__', y, sep = '')
      if (x != y & vpair %in% g2params$lhs) {
        beta2 = g2params[g2params$lhs == vpair , c('est')]
        se2 = g2params[g2params$lhs == vpair, c('se')]
        
        beta1 = beta3 = 0
        pvalue1 = pvalue3 = 2
        
        if (sum(g1params$lhs == vpair) > 0)  {
          beta1 = g1params[g1params$lhs == vpair, c('est')]
          se1 = g1params[g1params$lhs == vpair, c('se')]
          Z1 = (beta2 - beta1) / sqrt(se2**2 + se1**2)
          pvalue1 = 2*pnorm(-abs(Z1))
        }
        
        if (sum(g3params$lhs == vpair) > 0) {
          beta3 = g3params[g3params$lhs == vpair, c('est')]
          se3 = g3params[g3params$lhs == vpair, c('se')]
          Z3 = (beta2 - beta3) / sqrt(se2**2 + se3**2)
          pvalue3 = 2*pnorm(-abs(Z3))
        }
        
        s = sprintf('%s %s %.3f%s %.3f %.3f%s %.3f %.3f', y, x, 
                    beta1, if(pvalue1 <= 0.1) '*' else '', 
                    beta2, 
                    beta3, if(pvalue3 <= 0.1) '*' else '', pvalue1, pvalue3)
        cat(s, '\n')
      }
    }
}




#pchisq(q=11347.675-10505.879, df = 1052.000-450.000, lower.tail = F)

boxplot(datatable$work_inhome, datatable$work_outhome)
hist(datatable$work_outhome[datatable$work_outhome > 0 & datatable$work_outhome < 730])
hist(datatable$work_inhome[datatable$work_inhome > 0])

mean(datatable$work_inhome)
sd(datatable$work_inhome)

quantile(datatable$work_outhome, probs = c(0.99))[[1]]
quantile(datatable$work_inhome, probs = c(0, 0.5, 0.75, 0.90, 0.99))

datatable[datatable$work_outhome> 1300, "fullactstr"]


#options(max.print = 20000)
#sink('sem-output.txt')
#m = modindices(fit)
#m[, c("lhs", 'op', "rhs", "mi", "group", "block")]
#sink()

fit = fit.unconstrained
m = modindices(fit)
tmp = m[m$mi > 1e4 & m$op == '~', c("lhs", 'op', "rhs", "mi", "group", "block")]
tmp
#tmp[order(tmp$lhs, tmp$rhs), ]


cortable = data.frame()
for (x in c('xweekday', 'xfall', 'xwinter', 'xsummer', 'xspring'))
for (y in endo.variables)
cortable[x, y] = cor(datatable[[x]], datatable[[y]])

cortable = data.frame()
for (x in c('xweekday'))
for (y in exo.variables)
cortable[y, x] = cor(datatable[[x]], datatable[[y]])

cortable


fitted(fit)

boxplot(semdataset$work_outhome)

head(semdataset[semdataset$work_outhome > 1300, c("tour_types", "fullactstr")])

install.packages('polycor')
library(polycor)

x = c(1, 0, 1, 0, 1, 0, 1, 1, 1)
y = c(5, 4, 3, 4, 1, 2, 4, 5, 9)
z = c(45, 24, 5, 5, 67, 23, 66, 67, 89)
x = ordered(x)
polychor(x, y)
polychor(y, x)

cor.test(x, y)
cor(y, z)


ordered.endo.variables = c('sw', 'cw', 'snw', 'cnw')
ordered.exo.variables = c('xprincipal', 'xbalance', 'xnonmetro', 'xemp_type', 	
                  'xhhown', 'xhhincome_mid', 'xhhincome_low', 'xhhincome_high', 'xhispanic', 	
                  'xmultijobs', 'xgender', 'xmarried_spemp', 'xmarried_spunemp','xsingle',	
                  'xfall', 'xwinter', 'xspring', 'xsummer')


cor.table = data.frame()
for (vx in endo.variables){
  x = datatable[[vx]]
  if (vx %in% ordered.endo.variables)
    x = ordered(x)
  for(vy in c(endo.variables, exo.variables)){
    y = datatable[[vy]]
    if (vy %in% c(ordered.endo.variables, ordered.exo.variables))
      y = ordered(y)
      
    if (vx %in% ordered.endo.variables)
      cor.table[vx, vy] = polychor(x, y)
    else if (vy %in% c(ordered.endo.variables, ordered.exo.variables))
      cor.table[vx, vy] = polychor(y, x)
    else 
      cor.table[vx, vy] = cor(x, y)
  }
}


cor.table

#summary stats-2
summary.stats = data.frame()
years = c(2006, 2009, 2012)
for (x in c('xnchild_0to5', 'xnchild_6to10', 'xnchild_11to18', 
            'xprincipal', 'xbalance', 'xnonmetro', 
            'xhh_size', 'xemp_type','xhhown', 
            'xhhincome_low', 'xhhincome_mid', 'xhhincome_high', 
            'xhispanic', 'xmultijobs', 'xgender', 'xage', 
            'xmarried_spemp', 'xmarried_spunemp',	'xsingle',
            'xfall', 'xwinter', 'xspring')
) 
  for(yi in 1:3){
    year = years[yi]
    summary.stats[x, paste(year, 'mean', sep='-')] = mean(datatable[datatable$year == yi, x], na.rm = T)
    summary.stats[x, paste(year, 'sd', sep='-')] = sd(datatable[datatable$year == yi, x], na.rm = T)
    #summary.stats[x, paste(year, 'min', sep='-')] = min(datatable[datatable$year == yi, x], na.rm = T)
    #summary.stats[x, paste(year, 'max', sep='-')] = min(datatable[datatable$year == yi, x], na.rm = T)    
  }


for (x in endo.variables)
  for (yi in 1:3) {
    year = years[yi]
    summary.stats[x, paste(year, 'cases>0', sep='-')] = 100*length(nz(datatable[datatable$year == yi, x]))/sum(datatable$year==yi)
    summary.stats[x, paste(year, 'mean', sep='-')] = mean(nz(datatable[datatable$year == yi, x]), na.rm = T)
    summary.stats[x, paste(year, 'sd', sep='-')] = sd(nz(datatable[datatable$year == yi, x]), na.rm = T)
    #summary.stats[x, paste(year, 'min', sep='-')] = min(datatable[datatable$year == yi, x], na.rm = T)
    #summary.stats[x, paste(year, 'max', sep='-')] = min(datatable[datatable$year == yi, x], na.rm = T)    
  }

summary.stats
write.csv(summary.stats, 'summary-2.csv')
table(datatable$xhhown)


# Summary statistics - 3
nrow(datatable)

waytowork.nonwork.t1codes = list()
waytohome.nonwork.t1codes = list()
during.nonwork.t1codes = list()
beforework.nonwork.t1codes = list()
afterwork.nonwork.t1codes = list()

cw.tour.counts = list()
nw.tour.counts = list()
nw.durations = list()

years = c(2006, 2009, 2012)

for (yi in 1:3) {
  year = years[yi]
  beforework.t1codes = c()
  afterwork.t1codes = c()
  waytowork.t1codes = c()
  waytohome.t1codes = c()
  during.t1codes = c()
  
  cw.tour.counts[[year]] = list(waytowork=list(), duringwork=list(),waytohome=list())
  nw.tour.counts[[year]] = list(beforework=list(), afterwork=list())
  nw.durations[[year]] = list(beforework=list(), waytowork=list(), duringwork=list(),waytohome=list(),afterwork=list())
  
  for (part in c('waytowork', 'duringwork', 'waytohome'))
    for (act in c(1:16, 50))
      cw.tour.counts[[year]][[part]][[act]] = c(0)
  
  for (part in c('beforework', 'afterwork'))
    for (act in c(1:16, 50))
      nw.tour.counts[[year]][[part]][[act]] = c(0)
  
  for (part in c('beforework', 'waytowork', 'duringwork', 'waytohome', 'afterwork'))
    for (act in c(1:16, 50))
      nw.durations[[year]][[part]][[act]] = c(0)
  
  peryeardata = datatable[datatable$year == yi, ]
  for (i in 1:nrow(peryeardata)){
    tucaseid = peryeardata[i, "tucaseid"]
    fullactstr = peryeardata[i, "fullactstr"]
    fullactstr = levels(fullactstr)[fullactstr]
    values <- strsplit(fullactstr, ' ')[[1]]
    wheres <- values[seq(1, length(values), 3)]
    t1codes = values[seq(2, length(values), 3)]
    t1codes = as.numeric(t1codes)
    durations = values[seq(3, length(values), 3)]
    durations = as.numeric(durations)
    
    tours = extract_tours_with_details_v3(fullactstr)
    ttypes = paste(sapply(tours, function(v){v$type}), collapse = '+')
    
    noWorkTour = FALSE
    if (any(grepl('SW', ttypes), grepl('CW', ttypes))) {
      noWorkTour = FALSE
    } else {
      noWorkTour = TRUE
      Wdurations = durations * sapply(1:length(wheres), function(i){wheres[i] == 'H' & t1codes[i] == 5})
      longestWpos = which(Wdurations == max(Wdurations))[1]
    }
    
    # In home nonwork activities (before work and after work)
    if (noWorkTour)
      workpos = longestWpos
    else {
      workpos = which(wheres == 'W')[1]
    }
    
    activity.count = 0
    for (t in tours) {
      if (t$type == 'SNW' | t$type == 'CNW') {
        for (j in 1:length(t$t1codes)){ 
          act.code = t$t1codes[j]
          duration = t$times[j]
          if (t$wheres[j] == 'N'){
            #Beforework
            if (workpos < activity.count + j) {
              beforework.t1codes = c(beforework.t1codes, act.code)
              nw.tour.counts[[year]]$beforework[[act.code]] = c(nw.tour.counts[[year]]$beforework[[act.code]], tucaseid)
              nw.durations[[year]]$beforework[[act.code]] = c(nw.durations[[year]]$beforework[[act.code]], duration)
            }
            else { # After work
              afterwork.t1codes = c(afterwork.t1codes, act.code)
              nw.tour.counts[[year]]$afterwork[[act.code]] = c(nw.tour.counts[[year]]$afterwork[[act.code]], tucaseid)
              nw.durations[[year]]$afterwork[[act.code]] = c(nw.durations[[year]]$afterwork[[act.code]], duration)
            }
          }
        }
        activity.count = activity.count + length(t$t1codes)
      }
      if (t$type == 'CW') {
        Wpos = gregexpr('W', t$tour)[[1]]
        Npos = gregexpr('N', t$tour)[[1]]
        firstWpos = Wpos[1]; lastWpos = rev(Wpos)[1]
        firstNpos = Npos[1]; lastNpos = rev(Npos)[1]
        
        for (j in 1:nchar(t$tour)) {
          where = t$wheres[j]
          act.code = t$t1codes[j]
          duration = t$times[j]
          waytowork = (j < firstWpos)
          duringwork = (j > firstWpos & j <= lastWpos)
          waytohome = (j > lastWpos)
          #cat(year, t$tour, j, waytowork, duringwork, waytohome, '\n')
          
          if (where == 'N' & act.code > 0) {
            if (waytowork){
              waytowork.t1codes = c(waytowork.t1codes, act.code)
              cw.tour.counts[[year]]$waytowork[[act.code]] = c(cw.tour.counts[[year]]$waytowork[[act.code]], tucaseid)
              nw.durations[[year]]$waytowork[[act.code]] = c(nw.durations[[year]]$waytowork[[act.code]], duration)
            }
            else if (duringwork){
              during.t1codes = c(during.t1codes, act.code)
              cw.tour.counts[[year]]$duringwork[[act.code]] = c(cw.tour.counts[[year]]$duringwork[[act.code]], tucaseid)
              nw.durations[[year]]$duringwork[[act.code]] = c(nw.durations[[year]]$duringwork[[act.code]], duration)
            } 
            else if (waytohome){
              waytohome.t1codes = c(waytohome.t1codes, act.code)
              cw.tour.counts[[year]]$waytohome[[act.code]] = c(cw.tour.counts[[year]]$waytohome[[act.code]], tucaseid)
              nw.durations[[year]]$waytohome[[act.code]] = c(nw.durations[[year]]$waytohome[[act.code]], duration)        
            }
          }
        }
      }
    }
  }
  
  beforework.nonwork.t1codes[[year]] = beforework.t1codes
  afterwork.nonwork.t1codes[[year]] = afterwork.t1codes
  
  waytowork.nonwork.t1codes[[year]] = waytowork.t1codes
  during.nonwork.t1codes[[year]] = during.t1codes
  waytohome.nonwork.t1codes[[year]] = waytohome.t1codes
  
  for (part in c('waytowork', 'duringwork', 'waytohome')){
    cw.tour.counts[[year]][[part]][['NTOUR']] = c()
    for (act in c(1:16)) {
      cw.tour.counts[[year]][[part]][['NTOUR']] = c(cw.tour.counts[[year]][[part]][['NTOUR']], cw.tour.counts[[year]][[part]][[act]])
      cw.tour.counts[[year]][[part]][[act]] = length(unique(cw.tour.counts[[year]][[part]][[act]])) - 1
    }
    cw.tour.counts[[year]][[part]][['NTOUR']] = length(unique((cw.tour.counts[[year]][[part]][['NTOUR']]))) - 1
  }

  for (part in c('beforework', 'afterwork')){
    nw.tour.counts[[year]][[part]][['NTOUR']] = c()
    for (act in c(1:16)) {
      nw.tour.counts[[year]][[part]][['NTOUR']] = c(nw.tour.counts[[year]][[part]][['NTOUR']], nw.tour.counts[[year]][[part]][[act]])
      nw.tour.counts[[year]][[part]][[act]] = length(unique(nw.tour.counts[[year]][[part]][[act]])) - 1
    }
    nw.tour.counts[[year]][[part]][['NTOUR']] = length(unique((nw.tour.counts[[year]][[part]][['NTOUR']]))) - 1
  }
}


tucaseid = cw.tour.counts[[2009]][['waytowork']][[12]][10]
nw.durations[[2009]][['waytowork']][[12]][10]

act <- read.csv(filename('act'))
tucaseid
act[act$TUCASEID == tucaseid, c("TRCODEP", "TEWHERE", "TUSTARTTIM", "TUACTDUR")]
datatable[datatable$tucaseid == tucaseid, "tour_types"]

for (year in years){
  print(year)
  print(table(waytowork.nonwork.t1codes[[year]]))
  print(table(during.nonwork.t1codes[[year]]))
  print(table(waytohome.nonwork.t1codes[[year]]))
  print(table(beforework.nonwork.t1codes[[year]]))
  print(table(afterwork.nonwork.t1codes[[year]]))
}


var = waytohome.nonwork.t1codes
for (i in 1:16) {
  n1 = sum(var[[2006]] == i)
  n2 = sum(var[[2009]] == i)
  n3 = sum(var[[2012]] == i)
  cat(i, n1, n2, n3, '\n')
}

# Participation ratios
for (act in c(1:16)) {
  cat(act, ' ')
  for (part in c('beforework')) {
    for (year in c(2006, 2009, 2012)){
      v = nw.tour.counts[[year]][[part]][[act]]
      n = nw.tour.counts[[year]][[part]][['NTOUR']]
      cat(100*v/n, ' ')
    }
  }
  for (part in c('waytowork', 'duringwork', 'waytohome')) {
    for (year in c(2006, 2009, 2012)){
      v = cw.tour.counts[[year]][[part]][[act]]
      n = cw.tour.counts[[year]][[part]][['NTOUR']]
      cat(100*v/n, ' ')
    }
  }
  for (part in c('afterwork')) {
    for (year in c(2006, 2009, 2012)){
      v = nw.tour.counts[[year]][[part]][[act]]
      n = nw.tour.counts[[year]][[part]][['NTOUR']]
      cat(100*v/n, ' ')
    }
  }
  cat('\n')
}

# Average durations
for (act in c(1:16)) {
  cat(act, ' ')
  for (part in c('beforework')) {
    for (year in c(2006, 2009, 2012)){
      v = sum(nz(nw.durations[[year]][[part]][[act]]))
      n = nw.tour.counts[[year]][[part]][[act]]
      cat(v/n, ' ')
    }
  }
  for (part in c('waytowork', 'duringwork', 'waytohome')) {
    for (year in c(2006, 2009, 2012)){
      v = sum(nz(nw.durations[[year]][[part]][[act]]))
      n = cw.tour.counts[[year]][[part]][[act]]
      cat(v/n, ' ')
    }
  }
  for (part in c('afterwork')) {
    for (year in c(2006, 2009, 2012)){
      v = sum(nz(nw.durations[[year]][[part]][[act]]))
      n = nw.tour.counts[[year]][[part]][[act]]
      cat(v/n, ' ')
    }
  }
  cat('\n')
}


nperson = list()
for (yi in 1:3) {
  nperson[[years[yi]]] = sum(datatable$year == yi)
}

for (act in c('NTOUR')) {
  cat(act, ' ')
  for (part in c('beforework')) {
    for (year in c(2006, 2009, 2012)){
      v = nw.tour.counts[[year]][[part]][['NTOUR']]
      n = nperson[[year]]
      cat(100*v/n, ' ')
    }
  }
  for (part in c('waytowork', 'duringwork', 'waytohome')) {
    for (year in c(2006, 2009, 2012)){
      v = cw.tour.counts[[year]][[part]][['NTOUR']]
      n = nperson[[year]]
      cat(100*v/n, ' ')
    }
  }
  for (part in c('afterwork')) {
    for (year in c(2006, 2009, 2012)){
      v = nw.tour.counts[[year]][[part]][['NTOUR']]
      n = nperson[[year]]
      cat(100*v/n, ' ')
    }
  }
  cat('\n')
}



## Time use difference
datatable = read.csv("semdataset.csv")
# Remove outliers: take only 99-percentile values
for (x in c('work_outhome', 'work_inhome', 'work_travel',
            'nw_beforework' , 'nw_afterwork',  
            'nw_travel_beforework' , 'nw_travel_afterwork',
            'nw_waytowork', 'nw_duringwork', 'nw_waytohome',
            'nw_travel_waytowork', 'nw_travel_duringwork', 'nw_travel_waytohome')) {
  maxvalue = quantile(datatable$work_outhome, probs = c(0.99))[[1]]
  datatable = datatable[datatable$work_outhome <= maxvalue, ]
  cat(x, nrow(datatable), '\n')
}

nrow(datatable)

x = datatable[datatable$year == 2 & datatable$xgender == 1, "work_outhome"]
y = datatable[datatable$year == 2 & datatable$xgender == 0, "work_outhome"]
kruskal.test(list(x, y))

# Counting work-only tours (simple and complex)

for (yi in 1:3) {
  yearly = datatable[datatable$year == yi, c("tucaseid", "fullactstr", 'sw', 'cw', 'snw', 'cnw')]
  wos = c()
  woc = c()
  for (i in 1:nrow(yearly)) {
    tucaseid = yearly[i, 'tucaseid']
    fullactstr = yearly[i, 'fullactstr']
    fullactstr = levels(fullactstr)[fullactstr]
    tours = extract_tours_with_details_v3(fullactstr)
    for (t in tours) {
      if (t$type == 'SW')
      {
        if (grepl('WT+W', t$tour)) {
          #cat(t$type, t$tour, '\n')
          woc = c(woc, tucaseid)
        }
        else
          wos = c(wos, tucaseid)
      }
    }
  }
  cat(yi, 'WOS', length(unique(wos)), nrow(yearly), '\n')
  cat(yi, 'WOC', length(unique(woc)), nrow(yearly), '\n')
  cat(yi, 'WNW', sum(yearly$cw == 1), '\n')
  cat(yi, 'SNW', sum(yearly$snw == 1), '\n')
  cat(yi, 'CNW', sum(yearly$cnw == 1), '\n')
}

# Inhome consumer purchase
y = list()
for (yi in 1:3){
  yearly = datatable[datatable$year == yi, ]
  timeuses = c()
  participations = c()
  for(i in 1:nrow(yearly)) {
    tucaseid = yearly[i, "tucaseid"]
    fullactstr = yearly[i, 'fullactstr']
    fullactstr = levels(fullactstr)[fullactstr]
    values <- strsplit(fullactstr, ' ')[[1]]
    wheres <- values[seq(1, length(values), 3)]
    t1codes = values[seq(2, length(values), 3)]
    t1codes = as.numeric(t1codes)
    durations = values[seq(3, length(values), 3)]
    durations = as.numeric(durations)
    samples = c()
    for (j in 1:length(wheres)){
      if (wheres[j] == 'W') {
        samples = c(samples, durations[j])
        participations = c(participations, tucaseid)
      }
    }
    if (sum(samples) > 0)
      timeuses = c(timeuses, sum(samples))
  }
  cat(years[yi], mean(timeuses), 100 * length(unique(participations))/nrow(yearly), '\n')
  y[[yi]] = timeuses 
}

mean(y[[3]])
kruskal.test(list(y[[2]], y[[3]]))



hist(datatable$work_inhome)
quantile(datatable$work_inhome)

years = c(2006, 2009, 2012)
for(yi in 1:2)
  for (v in c('act_inhome', 'act_outhome', 'total_travel','work_inhome', 'work_outhome', 'work_travel', 'maintain_inhome', 'maintain_outhome','maintain_travel','discre_inhome', 'discre_outhome','discre_travel', 'cc_inhome', 'cc_outhome'))
  {
    y1 = years[yi]
    y2 = years[yi + 1]
    d1 = datatable[datatable$year == yi, v]
    #d1 = nz(d1)
    d2 = datatable[datatable$year == yi + 1, v]
    #d2 = nz(d2)
    kw.test = kruskal.test(list(d1, d2))
    #if (kw.test$p.value < 0.1)
      cat(y1, y2, v, kw.test$p.value, mean(d1), mean(d2), '\n')
    
  }

#SW tours per person
#datatable$tour_types
nrow(datatable)
for (year in c(1, 2, 3)){
  print(year)
  print(sum(datatable$year == year))
  swcount = datatable[datatable$year == year, 'swcount']
  cwcount = datatable[datatable$year == year, 'cwcount']
  count = swcount + cwcount
  print(mean(count))
}

cor(datatable$swcount, datatable$xmultijobs)
polychor(datatable$swcount, datatable$xmultijobs)

cor(datatable$work_outhome, (datatable$swcount + datatable$cwcount))
cor(datatable$work_outhome, (datatable$cwcount))
cor(datatable$work_outhome, (datatable$swcount))



sum(datatable[datatable$year == 1 & datatable$xmultijobs == 1, "sw"])/sum(datatable$year == 1 & datatable$xmultijobs == 1)
sum(datatable[datatable$year == 2 & datatable$xmultijobs == 1, "sw"])/sum(datatable$year == 2 & datatable$xmultijobs == 1)
sum(datatable[datatable$year == 3 & datatable$xmultijobs == 1, "sw"])/sum(datatable$year == 3 & datatable$xmultijobs == 1)

## Tour Duration

for (yi in 1:3) { 
  tour.durations = list(SW=c(), CW=c(), SNW=c(), CNW=c())
  dataset = datatable[datatable$year == yi, c('tucaseid', 'fullactstr')]
  for (i in 1:nrow(dataset)) {
    fullactstr = dataset[i, 'fullactstr']
    fullactstr = levels(fullactstr)[fullactstr]
    tours = extract_tours_with_details_v3(fullactstr)
    samples = list(SW=c(), CW=c(), SNW=c(), CNW=c())
    for (t in tours)
      samples[[t$type]] = c(samples[[t$type]], t$duration)
    
    for (tt in c('SW', 'CW', 'SNW', 'CNW'))
      if (length(samples[[tt]]) > 0)
        tour.durations[[tt]] = c(tour.durations[[tt]], mean(samples[[tt]]))
  }
  values = sapply(c('SW', 'CW', 'SNW', 'CNW'), function(x){mean(nz(tour.durations[[x]]))})
  cat(yi, values, '\n')
}



## Participation

respondents = list()
participation.ratios = list()
gfilters = list('all' = TRUE 
                #'multiple'= datatable$xmultijobs == 1,
                #'fulltime' = datatable$xemp_type == 1,
                #'highincome' = datatable$xhhincome_high == 1,
                #'men' = datatable$xnonmetro == 1
                )

for(yi in c(1:3)){
  respondents[[yi]] = list()
  participation.ratios[[yi]] = list()
  
  for (pg in names(gfilters)){
    filter = datatable$year == yi & gfilters[[pg]]
    dataset = datatable[filter, c("tucaseid", 'fullactstr')]
    respondents[[yi]][[pg]] = nrow(dataset)
    participation.ratios[[yi]][[pg]] = list()
    for (tt in c('SW', 'SNW', 'CW', 'CNW', 'INWORK', 'OUTWORK', 'NONWORK', 'TRAVEL'))
      participation.ratios[[yi]][[pg]][[tt]] = rep(0, 1440)
    
    for(i in 1:nrow(dataset)) {
      fullactstr = dataset[i, "fullactstr"]
      fullactstr = levels(fullactstr)[fullactstr]
      values <- strsplit(fullactstr, ' ')[[1]]
      wheres <- values[seq(1, length(values), 3)]
      t1codes = values[seq(2, length(values), 3)]
      t1codes = as.numeric(t1codes)
      durations = values[seq(3, length(values), 3)]
      durations = as.numeric(durations)
      
      start.time = 0
      for (j in 1:length(t1codes)) {
        tag = NA
        if (wheres[j] == 'W')
          tag = 'OUTWORK'
        else if (wheres[j] == 'H' & t1codes[j] == 5) 
          tag = 'INWORK'
        else if (wheres[j] == 'T')
          tag = 'TRAVEL'
        else if (wheres[j] == 'N')
          tag = 'NONWORK'
        
        if (!is.na(tag))
          for (k in 1:durations[j])
            participation.ratios[[yi]][[pg]][[tag]][start.time + k] = participation.ratios[[yi]][[pg]][[tag]][start.time + k] + 1
        start.time = start.time + durations[j]
      }
      
      tours = extract_tours_with_details_v3(fullactstr)
      for (t in tours) {
        if (t$type %in% c('SW', 'SNW', 'CW', 'CNW') & t$duration > 0)
          for(k in 1:t$duration) {
            participation.ratios[[yi]][[pg]][[t$type]][t$start + t$skip + k] = participation.ratios[[yi]][[pg]][[t$type]][t$start + t$skip + k] + 1
          }
      }
    }
  }
}

tags = c('OUTWORK', 'INWORK', 'NONWORK', 'TRAVEL')
captions = c('Work out-of-home', 'Work in-home', 'Non-work out-of-home', 'Travel')
daytime_names = get_daytime_names()
for (yi in 1:3) {
  pg = 'all'
  cols = rainbow(length(tags))
  plot(0, xlim = c(1, 1440), ylim = c(0, 100), type = 'n', cex = 1.5, xaxt = 'n', xlab = 'Time', ylab = '%')
  for (i in 1:length(tags)) {
    tag = tags[i]
    y = participation.ratios[[yi]][[pg]][[tag]][1:1440]
    n = respondents[[yi]][[pg]]
    cat(yi, tag, length(y), 100*mean(y)/n, '\n')
    lines(1:1440, 100 * y / n, type = 'l', lwd = 4, col = cols[i])
  }
  abline(h = 30, col = 'black', lwd = 0.5, lty = 2)
  axis(1, at = seq(1,1441,120), labels = daytime_names[seq(1, 1441, 120)], las = 2)
  legend('topright', legend = captions, fill = cols, ncol = 2)
  dev.copy(png, paste('./Activity-participation-plots/plot-', yi, '.png', sep = ''), width = 800, height = 600, res = 100)
  dev.off()
}

tags = c('SW', 'CW', 'SNW', 'CNW')
ylims = list(SW =45, CW = 45, SNW = 12, CNW = 12)
daytime_names = get_daytime_names()
for (tag in tags) {
  pg = 'all'
  cols = rainbow(3)
  plot(0, xlim = c(1, 1440), ylim = c(0, ylims[[tag]]), type = 'n', cex.lab = 1.5, cex.axis = 1.2, xaxt = 'n', xlab = 'Time', ylab = 'Participation rate (%)')
  for (yi in 1:3) {
    y = participation.ratios[[yi]][[pg]][[tag]][1:1440]
    n = respondents[[yi]][[pg]]
    cat(yi, tag, length(y), 100*mean(y)/n, '\n')
    lines(1:1440, 100 * y / n, type = 'l', lwd = 4, col = cols[yi])
  }
  axis(1, at = seq(1,1441,120), labels = daytime_names[seq(1, 1441, 120)], las = 2, cex.axis = 1.2)
  legend('topright', legend = c(2006, 2009, 2012), fill = cols, ncol = 1, cex = 1.5)
  dev.copy(png, paste('./Activity-participation-plots/plot-', tag, '.png', sep = ''), width = 800, height = 600, res = 100)
  dev.off()
}


# Loading 
resp <-read.csv(filename('resp'))
cps <- read.csv(filename(('cps')))
resp_cps <- merge(resp, cps, on = c('TUCASEID', 'TULINENO'))

sum(resp$TUYEAR == 2009 & resp$TELFS %in% c(3, 4)) / sum(resp$TUYEAR == 2009)

table(resp_cps[resp_cps$TUYEAR == 2009 & resp_cps$HUFAMINC %in% c(13:16), 'TEIO1COW'])

f = datatable$year == 2 & !is.na(datatable$xhhincome_low) & datatable$xhhincome_low == 1
mean(nz(datatable[f, "work_inhome"]))
mean(nz(datatable$work_inhome))

samples = datatable[datatable$year == 1 & datatable$work_inhome > 0, ]
table(samples$xgender)

table(resp_cps[resp_cps$TUCASEID %in% samples$tucaseid, 'TRMJIND1'])
