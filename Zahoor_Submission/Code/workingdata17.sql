---Dataselection

SELECT  trippub17.[HOUSEID] ,trippub17.[PERSONID] ,trippub17.[TRPTRANS],trippub17.[R_SEX],trippub17.[STRTTIME], 
trippub17.[TRAVDAY], trippub17.[TDAYDATE], trippub17.[WHYTO], trippub17.[WHYFROM] ,trippub17.[TRVLCMIN], trippub17.[TRPMILES] 
,trippub17.[HHSIZE] ,trippub17.[HHVEHCNT] ,trippub17.[HHFAMINC] ,
trippub17.[R_AGE] ,trippub17.[EDUC], trippub17.[HHSTATE], trippub17.[URBRUR] , trippub17.[RAIL] , trippub17.[HH_HISP]
, trippub17.[HH_RACE], trippub17.[URBAN],trippub17.[URBANSIZE] , trippub17.[HBPPOPDN],trippub17.[WTTRDFIN]
INTO WorkingData17A
FROM trippub17;

SELECT perpub17.[BIKE_DFR], perpub17.[BIKE_GKP], perpub17.[BORNINUS], perpub17.[WALK_DEF], perpub17.[WALK_GKQ], 
perpub17.[HEALTH], perpub17.[PERSONID_p], perpub17.[HOUSEID_p], perpub17.[MEDCOND]
INTO WorkingData17B
FROM perpub17;

SELECT * INTO WorkingData17 FROM
WorkingData17B P JOIN WorkingData17A T
ON P.[HOUSEID_p] = T.[HOUSEID] AND P.[PERSONID_p] = T.[PERSONID]

ALTER Table WorkingData17
DROP Column [HOUSEID_p]

ALTER Table WorkingData17
DROP Column [PERSONID_p]




-----Removing Negetive Responses


DELETE FROM WorkingData17
where WorkingData17.[R_AGE] IN ('-1','-7','-8','-9')



DELETE FROM WorkingData17
WHERE WorkingData17.[R_AGE] > 18

DELETE FROM WorkingData17
WHERE WorkingData17.[STRTTIME] <600

DELETE FROM WorkingData17
WHERE WorkingData17.[STRTTIME] >1659

DELETE FROM WorkingData17
WHERE WorkingData17.[STRTTIME] >859 and WorkingData17.[STRTTIME] < 1400 

DELETE FROM WorkingData17
WHERE WorkingData17.[TRAVDAY] in ('7','1','01','07')

DELETE FROM WorkingData17
WHERE WorkingData17.[TDAYDATE] in ('201607','201608')

----
UPDATE  WorkingData17
SET [BIKE_DFR] = 'NO_Trails_Park_Sidewalk'
WHERE WorkingData17.[BIKE_DFR] NOT IN ('-1','-9')

UPDATE  WorkingData17
SET [BIKE_DFR] = 'DKNA'
WHERE WorkingData17.[BIKE_DFR] IN ('-1','-9')

UPDATE  WorkingData17
SET [BIKE_GKP] = 'Unsafe_Congestion_Darkness'
WHERE WorkingData17.[BIKE_GKP] NOT IN ('-1','-9')

UPDATE  WorkingData17
SET [BIKE_GKP] = 'DKNA'
WHERE WorkingData17.[BIKE_GKP] IN ('-1','-9')

UPDATE  WorkingData17
SET [WALK_DEF] = 'NO_Trails_Park_Sidewalk'
WHERE WorkingData17.[WALK_DEF] NOT IN ('-1','-9')

UPDATE  WorkingData17
SET [WALK_DEF] = 'DKNA'
WHERE WorkingData17.[WALK_DEF] IN ('-1','-9')

UPDATE  WorkingData17
SET [WALK_GKQ] = 'Unsafe_Congestion_Darkness'
WHERE WorkingData17.[WALK_GKQ] NOT IN ('-1','-9')

UPDATE  WorkingData17
SET [WALK_GKQ] = 'DKNA'
WHERE WorkingData17.[WALK_GKQ] IN ('-1','-9')

-------HEALTH------
UPDATE WorkingData17
SET [HEALTH] = 'Excellent'
WHERE WorkingData17.[HEALTH] IN ('1','01')

UPDATE WorkingData17
SET [HEALTH] = 'Very_Good'
WHERE WorkingData17.[HEALTH] IN ('2','02')

UPDATE WorkingData17
SET [HEALTH] = 'Good'
WHERE WorkingData17.[HEALTH] IN ('3','03')

UPDATE WorkingData17
SET [HEALTH] = 'Fair'
WHERE WorkingData17.[HEALTH] IN ('4','04')

UPDATE WorkingData17
SET [HEALTH] = 'Poor'
WHERE WorkingData17.[HEALTH] IN ('5','05')

UPDATE WorkingData17
SET [HEALTH] = 'DKNA'
WHERE WorkingData17.[HEALTH] IN ('-7')

UPDATE WorkingData17
SET [RAIL] = '1'
WHERE WorkingData17.[RAIL] IN ('1','01')

UPDATE WorkingData17
SET [RAIL] = '0'
WHERE WorkingData17.[RAIL] IN ('2','02')

--------------
UPDATE WorkingData17
SET [HH_HISP] = '1'
WHERE WorkingData17.[RAIL] IN ('1','01')

UPDATE WorkingData17
SET [HH_HISP] = '0'
WHERE WorkingData17.[HH_HISP] IN ('2','02')



UPDATE WorkingData17
SET [HH_RACE] = 'White'
WHERE WorkingData17.[HH_RACE] in ('1','01')

UPDATE WorkingData17
SET [HH_RACE] = 'Black'
WHERE WorkingData17.[HH_RACE] in ('2','02')
UPDATE WorkingData17
SET [HH_RACE] = 'Asian'
WHERE WorkingData17.[HH_RACE] in ('3','03')
UPDATE WorkingData17
SET [HH_RACE] = 'AmericanIndian'
WHERE WorkingData17.[HH_RACE] in ('4','04')
UPDATE WorkingData17
SET [HH_RACE] = 'NativeHawaiian'
WHERE WorkingData17.[HH_RACE] in ('5','05')
UPDATE WorkingData17
SET [HH_RACE] = 'Multiracial'
WHERE WorkingData17.[HH_RACE] in ('6','06')
UPDATE WorkingData17
SET [HH_RACE] = 'Mexican'
WHERE WorkingData17.[HH_RACE] in ('7','07')

UPDATE WorkingData17
SET [HH_RACE] = 'Other'
WHERE WorkingData17.[HH_RACE] in ('97')
-----

Update WorkingData17
SET [URBAN] = 'Urban_Area'
WHERE WorkingData17.[URBAN] in ('1','01')

Update WorkingData17
SET [URBAN] = 'Urban_Cluster'
WHERE WorkingData17.[URBAN] in ('2','02')

Update WorkingData17
SET [URBAN] = 'Urban_Surrounding'
WHERE WorkingData17.[URBAN] in ('3','03')

Update WorkingData17
SET [URBAN] = 'Not_Urban_Area'
WHERE WorkingData17.[URBAN] in ('4','04')

------------

Update WorkingData17
SET [URBANSIZE] = '50000-199999'
WHERE WorkingData17.[URBANSIZE] in ('1','01')

Update WorkingData17
SET [URBANSIZE] = '200000-499999'
WHERE WorkingData17.[URBANSIZE] in ('2','02')
Update WorkingData17
SET [URBANSIZE] = '500000-999999'
WHERE WorkingData17.[URBANSIZE] in ('3','03')
Update WorkingData17
SET [URBANSIZE] = '>=1Million_W/OHR'
WHERE WorkingData17.[URBANSIZE] in ('4','04')
Update WorkingData17
SET [URBANSIZE] = '>=1Million_WHR'
WHERE WorkingData17.[URBANSIZE] in ('5','05')
Update WorkingData17
SET [URBANSIZE] = 'Not_Urban'
WHERE WorkingData17.[URBANSIZE] in ('6','06')




-----Grouping---

UPDATE  WorkingData17
SET R_AGE = ' 5-10'
where WorkingData17.[R_AGE] in ('5','6','7','8','9','10')

UPDATE  WorkingData17
SET R_AGE = ' 11-13'
where WorkingData17.[R_AGE] in ('11','12','13')

UPDATE  WorkingData17
SET R_AGE = ' 14-15'
where WorkingData17.[R_AGE] in ('14','15')

UPDATE  WorkingData17
SET R_AGE = ' 16-18'
where WorkingData17.[R_AGE] in ('16','17','18')


------INCOME-----

UPDATE  WorkingData17
SET HHFAMINC = '<$10000'
where WorkingData17.[HHFAMINC] in ('01','1')

UPDATE  WorkingData17
SET HHFAMINC = '$10000-$24999'
where WorkingData17.[HHFAMINC] in ('2','3','02','03')

UPDATE  WorkingData17
SET HHFAMINC = '$25000-$49999'
where WorkingData17.[HHFAMINC] in ('4','5','04','05')

UPDATE  WorkingData17
SET HHFAMINC = '$50000-$99999'
where WorkingData17.[HHFAMINC] in ('6','7','06','07')

UPDATE  WorkingData17
SET HHFAMINC = '>=$100000'
where WorkingData17.[HHFAMINC] in ('8','9','10','11','08','09')


-----HHVEHCNT----

UPDATE  WorkingData17
SET HHVEHCNT = '>4'
where WorkingData17.[HHVEHCNT] in ('5','6','7','8','9','10','11','12','13','14','15','23','27')

-----SEX----
UPDATE  WorkingData17
SET R_SEX = 'Male'
where WorkingData17.[R_SEX] in ('1','01')

UPDATE  WorkingData17
SET R_SEX = 'Female'
where WorkingData17.[R_SEX] in ('2','02')



----Trip Origin Purpose(WHYTO)

UPDATE  WorkingData17
SET WHYTO = 'HomeActivity'
where WorkingData17.[WHYTO] in ('1')

UPDATE  WorkingData17
SET WHYTO = 'WorkRelatedActivity'
where WorkingData17.[WHYTO] in ('2','3','4')

UPDATE  WorkingData17
SET WHYTO = 'AttendChild/AdultCare'
where WorkingData17.[WHYTO] in ('9','10')

UPDATE  WorkingData17
SET WHYTO = 'Other'
where WorkingData17.[WHYTO] in ('97','7', '14')

UPDATE  WorkingData17
SET WHYTO = 'Relegious/VolunteerActivity'
where WorkingData17.[WHYTO] in ('5','19')

UPDATE  WorkingData17
SET WHYTO = 'PicknDropSomeone'
where WorkingData17.[WHYTO] in ('6')

UPDATE  WorkingData17
SET WHYTO = 'Shopping/BuyServices'
where WorkingData17.[WHYTO] in ('11','12')



UPDATE  WorkingData17
SET WHYTO = 'AttendSchool'
where WorkingData17.[WHYTO] in ('8')

UPDATE  WorkingData17
SET WHYTO = 'MealTrip'
where WorkingData17.[WHYTO] in ('13')


UPDATE  WorkingData17
SET WHYTO = 'RecreationalActivity'
where WorkingData17.[WHYTO] in ('15')

UPDATE  WorkingData17
SET WHYTO = 'Exercise'
where WorkingData17.[WHYTO] in ('16')

UPDATE  WorkingData17
SET WHYTO = 'VisitRelatives'
where WorkingData17.[WHYTO] in ('17')

UPDATE  WorkingData17
SET WHYTO = 'HealthCareTrip'
where WorkingData17.[WHYTO] in ('18')

----WHYFROM----
UPDATE  WorkingData17
SET WHYFROM = 'HomeActivity'
where WorkingData17.[WHYFROM] in ('1')

UPDATE  WorkingData17
SET WHYFROM = 'WorkRelatedActivity'
where WorkingData17.[WHYFROM] in ('2','3','4')

UPDATE  WorkingData17
SET WHYFROM = 'AttendChild/AdultCare'
where WorkingData17.[WHYFROM] in ('9','10')

UPDATE  WorkingData17
SET WHYFROM = 'Other'
where WorkingData17.[WHYFROM] in ('97','7', '14')

UPDATE  WorkingData17
SET WHYFROM = 'Relegious/VolunteerActivity'
where WorkingData17.[WHYFROM] in ('5','19')

UPDATE  WorkingData17
SET WHYFROM = 'PicknDropSomeone'
where WorkingData17.[WHYFROM] in ('6')

UPDATE  WorkingData17
SET WHYFROM = 'Shopping/BuyServices'
where WorkingData17.[WHYFROM] in ('11','12')



UPDATE  WorkingData17
SET WHYFROM = 'AttendSchool'
where WorkingData17.[WHYFROM] in ('8')

UPDATE  WorkingData17
SET WHYFROM = 'MealTrip'
where WorkingData17.[WHYFROM] in ('13')


UPDATE  WorkingData17
SET WHYFROM = 'RecreationalActivity'
where WorkingData17.[WHYFROM] in ('15')

UPDATE  WorkingData17
SET WHYFROM = 'Exercise'
where WorkingData17.[WHYFROM] in ('16')

UPDATE  WorkingData17
SET WHYFROM = 'VisitRelatives'
where WorkingData17.[WHYFROM] in ('17')

UPDATE  WorkingData17
SET WHYFROM = 'HealthCareTrip'
where WorkingData17.[WHYFROM] in ('18')

-------TRPTRANS------
UPDATE  WorkingData17
SET TRPTRANS = 'Walk'
where WorkingData17.[TRPTRANS] in ('1')

UPDATE  WorkingData17
SET TRPTRANS = 'Bicycle'
where WorkingData17.[TRPTRANS] in ('2')

UPDATE  WorkingData17
SET TRPTRANS = 'Car'
where WorkingData17.[TRPTRANS] in ('3')

UPDATE  WorkingData17
SET TRPTRANS = 'SUV'
where WorkingData17.[TRPTRANS] in ('4')

UPDATE  WorkingData17
SET TRPTRANS = 'Van'
where WorkingData17.[TRPTRANS] in ('5')

UPDATE  WorkingData17
SET TRPTRANS = 'PickupTruck'
where WorkingData17.[TRPTRANS] in ('6')

UPDATE  WorkingData17
SET TRPTRANS = 'SchoolBus'
where WorkingData17.[TRPTRANS] in ('10')


UPDATE  WorkingData17
SET TRPTRANS = 'PublicTransport'
where WorkingData17.[TRPTRANS] in ('11','13','16','15')

UPDATE  WorkingData17
SET TRPTRANS = 'Taxi'
where WorkingData17.[TRPTRANS] in ('17','18')

UPDATE  WorkingData17
SET TRPTRANS = 'Other'
where WorkingData17.[TRPTRANS] in ('7','9','12','14','19','20','97','8','08','-1','-7','-8','-9')

----Urban/Rural URBRUR----
UPDATE  WorkingData17
SET URBRUR = 'Urban'
where WorkingData17.[URBRUR] in ('1','01')

UPDATE  WorkingData17
SET URBRUR = 'Rural'
where WorkingData17.[URBRUR] in ('2','02')

--------Travel Day of WEEK

UPDATE  WorkingData17
SET TRAVDAY = 'Monday'
where WorkingData17.[TRAVDAY] in ('2','02')

UPDATE  WorkingData17
SET TRAVDAY = 'Tuesday'
where WorkingData17.[TRAVDAY] in ('3','03')

UPDATE  WorkingData17
SET TRAVDAY = 'Wednesday'
where WorkingData17.[TRAVDAY] in ('4','04')

UPDATE  WorkingData17
SET TRAVDAY = 'Thursday'
where WorkingData17.[TRAVDAY] in ('5','05')

UPDATE  WorkingData17
SET TRAVDAY = 'Friday'
where WorkingData17.[TRAVDAY] in ('6','06')

UPDATE WorkingData17
SET [TDAYDATE]= ' April2016'
WHERE  WorkingData17.[TDAYDATE]= '201604'

UPDATE WorkingData17
SET [TDAYDATE]= ' May2016'
WHERE  WorkingData17.[TDAYDATE]= '201605'

UPDATE WorkingData17
SET [TDAYDATE]= ' June2016'
WHERE  WorkingData17.[TDAYDATE]= '201606'

UPDATE WorkingData17
SET [TDAYDATE]= ' July2016'
WHERE  WorkingData17.[TDAYDATE]= '201607'

UPDATE WorkingData17
SET [TDAYDATE]= ' August2016'
WHERE  WorkingData17.[TDAYDATE]= '201608'

UPDATE WorkingData17
SET [TDAYDATE]= ' September2016'
WHERE  WorkingData17.[TDAYDATE]= '201609'

UPDATE WorkingData17
SET [TDAYDATE]= ' October2016'
WHERE  WorkingData17.[TDAYDATE]= '201610'

UPDATE WorkingData17
SET [TDAYDATE]= ' November2016'
WHERE  WorkingData17.[TDAYDATE]= '201611'

UPDATE WorkingData17
SET [TDAYDATE]= ' December2016'
WHERE  WorkingData17.[TDAYDATE]= '201612'

UPDATE WorkingData17
SET [TDAYDATE]= 'January2017'
WHERE  WorkingData17.[TDAYDATE]= '201701'

UPDATE WorkingData17
SET [TDAYDATE]= ' February2017'
WHERE  WorkingData17.[TDAYDATE]= '201702'

UPDATE WorkingData17
SET [TDAYDATE]= ' March2017'
WHERE  WorkingData17.[TDAYDATE]= '201703'

UPDATE WorkingData17
SET [TDAYDATE]= ' April2017'
WHERE  WorkingData17.[TDAYDATE]= '201704'

-----------------------------------

