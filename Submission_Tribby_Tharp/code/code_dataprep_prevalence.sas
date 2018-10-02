libname LIBRARY "H:\NCI_research\Data\NHTravelSurvey\Sas";

data Person;
set LIBRARY.perpub;
run;

data Household;
set LIBRARY.hhpub;
run;

data personweight;
set LIBRARY.perwgt;
run;

proc sort data = person;
by houseid ;
run;
proc sort data = household;
by houseid ;
run;
data merged;
merge household person;
 by houseid ;
 run;

data analytic; 
set merged;
/* DOUG CODE */
length smartphone taxicnt weights rentpcnt popdensity houseunits hhtrips pubtransit active hhactive modecount delivery 
carshare2 bikeshare2 bike4ex2  8. ;
smartphone = sphone * 1;
if smartphone lt 0 then smartphone = .;
taxicnt = taxi * 1;
if taxicnt lt 0 then taxicnt = .;
weights = 1 * WTHHFIN;
rentpcnt 		= 0.01 	* HTHTNRNT;
popdensity 		= 1 	* HTPPOPDN;
houseunits 		= 1 	* HTRESDN;
hhtrips 		= 1 	* CNTTDHH;
if USEPUBTR = '01' then pubtransit		= 1;
else
if USEPUBTR = '02' then pubtransit		= 0;

*convert walk bike and both codes to active;
if alt_45 in ('01','02','03') then active = 1;
else active = 0;

*wont work as coded, but reminds me to create household level variable for somebody is active traveler;
if sum(active) gt 0 then hhactive = 1;
else hhactive = 0;

* convert character freq by travel modes to numeric 'ever' variable;
length carever bikeever walkever busever taxiever paraever trainever tripmiles age 8.;
if 5 gt walk gt 0 then walkever = 1;
else 
if walk = '-9' then walkever = 0;
else
if walk = 5 then walkever = 0;
else
if walk lt 0 and walk ne '-9' then walkever = 0; *changed 30sept2018 from missing to 0;

if 5 gt bike gt 0 then bikeever = 1;
else 
if bike = '-9' then bikeever = 0;
else
if bike = 5 then bikeever = 0;
else
if bike lt 0 and bike ne '-9' then bikeever = 0;  *changed 30sept2018 from missing to 0;

/*binary variable*/
if biketyp in (2,3,4) then biketyp2 =1;
if biketyp = 1 then biketyp2 = 0;

if 5 gt taxi gt 0 then taxiever = 1;
else 
if taxi = '-9' then taxiever = 0;
else
if taxi = 5 then taxiever = 0;
else
if taxi lt 0 and taxi ne '-9' then taxiever = 0;  *changed 30sept2018 from missing to 0;

if 5 gt bus gt 0 then busever = 1;
else 
if bus = '-9' then busever = 0;
else
if bus = 5 then busever = 0;
else
if bus lt 0 and bus ne '-9' then busever = 0;  *changed 30sept2018 from missing to 0;

if 5 gt train gt 0 then trainever = 1;
else 
if train = '-9' then trainever = 0;
else
if train = 5 then trainever = 0;
else
if train lt 0 and train ne '-9' then trainever = 0; *changed 30sept2018 from missing to 0;

if 5 gt para gt 0 then paraever = 1;
else 
if para = '-9' then paraever = 0;
else
if para = 5 then paraever = 0;
else
if para lt 0 and para ne '-9' then paraever = 0; *changed 30sept2018 from missing to 0;

if 5 gt car gt 0 then carever = 1;
else 
if car = '-1' then carever = 0;
else
if car = 5 then carever = 0;
else
if car lt 0 and car ne '-9' then carever = 0; *changed 30sept2018 from missing to 0;

modecount = carever  + bikeever  + walkever  + busever  + taxiever  + paraever  + trainever ;

if trpmiles ge 0 then tripmiles = trpmiles * 1;
else tripmiles = 0;  *changed 30sept2018 from missing to 0; *will be uninitialized when less granular than n=trip level (trip count);


if r_age  ge 0 then age = r_age * 1;
else age = .; *age should be age or missing, not zero;


if deliver  ge 0 then delivery = deliver * 1;
else delivery = 0;

if bike4ex  ge 0 then bike4ex2 = bike4ex * 1;
else bike4ex2 = 0;

if bikeshare  ge 0 then bikeshare2 = bikeshare * 1;
else bikeshare2 = 0; *changed 1oct2018 from missing to 0;

if carshare  ge 0 then carshare2 = carshare * 1;
else carshare2 = 0;

/*************************************/
/* new transformations as of sept 27 */
/*************************************/
length mileyear workhome workft walksafety walkinfra WALK4EX2 female white hispanic age rideshare2 rail2 PTUSED2 
PRMACT2 PHYACT2 OCCAT2 NWALKTRP2 children HTEEMPDN2 HTHTNRNT2 HTPPOPDN2 HTRESDN2 HHFAMINC2 health2
HBRESDN2 /*use either this or rural v not */ 

8.;

if YEARMILE lt 0 then mileyear = 0 ;
else
mileyear = yearmile;

*wrkcount left as is;

if WKRMHM = '-1' then workhome = 0;
else if WKRMHM = '01' then workhome = 2;  * yes, intentional reverse coding;
else if WKRMHM = '02' then workhome = 1;
else workhome = .;

if WKFTPT = '-1' then workft = 0;
else if WKFTPT = '01' then workft = 2;  * yes, intentional reverse coding;
else if WKFTPT = '02' then workft = 1;
else workft = .;

if WALK_GKQ = '-1' then walksafety = 0;
else
if WALK_GKQ gt 0 then walksafety = 1;
else
walksafety = .;

if WALK_DEF = '-1' then walkinfra = 0;
else
if WALK_DEF gt 0 then walkinfra = 1;
else
walkinfra = .;

if WALK4EX = '-1' then WALK4EX2 = 0;
else
if WALK4EX gt 0 then WALK4EX2 = 1;
else
walkinfra = .;

if R_SEX = '02' then female = 1;
else 
if R_SEX = '01' then female = 0;
else female = .;

if R_RACE = '01' then white = 1;
else 
if R_RACE ne '' then white = 0;
else white = .;

if R_HISP = '01' then hispanic = 1;
else 
if R_HISP = '02' then hispanic = 0;
else hispanic = .;

if r_age  ge 0 then age = r_age * 1;
else age = .;

if rideshare  ge 0 then rideshare2 = rideshare * 1;
else rideshare2 = .;

if rail = '01' then rail2 = 1;
else 
if rail = '02' then rail2 = 0;

if PTUSED ge 0 then PTUSED2 = PTUSED * 1;
else PTUSED2 = .;

if PRMACT = '01' then PRMACT2 = 1;
else 
if PRMACT ne '' then PRMACT2 = 0;
else PRMACT2 = .;

if PHYACT = '01' then PHYACT2 = 1;
else 
if PHYACT = '02' then PHYACT2 = 2;
else 
if PHYACT = '03' then PHYACT2 = 3;
else PHYACT2 = .;

if OCCAT = '-1' then OCCAT2 = 0;
else
if OCCAT = '01' then OCCAT2 =  1;
else
if OCCAT = '02' then OCCAT2 =  2;
else
if OCCAT = '03' then OCCAT2 =  3;
else
if OCCAT = '04' then OCCAT2 =  4;
else
if OCCAT = '97' then OCCAT2 =  5;
else OCCAT2 =  .;

if NWALKTRP  ge 0 then NWALKTRP2 = NWALKTRP * 1;
else NWALKTRP2 = .;

* don't forget NUMADLT, use as is;
* NBIKETRP seems tautological, if dep var is bike riding;
* don't forget LPACT;
* don't forget HHVEHCNT;
* don't forget HHSIZE;


if LPACT lt 0 then lpact = .;

if LIF_CYC in ('03','04','05','06','07','08') then children = 1;
else if LIF_CYC ne '' then children = 0;
else children = .;

  

/*HTEEMPDN
25=0-49
75=50-99
150=100-249
350=250-499
750=500-999
1500=1,000-1,999
3000=2,000-3,999
5000=4,000-999,999
*/
HTEEMPDN2 = HTEEMPDN * 1;
if HTEEMPDN2 lt 0 then HTEEMPDN2 = .;

/*HTPPOPDN2 */
HTPPOPDN2 = HTPPOPDN * 1;
if HTPPOPDN2 lt 0 then HTPPOPDN2 = .;

/*HHFAMINC2 */
HHFAMINC2 = HHFAMINC * 1;
if HHFAMINC2 lt 0 then HHFAMINC2 = .;

/* HTHTNRNT 
-9=Not ascertained
0=0-4%
05=5-14%
20=15-24%
30=25-34%
40=35-44%
50=45-54%
60=55-64%
70=65-74%
80=75-84%
90=85-94%
95=95-100%
*/
if HTHTNRNT = '0'  then HTHTNRNT2 = 0;
if HTHTNRNT = '05' then HTHTNRNT2 = 5;
if HTHTNRNT = '20' then HTHTNRNT2 = 20;
if HTHTNRNT = '30' then HTHTNRNT2 = 30;
if HTHTNRNT = '40' then HTHTNRNT2 = 40;
if HTHTNRNT = '50' then HTHTNRNT2 = 50;
if HTHTNRNT = '60' then HTHTNRNT2 = 60;
if HTHTNRNT = '70' then HTHTNRNT2 = 70;
if HTHTNRNT = '80' then HTHTNRNT2 = 80;
if HTHTNRNT = '90' then HTHTNRNT2 = 90;
if HTHTNRNT = '95' then HTHTNRNT2 = 95;
else HTHTNRNT2 = .;

/*health2 */
health2 = health * 1;
if health2 lt 0 then health2 = .;

/*HBRESDN2 */
HBRESDN2 = HBRESDN * 1;
if HBRESDN2 lt 0 then HBRESDN2 = .;

/* DOUG CODE END*/

/*alternative mode of transportation: transit/taxi */
if ALT_16 in ('-9', '-1') then ALT_16_r = 0;
if ALT_16 in ('01', '02', '03', '04') then ALT_16_r = 1;

/*alternative mode of transportation: carpool/ */
if ALT_23 in ('-9', '-1') then ALT_23_r = 0;
if ALT_23 in ('01', '02', '03', '04') then ALT_23_r = 1;

/*bike for exercise in the last week*/
if BIKE4EX <= 0 then BIKE4EX_r = 0;
if BIKE4EX > 0 then BIKE4EX_r = 1;   

/*count of bike share in the last week*/
if BIKESHARE <=0 then BIKESHARE_r = 0;
if BIKESHARE > 0 then BIKESHARE_r = 1;

/*reasons for not biking: infra */
if BIKE_DFR in ('-9', '-1') then BIKE_DFR_r = 0;
if BIKE_DFR in ('01', '02', '03', '04', '05', '06', '07') then BIKE_DFR_r = 1;

/*reasons for not biking: safety */
if BIKE_GKP in ('-9', '-1') then BIKE_GKP_r = 0;
if BIKE_GKP in ('01', '02', '03', '04', '05', '06', '07') then BIKE_GKP_r = 1;

/*nativity */
if BORNINUS = '01' then BORNINUS_r = 1;
if BORNINUS = '02' then BORNINUS_r = 0;
if BORNINUS in ( '-9', '-8', '-7') then delete;

/* carshare */
if carshare ge 0 then carshare_r = carshare * 1;
else carshare_r = 0;

/*CENSUS division */
/*CENSUS_D */

/* Count of trips on travel day */
CNTTDTR_r = CNTTDTR;

/*Medical conditions affecting travel */
if CONDNIGH = '01' or CONDPUB = '01' or CONDRIDE = '01' or CONDRIVE = '01' or CONDSPEC = '01' or
   CONDTAX = '01' or CONDTRAV = '01' then delete;

/*DELIVERY */
DELIVER_r = 1;
if DELIVER < 1 then DELIVER_r = 0;

/* Distance to school or work */
if DISTTOSC17 = -9 and DISTTOWK17 = -9 then Distance = 0; 
if DISTTOSC17 < DISTTOWK17 then Distance = DISTTOWK17;
if DISTTOSC17 > DISTTOWK17 then Distance = DISTTOSC17;

/*Driver */
DRIVER_r = 1;
if DRIVER = '-1' or DRIVER = '02' then DRIVER_r = 0;

/*Driver Count */
DRVRCNT_r = DRVRCNT;

/*EDUCATION */
if EDUC < 1 then EDUC_r = 0;
if EDUC = '01' then EDUC_r = 1;
if EDUC = '02' then EDUC_r = 2;
if EDUC = '03' then EDUC_r = 3;
if EDUC = '04' then EDUC_r = 4;
if EDUC = '05' then EDUC_r = 5;

/*FLEXTIME */
if FLEXTIME < 1 then FLEXTIME_r = '0';
if FLEXTIME = '01' then FLEXTIME_r = '1';
if FLEXTIME = '02' then FLEXTIME_r = '2';

/*Travel day began at home location */
TravDayHM = FRSTHM17;

/*More than one job */
if GT1JBLWK < 1 then GT1JBLWK_r = '0';
if GT1JBLWK = '01' then GT1JBLWK_r = '1';
if GT1JBLWK = '02' then GT1JBLWK_r = '2';

/*Renter Occupied housing */
HBHTNRNT_r = HBHTNRNT; 
if HBHTNRNT = '-9' then delete;

/* Housing units / sq mi */
HBRESDN_r = HBRESDN;
if HBRESDN = '-9' then delete;

/*bike typology*/
if BIKESHARE_r = 1 and BIKE4EX_r = 1 then biketyp = 4; /*both */
if BIKESHARE_r = 0 and BIKE4EX_r = 1 then biketyp = 3; /*exercise only */
if BIKESHARE_r = 1 and BIKE4EX_r = 0 then biketyp = 2; /*shared only */
if BIKESHARE_r = 0 and BIKE4EX_r = 0 then biketyp = 1; /*no bike */
/*binary variable*/
if biketyp in (2,3,4) then biketyp2 =1;
if biketyp = 1 then biketyp2 = 0;

run;

data analytic4exp;
set analytic;

drop   /* check these? */
HOUSEID TRAVDAY SAMPSTRAT TDAYDATE HHRESP LIF_CYC MSACAT MSASIZE RAIL URBAN URBANSIZE
URBRUR SCRESP CENSUS_D CENSUS_R CDIVMSAR HH_RACE
 BIKE_GKP CONDTRAV CONDRIDE CONDNIGH CONDRIVE CONDPUB CONDSPEC CONDTAX  WTPERFIN smartphone taxicnt   weights
 DRIVER OUTOFTWN DISTTOWK17 DISTTOSC17 R_AGE_IMP R_SEX_IMP ALT_16 ALT_23 ALT_45 WALK_DEF WALK_GKQ BIKE_DFR
  W_WHCANE W_DOG W_CRUTCH W_SCOOTR W_CHAIR W_MTRCHR WORKER DIARY OUTCNTRY FRSTHM17 CNTTDTR GCDWORK WKSTFIPS
    HEALTH PHYACT VPACT LPACT BORNINUS YRTOUS YEARMILE PROXY WHOPROXY USEPUBTR SAMEPLC W_NONE W_CANE W_WLKR
	 CARRODE TIMETOWK NOCONG PUBTIME  WRKTIME WKRMHM FLEXTIME WKFMHMXX SCHTRN1 SCHTRN2 DELIVER MEDCOND MEDCOND6
WRKTRANS LSTTRDAY17 OCCAT SCHTYP NWALKTRP WALK4EX NBIKETRP BIKE4EX BIKESHARE PTUSED MCUSED CARSHARE RIDESHARE
 HBPPOPDN HBRESDN /*PERSONID*/ R_AGE EDUC R_HISP R_RELAT R_SEX R_RACE PRMACT PAYPROF GT1JBLWK WRK_HOME WKFTPT
  HH_HISP HH_CBSA RESP_CNT WEBUSE17 SMPLSRCE   WTHHFIN HBHUR HTHTNRNT HTPPOPDN HTRESDN HTEEMPDN HBHTNRNT
  TDAYDATE HHRESP LIF_CYC MSACAT MSASIZE RAIL URBAN URBANSIZE URBRUR SCRESP CENSUS_D CENSUS_R CDIVMSAR HH_RACE
  PRICE PLACE WALK2SAVE BIKE2SAVE PTRANS HHRELATD DRVRCNT CNTTDHH HHSTATE HHSTFIPS NUMADLT YOUNGCHILD WRKCOUNT
;

run;

data data4xportrur;
set analytic ;
if urbrur='01' then delete;
run;

PROC EXPORT DATA= WORK.data4xportrur 
            OUTFILE= "data4xportrur.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;


/* *run this to create csv xport ; */
PROC EXPORT DATA= WORK.analytic4exp 
            OUTFILE= "data4xport.csv" 
            DBMS=CSV REPLACE;
     PUTNAMES=YES;
RUN;
*/
run;



/*
proc freq data=analytic;
tables biketyp;
run;
*/
proc sort data=analytic; by HOUSEID PERSONID; 
run;
proc sort data=personweight; by HOUSEID PERSONID; 
run;

data analyticwgt;
  merge analytic (in=per)
        personweight;
  by HOUSEID PERSONID;
  if per;
run;

proc surveyfreq data=analyticwgt varmethod=jackknife;  
repweights WTPERFIN1-WTPERFIN98;
weight WTPERFIN; 
tables URBRUR*biketyp2 URBRUR*biketyp CENSUS_D*URBRUR*biketyp2 
       / WCHISQ CL ROW;
run;
