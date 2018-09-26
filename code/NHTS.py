import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.formula.api import ols, Logit
from statsmodels.stats.anova import anova_lm, AnovaRM

pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
pd.set_option('display.max_colwidth', -1)

data = pd.read_csv("data.csv")
# Only look at full-time workers (1), part-time workers(2), or no work (0)
data = data[data.WKFTPT==2]

# http://www.pewresearch.org/topics/generations-and-age/
bins = pd.IntervalIndex.from_tuples([(0, 20), (21, 36), (37, 52), (53,71), (72,89)])
data["R_AGE_CAT"] = pd.cut(data.R_AGE, bins).cat.codes

# Combine walk and bike trips
data['NACTTRP'] = data['NWALKTRP'] + data['NBIKETRP']

# Update dataframe values to simplify and clean data
data = data[data.R_AGE_CAT>0]

# Obtain continuous probablities for home ownership, rather than discrete choice
# formula = 'HOMEOWN ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
formula = 'HOMEOWN ~ C(LIF_CYC) + C(R_AGE_CAT)'
model = Logit.from_formula(formula, data).fit(maxiter=100)
data['HOMEOWN_P'] = model.predict(data)
print(model.summary())

data.to_csv('output.csv')

print("Done forming data\n")

print("Beginning Type I ANOVA analysis:\n")
formula = 'BIKESHARE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1)
print("BIKESHARE\n",aov_table)

formula = 'RIDESHARE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1)
print("RIDESHARE\n",aov_table)

formula = 'CARSHARE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1)
print("CARSHARE\n",aov_table)

formula = 'EDUC ~ C(LIF_CYC) + C(R_AGE_CAT) +C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1, robust='hc3')
print("EDUC\n",aov_table)

formula = 'VEH_PER_DRIVE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1, robust='hc3')
print("VEH_PER_DRIVE\n",aov_table)

# formula = 'HOMEOWN_P ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
# model = ols(formula, data).fit()
# aov_table = anova_lm(model, typ=1, robust='hc3')
# print("HOMEOWN_P\n",aov_table)

formula = 'PTUSED ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1, robust='hc3')
print("PTUSED\n",aov_table)

formula = 'URBANSIZE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1, robust='hc3')
print("URBANSIZE\n",aov_table)

formula = 'WKFMHMXX ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1, robust='hc3')
print("WKFMHMXX\n",aov_table)

formula = 'YEARMILE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1, robust='hc3')
print("YEARMILE\n",aov_table)

formula = 'TIMETOWK ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1, robust='hc1')
print("TIMETOWK\n",aov_table)

formula = 'NACTTRP ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=1, robust='hc1')
print("NACTTRP\n",aov_table)

print("Beginning Type II ANOVA analysis:\n")
data_2 = data.sample(frac=1.0)

formula = 'BIKESHARE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data_2).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("BIKESHARE\n",aov_table)

formula = 'RIDESHARE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("RIDESHARE\n",aov_table)

formula = 'CARSHARE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("CARSHARE\n",aov_table)

formula = 'EDUC ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data_2).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("EDUC\n",aov_table)

formula = 'VEH_PER_DRIVE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data_2).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("VEH_PER_DRIVE\n",aov_table)

# formula = 'HOMEOWN_P ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
# model = ols(formula, data_2).fit()
# aov_table = anova_lm(model, typ=2, robust='hc1')
# print("HOMEOWN_P\n",aov_table)

formula = 'PTUSED ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data_2).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("PTUSED\n",aov_table)

formula = 'URBANSIZE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data_2).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("URBANSIZE\n",aov_table)
#
formula = 'WKFMHMXX ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data_2).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("WKFMHMXX\n",aov_table)

formula = 'YEARMILE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("YEARMILE\n",aov_table)

formula = 'TIMETOWK ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("TIMETOWK\n",aov_table)

formula = 'NACTTRP ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=2, robust='hc1')
print("NACTTRP\n",aov_table)

print("Beginning Type III ANOVA analysis:\n")
formula = 'BIKESHARE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("BIKESHARE\n",aov_table)

formula = 'RIDESHARE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("RIDESHARE\n",aov_table)

formula = 'CARSHARE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("CARSHARE\n",aov_table)

formula = 'EDUC ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("EDUC\n",aov_table)

formula = 'VEH_PER_DRIVE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("VEH_PER_DRIVE\n",aov_table)

# formula = 'HOMEOWN_P ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
# model = ols(formula, data).fit()
# aov_table = anova_lm(model, typ=3, robust='hc1')
# print("HOMEOWN_P\n",aov_table)

formula = 'PTUSED ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("PTUSED\n",aov_table)

formula = 'URBANSIZE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("URBANSIZE\n",aov_table)

formula = 'WKFMHMXX ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("WKFMHMXX\n",aov_table)

formula = 'YEARMILE ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("YEARMILE\n",aov_table)

formula = 'TIMETOWK ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("TIMETOWK\n",aov_table)

formula = 'NACTTRP ~ C(LIF_CYC) + C(R_AGE_CAT) + C(LIF_CYC):C(R_AGE_CAT)'
model = ols(formula, data).fit()
aov_table = anova_lm(model, typ=3, robust='hc1')
print("NACTTRP\n",aov_table)