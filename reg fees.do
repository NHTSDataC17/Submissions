cd "~/Dropbox (ASU)/Vehicle Shedding"
use "data/vehicles_depreciation.dta", clear

g veh_age=2017-VEHYEAR

g regfee=23 if HHSTATE=="AL"
replace regfee=100 if HHSTATE=="AK"
replace regfee=9.5+2.89*(msrp/100*.6*.7375^veh_age) if HHSTATE=="AZ" & veh_age>=1
replace regfee=9.5+2.8*(msrp*.6/100) if HHSTATE=="AZ" & veh_age==0
replace regfee=25 if HHSTATE=="AR"
replace regfee=46+24+.0065*value_imputed if HHSTATE=="CA"

*adding CO regfee
* https://www.colorado.gov/pacific/sites/default/files/14-05SpecificOwnershipTax%20IB.pdf
* https://www.douglas.co.us/motorvehicle/motor-vehicle/vehicle-registration-fee-estimate/
replace regfee=75+msrp*.85*.021 if HHSTATE=="CO" & veh_age==0
replace regfee=75+msrp*.85*.015 if HHSTATE=="CO" & veh_age==1
replace regfee=75+msrp*.85*.012 if HHSTATE=="CO" & veh_age==2
replace regfee=75+msrp*.85*.009 if HHSTATE=="CO" & veh_age==3
replace regfee=75+msrp*.85*.0045 if HHSTATE=="CO" & veh_age>3 & veh_age<10
replace regfee=75+3 if HHSTATE=="CO" & veh_age>9

replace regfee=80 if HHSTATE=="CT"
replace regfee=40 if HHSTATE=="DE"

/*DC full info:
*$72 for vehicles 3,499 lbs. and under
*$115 for vehicles 3,500 to 4,999 lbs.
*$155 for vehicles 5,000 lbs. or more
*/
replace regfee=72 if HHSTATE=="DC" & kind=="Car"
replace regfee=115 if HHSTATE=="DC" & kind~="Car"

/*FL full info:
$225 - initial registration plus:
$14.50 for vehicles under 2,500 lbs.
$22.50 for vehicles between 2,500 - 3,499 lbs.
$32.50 for vehicles over 3,500 lbs. 
*/
replace regfee=225+20 if HHSTATE=="FL" & kind=="Car"
replace regfee=225+32.5 if HHSTATE=="FL" & kind~="Car"

replace regfee=20 if HHSTATE=="GA"

/*HI full info:
All vehicles are subject to a $45 state registration fee.
An additional vehicle weight tax shall be levied at the rate of:
1.75 cents a lbs. up to and including 4,000 lbs.;
2.00 cents a lbs. for vehicles over 4,000 lbs. and up to and
including 7,000 lbs.;
2.25 cents a lbs. for vehicles over 7,000 lbs. and up to and
including 10,000 lbs.; or
Vehicles over 10,000 lbs. shall be taxed at a flat rate of $300.
*/
replace regfee=45+3000*.0175 if HHSTATE=="HI" & kind=="Car"
replace regfee=45+4500*.02 if HHSTATE=="HI" & kind~="Car"

replace regfee=69 if HHSTATE=="ID" & veh_age<3
replace regfee=57 if HHSTATE=="ID" & veh_age>2 & veh_age<7
replace regfee=45 if HHSTATE=="ID" & veh_age>6

replace regfee=101 if HHSTATE=="IL" & R_AGE_IMP<65
replace regfee=24 if HHSTATE=="IL" & R_AGE_IMP>=65

/*IN fees are very complex. We have a separate spreadsheet of state fees by vehicle value and age
there are also county excise taxes in many IN counties (though not all), which aren't included here
we argue that because we're using midwest region gas prices and IN does not have a gas tax, our 
omission of county excise taxes in IN is offset (and roughly correct)
*/
replace regfee=21.35+15+in_value_fee if HHSTATE=="IN" & hybrid~=1
replace regfee=21.35+15+in_value_fee+50 if HHSTATE=="IN" & hybrid==1

replace regfee=value_imputed*.01+.4*3000/100 if HHSTATE=="IA" & kind=="Car" & veh_age<8
replace regfee=value_imputed*.0075+.4*3000/100 if HHSTATE=="IA" & kind=="Car" & (veh_age==8 | veh_age==9)
replace regfee=value_imputed*.005+.4*3000/100 if HHSTATE=="IA" & kind=="Car" & (veh_age==10 | veh_age==11)
replace regfee=50+.4*3000/100 if HHSTATE=="IA" & kind=="Car" & veh_age>11
replace regfee=value_imputed*.01+.4*4500/100 if HHSTATE=="IA" & kind~="Car" & veh_age<8
replace regfee=value_imputed*.0075+.4*4500/100 if HHSTATE=="IA" & kind~="Car" & (veh_age==8 | veh_age==9)
replace regfee=value_imputed*.005+.4*4500/100 if HHSTATE=="IA" & kind~="Car" & (veh_age==10 | veh_age==11)
replace regfee=50+.4*34500/100 if HHSTATE=="IA" & kind~="Car" & veh_age>11

replace regfee=30 if HHSTATE=="KS"

replace regfee=21 if HHSTATE=="KY"

replace regfee=value_imputed*.001 if HHSTATE=="LA" & value_imputed>=10000
replace regfee=10000*.001 if HHSTATE=="LA" & value_imputed<10000

replace regfee=35+msrp*.024 if HHSTATE=="ME" & veh_age==0
replace regfee=35+msrp*.0175 if HHSTATE=="ME" & veh_age==1
replace regfee=35+msrp*.0135 if HHSTATE=="ME" & veh_age==2
replace regfee=35+msrp*.01 if HHSTATE=="ME" & veh_age==3
replace regfee=35+msrp*.0065 if HHSTATE=="ME" & veh_age==4
replace regfee=35+msrp*.004 if HHSTATE=="ME" & veh_age==5
replace regfee=35 if HHSTATE=="ME" & veh_age>=6

/*MD full info:
Passenger Cars (shipping weight up to 3,700 lbs.): $135.00
Passenger Cars (shipping weight over 3,700 lbs.): $187.00
Trucks (3/4 ton or 7,000 lbs. or less): $161.50
*/
replace regfee=135 if HHSTATE=="MD" & kind=="Car"
replace regfee=161.5 if HHSTATE=="MD" & kind~="Car"

replace regfee=60 if HHSTATE=="MA"

/*MI info:
It turns out that MI has really opaque rules about registration fees
I found this document:  https://www.michigan.gov/documents/Ad_Valorem_Fees_74801_7.pdf
And calculated the percentage of MSRP fees paid. The percentage changes by value
and is higher for low-value cars. But I'm assuming a rate of about .6% for 0 and 1-year old cars
and a rate of about .5% for all other car ages
*/
replace regfee=msrp*.006 if HHSTATE=="MI" & (veh_age==0 | veh_age==1) & hybrid==0
replace regfee=msrp*.006+47.5 if HHSTATE=="MI" & (veh_age==0 | veh_age==1) & hybrid==1
replace regfee=msrp*.005 if HHSTATE=="MI" & veh_age>1 & hybrid==0
replace regfee=msrp*.005+47.5 if HHSTATE=="MI" & veh_age>1 & hybrid==1

replace regfee=10+msrp*(1-.1*veh_age)*.0125 if HHSTATE=="MN" & veh_age<11
replace regfee=25 if HHSTATE=="MN" & veh_age>10

/*MS has reg fees, privilege fees, and ad valorem taxes that vary by county
I've included here the average ad valorem tax rate that I found online
http://www.dor.ms.gov/Property/Documents/MILLAGE%202016-2017.pdf
*/
replace regfee=15+14+value_imputed*.3*.11593 if HHSTATE=="MS"

/*MO reg fees are based on horsepower, but they don't vary too much:
$18 for vehicles with less than 12 horsepower (hp);
$21 for vehicles with 12 hp - 23 hp;
$24 for vehicles with 24 hp - 35 hp;
$33 for vehicles with 36 hp - 47 hp;
$39 for vehicles with 48 hp - 59 hp;
$45 for vehicles with 60 hp - 71 hp; or
$51 for vehicles with 72 hp and greater.
*/
replace regfee=30 if HHSTATE=="MO"

*some counties in MT also assess vehicle taxes, not accounted for here
replace regfee=217 if HHSTATE=="MT" & veh_age<5
replace regfee=87 if HHSTATE=="MT" & veh_age>4 & veh_age<11
replace regfee=28 if HHSTATE=="MT" & veh_age>=11

/*NE is a bit like MI - very complicated:
https://dmv.nebraska.gov/sites/dmv.nebraska.gov/files/doc/dvr/MV_Tax_Fee_Chart.pdf
NE fees are progressive, though, increasing in percentage terms as vehicles get more expensive
The percentage seems to vary from a bit under .1% up to around .2%
I'm going to simplify to .15% for all, and then simplify the depreciation somewhat as well*/
replace regfee=15+msrp*.0015*(1-.1*veh_age) if HHSTATE=="NE" & veh_age<6
replace regfee=15+msrp*.0015*(.5-.08*(veh_age-5)) if HHSTATE=="NE" & veh_age>5 & veh_age<14
replace regfee=15 if HHSTATE=="NE" & veh_age>13

*some counties also charge a governmental service charge, not represented here
replace regfee=33+msrp*.35*.04 if HHSTATE=="NV" & veh_age==0
replace regfee=33+msrp*.35*.04*.95 if HHSTATE=="NV" & veh_age==1
replace regfee=33+msrp*.35*.04*(.95-.1*(veh_age-1)) if HHSTATE=="NV" & veh_age>1 & veh_age<10
replace regfee=33+msrp*.35*.04*.15 if HHSTATE=="NV" & veh_age>9

*this is a simplification of GVWR-based fees, but it isn't wrong by more than $10
replace regfee=45 if HHSTATE=="NH"

replace regfee=59 if HHSTATE=="NJ" & veh_age<3 & kind=="Car"
replace regfee=46.5 if HHSTATE=="NJ" & veh_age>2 & kind=="Car"
replace regfee=84 if HHSTATE=="NJ" & veh_age<3 & kind~="Car"
replace regfee=71.5 if HHSTATE=="NJ" & veh_age>2 & kind~="Car"

*NM doesn't easily provide documentation of their weight and age-varying fees
*but they don't vary too much ($27-$62), so I'm using the average here 
replace regfee=44.5 if HHSTATE=="NM"

/*NY Registration fees start at $26 for a vehicle under
1,650 lbs. and increase by $1.50 for every 100 lbs.
above 1,650lbs.
some counties charge extra fees as well, not accounted for here.
They are only $10-$20, though (mostly)
https://dmv.ny.gov/registration/registration-fees-use-taxes-and-supplemental-fees-passenger-vehicles
*/
replace regfee=26+1.5*(3000-1650)/100 if HHSTATE=="NY" & kind=="Car"
replace regfee=26+1.5*(4500-1650)/100 if HHSTATE=="NY" & kind~="Car"

*NC is another state where there are county-specific vehicle property taxes
*these are not included here because I can't easily find the rates!
replace regfee=36 if HHSTATE=="NC"

*ND charges fees based on vehicle weight and length of registration in the state (not vehicle age)
*I'm using an intermediate value for length of reg.
* http://www.dot.nd.gov/divisions/mv/docs/2017schedules/MVD2passengerfee.pdf
replace regfee=60 if HHSTATE=="ND" & kind=="Car"
replace regfee=90 if HHSTATE=="ND" & kind~="Car"

*there is also "permissive tax" of up to $25 that can be levied by counties in OH - not included here
replace regfee=34.5 if HHSTATE=="OH" 

*OK charges based on length of registration in the state (like ND)
*I use an intermediate value here
replace regfee=75 if HHSTATE=="OK"

/*In addition to the registration fees additional fees based on MPG will
be required for all vehicles. Vehicles with a rating of 0-19 MPG must
pay $20, 20-39 MPG $25, and 40 MPG or greater $35. I've just added $30 to approximate this.
additional county fees may also apply, it says
*/
replace regfee=43+30 if HHSTATE=="OR" & veh_age>4
replace regfee=43+30 if HHSTATE=="OR" & veh_age<5

replace regfee=36 if HHSTATE=="PA"

*http://www.dmv.ri.gov/documents/fees/RegByWeightChart.pdf
replace regfee=45 if HHSTATE=="RI" & kind=="Car"
replace regfee=55 if HHSTATE=="RI" & kind~="Car"

*SC also has property tax on vehicles, which I guessed at using this pub
* http://www.sccounties.org/Data/Sites/1/media/publications/propertytax2017.pdf
replace regfee=40+value_imputed*.06*.2 if HHSTATE=="SC"

/*Full info for SD: 
$36 for vehicles 2,000 lbs. or less
$72 for vehicles 2,001 to 4,000 lbs.
$108 for vehicles 4,001 to 6,000 lbs.
$144 for vehicles over 6,000 lbs.
this is a simplification
*/
replace regfee=72 if HHSTATE=="SD" 

*there may be additional county fees, but I can't find them
replace regfee=23.75 if HHSTATE=="TN" 

* http://www.txdmv.gov/motorists/register-your-vehicle
replace regfee=51.75+10+7.5+4.75 if HHSTATE=="TX" 

* https://dmv.utah.gov/taxes-fees/uniform-fees#passenger
replace regfee=43+150 if HHSTATE=="UT" & veh_age<3
replace regfee=43+110 if HHSTATE=="UT" & veh_age>2 & veh_age<6
replace regfee=43+80 if HHSTATE=="UT" & veh_age>5 & veh_age<9
replace regfee=43+50 if HHSTATE=="UT" & veh_age>8 & veh_age<12
replace regfee=43+10 if HHSTATE=="UT" & veh_age>11

replace regfee=76 if HHSTATE=="VT"


replace regfee=40.75 if HHSTATE=="VA" & kind=="Car"
replace regfee=45.75 if HHSTATE=="VA" & kind~="Car"

*WA fees are really complicated
* https://www.dol.wa.gov/vehicleregistration/docs/VehicleFees.pdf
replace regfee=38.75+25+80+value_imputed*.011 if HHSTATE=="WA" & HH_CBSA=="42660" & kind=="Car"
replace regfee=38.75+45+80+value_imputed*.011 if HHSTATE=="WA" & HH_CBSA=="42660" & kind~="Car"
replace regfee=38.75+25+30 if HHSTATE=="WA" & HH_CBSA~="42660" & kind=="Car"
replace regfee=38.75+45+30 if HHSTATE=="WA" & HH_CBSA~="42660" & kind~="Car"

*addition WV property taxes assessed by county. not included here
replace regfee=30 if HHSTATE=="WV"

*I've approximated WI local "wheel tax" here
* https://wisconsindot.gov/Pages/dmv/vehicles/title-plates/wheeltax.aspx
replace regfee=75+20 if HHSTATE=="WI"

* also varies a bit by county, but not sure how
replace regfee=30 if HHSTATE=="WY"

save "data/final_data.dta", replace
