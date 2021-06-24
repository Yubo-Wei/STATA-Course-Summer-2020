/*
Author: Antoine Deeb (antoinedib@ucsb.edu)
Purpose: Final Assignment q2
Economics Department UC Santa Barbara

*/
clear all // clears all data
set more off

use "..\q2\ACS_2018.dta",clear
 

rename serial hhid

replace countyfip=. if countyfip==0 // replace countyfip where missing
// make farm binary
gen farm2=(farm==2)
drop farm
rename farm2 farm 

// Take care of missing income variables
replace inctot=. if inctot==9999999 
replace hhincome =. if hhincome ==9999999
replace ftotinc =. if ftotinc ==9999999
replace incwage =. if incwage ==999999
replace valueh =. if valueh ==9999999

// fix missing hh chars
replace hotwater =. if hotwater ==0
replace shower =. if shower ==0
replace mult =. if mult ==0
replace kitchen =. if kitchen ==0
//make them binary
g have_kitchen=1 if kitchen==4
replace have_kitchen=0 if kitchen==1
label var have_kitchen "Has Kitchen"

g have_shower=1 if shower==4
replace have_shower=0 if shower==1
label var have_shower "Has Shower"
g have_water=1 if hotwater==4
replace have_water=0 if hotwater==3
label var have_water "Has Piped Water"
//create people in hh
 bys hhid: egen peopleinhh=max(pernum)

// fix food stamp
g temp=(food==2)
drop food
rename temp foodstamp

//creating education variables
g high_sch=(educ>=6) //high-school
g some_col=(educ>=7)  // some college
label var some_col "Has Attended College"
g col=(educ>=10) //college
* Note here I don't replace by missing if educ==0. Unfortunately they coded no schooling and missing as the same, this is a mistake with the surveyers.


//dealing with degrees:
replace degfieldd=. if degfieldd==0
drop degfield

//fix hours worked:
replace uhrswork=. if uhrswork==0
//fix labor force:
replace labfo=. if labforce==0
g temp=1 if labforce==2
replace temp=0 if labforce==1
drop labforce
rename temp labforce


*Make summary stats:
  
qui{
estpost sum inctot hhincome valueh incwage some_col have_*

esttab using "..\q2\sum_tables\Q2a.rtf", cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))")  replace label title("Statistics for Whole Sample") noobs mlabels(,none) nonumbers


foreach nb in 1 2 4 {
estpost sum inctot hhincome valueh incwage some_col have_* if peopleinhh==`nb'

esttab using  "..\q2\sum_tables\Q2a`nb'.rtf", replace cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f)) ") label title("Statistics for Households of `nb'") noobs mlabels(,none) nonumbers

}
}


*Make regression tables:

qui{
levelsof state, local(levels)
foreach l of local levels {
reg incwage uhrswork some_col have_* if state==`l',r
eststo maj`l'
esttab maj`l' using "..\q2\reg_tables\Q2b`:label (state) `l''.rtf", replace title("Results for  `:label (state) `l''") label nonumbers  drop( _cons) b(%9.3f) se(%9.3f)  starlevels(* 0.1 ** 0.05 *** 0.01) 
}
}
