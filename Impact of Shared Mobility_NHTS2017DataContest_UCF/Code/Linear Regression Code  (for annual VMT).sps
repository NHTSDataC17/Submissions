

DATASET ACTIVATE   dataset1.
REGRESSION
  /MISSING LISTWISE
  /REGWGT=wthhfin
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT LN_VMTHH
  /METHOD=ENTER Newyork Chicago Sanjose  hhsize pr_male Pr_senior wrkcount Pr_wrkhm Rural_Big  Veh_0 Income_low BKSH RDSH N_RD C_RD_SEnior Rural_RD   INCLW_bk .




