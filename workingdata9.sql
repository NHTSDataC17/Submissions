--------------DATA2009----------
---Dataselection
---Trip9 is the Trip FIle
SELECT  trip9.[HOUSEID] ,trip9.[PERSONID] ,trip9.[TRPTRANS],trip9.[R_SEX],trip9.[STRTTIME], 
trip9.[TRAVDAY], trip9.[TDAYDATE], trip9.[WHYTO], trip9.[WHYFROM] ,trip9.[TRVLCMIN], trip9.[TRPMILES] 
,trip9.[HHSIZE] ,trip9.[HHVEHCNT] ,trip9.[HHFAMINC] ,
trip9.[R_AGE] ,trip9.[EDUC], trip9.[HHSTATE], trip9.[URBRUR] , trip9.[RAIL] , trip9.[HH_HISP]
, trip9.[HH_RACE], trip9.[URBAN],trip9.[URBANSIZE] ,trip9.[WTTRDFIN]
INTO WorkingData9A
FROM trip9;

SELECT person9.[ISSUE], person9.[SCHCRIM], person9.[BORNINUS], person9.[SCHDIST], person9.[PERSONID_p], 
person9.[HOUSEID_p], person9.[MEDCOND], person9.[SCHSPD], person9.[SCHTRAF], person9.[SCHWTHR]
INTO WorkingData9B
FROM person9;

SELECT * INTO WorkingData9 FROM
WorkingData9B P JOIN WorkingData9A T
ON P.[HOUSEID_p] = T.[HOUSEID] AND P.[PERSONID_p] = T.[PERSONID]



ALTER Table WorkingData9
DROP Column [HOUSEID_p]

ALTER Table WorkingData9
DROP Column [PERSONID_p]




DELETE FROM WorkingData9
where WorkingData9.[R_AGE] IN ('-1','-7','-8','-9')

DELETE FROM WorkingData9
WHERE WorkingData9.[R_AGE] > 18

DELETE FROM WorkingData9
WHERE WorkingData9.[STRTTIME] <600

DELETE FROM WorkingData9
WHERE WorkingData9.[STRTTIME] >1659

DELETE FROM WorkingData9
WHERE WorkingData9.[STRTTIME] >859 and WorkingData9.[STRTTIME] < 1400 

DELETE FROM WorkingData9
WHERE WorkingData9.[TRAVDAY] in ('7','1','01','07')

DELETE FROM WorkingData9
WHERE WorkingData9.[TDAYDATE] in ('200807','200808')


UPDATE WorkingData9
SET [RAIL] = '1'
WHERE WorkingData9.[RAIL] IN ('1','01')

UPDATE WorkingData9
SET [RAIL] = '0'
WHERE WorkingData9.[RAIL] IN ('2','02')

----
UPDATE WorkingData9
SET [HH_HISP] = '1'
WHERE WorkingData9.[RAIL] IN ('1','01')

UPDATE WorkingData9
SET [HH_HISP] = '0'
WHERE WorkingData9.[HH_HISP] IN ('2','02')


----
UPDATE WorkingData9
SET [HH_RACE] = 'White'
WHERE WorkingData9.[HH_RACE] in ('1','01')

UPDATE WorkingData9
SET [HH_RACE] = 'Black'
WHERE WorkingData9.[HH_RACE] in ('2','02')
UPDATE WorkingData9
SET [HH_RACE] = 'Asian'
WHERE WorkingData9.[HH_RACE] in ('3','03')
UPDATE WorkingData9
SET [HH_RACE] = 'AmericanIndian'
WHERE WorkingData9.[HH_RACE] in ('4','04')
UPDATE WorkingData9
SET [HH_RACE] = 'NativeHawaiian'
WHERE WorkingData9.[HH_RACE] in ('5','05')
UPDATE WorkingData9
SET [HH_RACE] = 'Multiracial'
WHERE WorkingData9.[HH_RACE] in ('6','06')
UPDATE WorkingData9
SET [HH_RACE] = 'Mexican'
WHERE WorkingData9.[HH_RACE] in ('7','07')

UPDATE WorkingData9
SET [HH_RACE] = 'Other'
WHERE WorkingData9.[HH_RACE] in ('97')

-----------

Update WorkingData9
SET [URBAN] = 'Urban_Area'
WHERE WorkingData9.[URBAN] in ('1','01')

Update WorkingData9
SET [URBAN] = 'Urban_Cluster'
WHERE WorkingData9.[URBAN] in ('2','02')

Update WorkingData9
SET [URBAN] = 'Urban_Surrounding'
WHERE WorkingData9.[URBAN] in ('3','03')

Update WorkingData9
SET [URBAN] = 'Not_Urban_Area'
WHERE WorkingData9.[URBAN] in ('4','04')

-------

Update WorkingData9
SET [URBANSIZE] = '50000-199999'
WHERE WorkingData9.[URBANSIZE] in ('1','01')

Update WorkingData9
SET [URBANSIZE] = '200000-499999'
WHERE WorkingData9.[URBANSIZE] in ('2','02')
Update WorkingData9
SET [URBANSIZE] = '500000-999999'
WHERE WorkingData9.[URBANSIZE] in ('3','03')
Update WorkingData9
SET [URBANSIZE] = '>=1Million_W/OHR'
WHERE WorkingData9.[URBANSIZE] in ('4','04')
Update WorkingData9
SET [URBANSIZE] = '>=1Million_WHR'
WHERE WorkingData9.[URBANSIZE] in ('5','05')
Update WorkingData9
SET [URBANSIZE] = 'Not_Urban'
WHERE WorkingData9.[URBANSIZE] in ('6','06')


-----Variable Grouping

UPDATE  WorkingData9
SET R_AGE = ' 5-10'
where WorkingData9.[R_AGE] in ('5','6','7','8','9','10')

UPDATE  WorkingData9
SET R_AGE = ' 11-13'
where WorkingData9.[R_AGE] in ('11','12','13')

UPDATE  WorkingData9
SET R_AGE = ' 14-15'
where WorkingData9.[R_AGE] in ('14','15')

UPDATE  WorkingData9
SET R_AGE = ' 16-18'
where WorkingData9.[R_AGE] in ('16','17','18')

UPDATE  WorkingData9
SET R_AGE = ' 19-20'
where WorkingData9.[R_AGE] in ('19','20')

------INCOME-----

UPDATE  WorkingData9
SET HHFAMINC = '<$10000'
where WorkingData9.[HHFAMINC] in ('01','02')

UPDATE  WorkingData9
SET HHFAMINC = '$10000-$24999'
where WorkingData9.[HHFAMINC] in ('03','04','05')

UPDATE  WorkingData9
SET HHFAMINC = '$25000-$49999'
where WorkingData9.[HHFAMINC] in ('06','07','08','09','10')

UPDATE  WorkingData9
SET HHFAMINC = '$50000-$99999'
where WorkingData9.[HHFAMINC] in ('11','12','13','14','15','16','17')

UPDATE  WorkingData9
SET HHFAMINC = '>=$100000'
where WorkingData9.[HHFAMINC] in ('18')

-------(Trip Mode) TRPTRANS------

UPDATE  WorkingData9
SET TRPTRANS = 'Walk'
where WorkingData9.[TRPTRANS] in ('23')

UPDATE  WorkingData9
SET TRPTRANS = 'Bicycle'
where WorkingData9.[TRPTRANS] in ('22')

UPDATE  WorkingData9
SET TRPTRANS = 'Car'
where WorkingData9.[TRPTRANS] in ('01','1')

UPDATE  WorkingData9
SET TRPTRANS = 'SUV'
where WorkingData9.[TRPTRANS] in ('03','3')

UPDATE  WorkingData9
SET TRPTRANS = 'Van'
where WorkingData9.[TRPTRANS] in ('02','2')

UPDATE  WorkingData9
SET TRPTRANS = 'PickupTruck'
where WorkingData9.[TRPTRANS] in ('04','05','4','5')

UPDATE  WorkingData9
SET TRPTRANS = 'SchoolBus'
where WorkingData9.[TRPTRANS] in ('11')


UPDATE  WorkingData9
SET TRPTRANS = 'PublicTransport'
where WorkingData9.[TRPTRANS] in ('10','09','9','15','12','14','16','17')

UPDATE  WorkingData9
SET TRPTRANS = 'Taxi'
where WorkingData9.[TRPTRANS] in ('19')

UPDATE  WorkingData9
SET TRPTRANS = 'Other'
where WorkingData9.[TRPTRANS] in ('06','6','08','8','18','24','97','13','20','21', '7','07', '-1','-7','-8','-9')

-----HHVEHCNT----

UPDATE  WorkingData9
SET HHVEHCNT = '>4'
where WorkingData9.[HHVEHCNT] in ('5','6','7','8','9','10','11','12','13','14','15','23','27')

-----SEX----
UPDATE  WorkingData9
SET R_SEX = '1'
where WorkingData9.[R_SEX] in ('1','01')

UPDATE  WorkingData9
SET R_SEX = '0'
where WorkingData9.[R_SEX] in ('2','02')

---------WHYTO

UPDATE  WorkingData9
SET WHYTO = 'HomeActivity'
where WorkingData9.[WHYTO] in ('1','01')

UPDATE  WorkingData9
SET WHYTO = 'WorkRelatedActivity'
where WorkingData9.[WHYTO] in ('10','11','12','13','14','60')

UPDATE  WorkingData9
SET WHYTO = 'AttendChild/AdultCare'
where WorkingData9.[WHYTO] in ('24')

UPDATE  WorkingData9
SET WHYTO = 'Other'
where WorkingData9.[WHYTO] in ('97','62','63','23','61','65','72')

UPDATE  WorkingData9
SET WHYTO = 'Relegious/VolunteerActivity'
where WorkingData9.[WHYTO] in ('20','22','81')

UPDATE  WorkingData9
SET WHYTO = 'PicknDropSomeone'
where WorkingData9.[WHYTO] in ('70','71','73')

UPDATE  WorkingData9
SET WHYTO = 'Shopping/BuyServices'
where WorkingData9.[WHYTO] in ('40','41','42','43')


UPDATE  WorkingData9
SET WHYTO = 'AttendSchool'
where WorkingData9.[WHYTO] in ('21')

UPDATE  WorkingData9
SET WHYTO = 'MealTrip'
where WorkingData9.[WHYTO] in ('80','82','83')


UPDATE  WorkingData9
SET WHYTO = 'RecreationalActivity'
where WorkingData9.[WHYTO] in ('50','52','54','55')

UPDATE  WorkingData9
SET WHYTO = 'Exercise'
where WorkingData9.[WHYTO] in ('51','64')

UPDATE  WorkingData9
SET WHYTO = 'VisitRelatives'
where WorkingData9.[WHYTO] in ('53')

UPDATE  WorkingData9
SET WHYTO = 'HealthCareTrip'
where WorkingData9.[WHYTO] in ('30')


-----WHYFROM---
UPDATE  WorkingData9
SET WHYFROM = 'HomeActivity'
where WorkingData9.[WHYFROM] in ('1','01')

UPDATE  WorkingData9
SET WHYFROM = 'WorkRelatedActivity'
where WorkingData9.[WHYFROM] in ('10','11','12','13','14','60')

UPDATE  WorkingData9
SET WHYFROM = 'AttendChild/AdultCare'
where WorkingData9.[WHYFROM] in ('24')

UPDATE  WorkingData9
SET WHYFROM = 'Other'
where WorkingData9.[WHYFROM] in ('97','62','63','23','61','65','72')

UPDATE  WorkingData9
SET WHYFROM = 'Relegious/VolunteerActivity'
where WorkingData9.[WHYFROM] in ('20','22','81')

UPDATE  WorkingData9
SET WHYFROM = 'PicknDropSomeone'
where WorkingData9.[WHYFROM] in ('70','71','73')

UPDATE  WorkingData9
SET WHYFROM = 'Shopping/BuyServices'
where WorkingData9.[WHYFROM] in ('40','41','42','43')


UPDATE  WorkingData9
SET WHYFROM = 'AttendSchool'
where WorkingData9.[WHYFROM] in ('21')

UPDATE  WorkingData9
SET WHYFROM = 'MealTrip'
where WorkingData9.[WHYFROM] in ('80','82','83')


UPDATE  WorkingData9
SET WHYFROM = 'RecreationalActivity'
where WorkingData9.[WHYFROM] in ('50','52','54','55')

UPDATE  WorkingData9
SET WHYFROM = 'Exercise'
where WorkingData9.[WHYFROM] in ('51','64')

UPDATE  WorkingData9
SET WHYFROM = 'VisitRelatives'
where WorkingData9.[WHYFROM] in ('53')

UPDATE  WorkingData9
SET WHYFROM = 'HealthCareTrip'
where WorkingData9.[WHYFROM] in ('30')

----Urban/Rural URBRUR----
UPDATE  WorkingData9
SET URBRUR = '1'
where WorkingData9.[URBRUR] in ('1','01')

UPDATE  WorkingData9
SET URBRUR = '0'
where WorkingData9.[URBRUR] in ('2','02')


--------Travel Day of WEEK

UPDATE  WorkingData9
SET TRAVDAY = 'Monday'
where WorkingData9.[TRAVDAY] in ('2','02')

UPDATE  WorkingData9
SET TRAVDAY = 'Tuesday'
where WorkingData9.[TRAVDAY] in ('3','03')

UPDATE  WorkingData9
SET TRAVDAY = 'Wednesday'
where WorkingData9.[TRAVDAY] in ('4','04')

UPDATE  WorkingData9
SET TRAVDAY = 'Thursday'
where WorkingData9.[TRAVDAY] in ('5','05')

UPDATE  WorkingData9
SET TRAVDAY = 'Friday'
where WorkingData9.[TRAVDAY] in ('6','06')

-----------

UPDATE WorkingData9
SET [TDAYDATE]= ' March2008'
WHERE  WorkingData9.[TDAYDATE]= '200803'

UPDATE WorkingData9
SET [TDAYDATE]= ' April2008'
WHERE  WorkingData9.[TDAYDATE]= '200804'

UPDATE WorkingData9
SET [TDAYDATE]= ' May2008'
WHERE  WorkingData9.[TDAYDATE]= '200805'

UPDATE WorkingData9
SET [TDAYDATE]= ' June2008'
WHERE  WorkingData9.[TDAYDATE]= '200806'

UPDATE WorkingData9
SET [TDAYDATE]= ' July2008'
WHERE  WorkingData9.[TDAYDATE]= '200807'

UPDATE WorkingData9
SET [TDAYDATE]= ' August2008'
WHERE  WorkingData9.[TDAYDATE]= '200808'

UPDATE WorkingData9
SET [TDAYDATE]= ' September2008'
WHERE  WorkingData9.[TDAYDATE]= '200809'

UPDATE WorkingData9
SET [TDAYDATE]= ' October2008'
WHERE  WorkingData9.[TDAYDATE]= '200810'

UPDATE WorkingData9
SET [TDAYDATE]= ' November2008'
WHERE  WorkingData9.[TDAYDATE]= '200811'

UPDATE WorkingData9
SET [TDAYDATE]= ' December2016'
WHERE  WorkingData9.[TDAYDATE]= '200812'

UPDATE WorkingData9
SET [TDAYDATE]= ' January2009'
WHERE  WorkingData9.[TDAYDATE]= '200901'

UPDATE WorkingData9
SET [TDAYDATE]= ' February2009'
WHERE  WorkingData9.[TDAYDATE]= '200902'

UPDATE WorkingData9
SET [TDAYDATE]= ' March2009'
WHERE  WorkingData9.[TDAYDATE]= '200903'

UPDATE WorkingData9
SET [TDAYDATE]= ' April2009'
WHERE  WorkingData9.[TDAYDATE]= '200904'


