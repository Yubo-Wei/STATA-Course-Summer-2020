clear all 
set more off
use ACS_2018.dta,clear
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
//create people in hh
 bys hhid: egen peopleinhh=max(pernum)

// fix food stamp
g temp=(food==2)
drop food
rename temp foodstamp

//creating education variables
g high_sch=(educ>=6) //high-school
g some_col=(educ>=7)  // some college
g col=(educ>=10) //college

//dealing with degrees:
replace degfield=. if degfield==0
drop degfieldd

//fix hours worked:
replace uhrswork=. if uhrswork==0
//fix labor force:
replace labfo=. if labforce==0
g temp=1 if labforce==2
replace temp=0 if labforce==1
drop labforce
rename temp labforce

//part1 
label variable some_col "Has some college" 
// first table for the whole sample 
estpost tabstat inctot ftotinc valueh incwage some_col hotwater shower kitchen, statistics(mean sd count) columns(statistics) 
esttab using "/Users/leewei/Desktop/stata/final/sum_tables/sum_stats1.rtf", replace cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))") noobs nonumbers title("Statistics by whole sample") label
 
 // dealing with the family size variable 
 gen fam1 = (famsize == 1) 
 label variable fam1 "Has 1 person in the household"
 replace fam1 = . if fam1 == 0 
 gen fam2 = (famsize == 2)
 label variable fam2 "Has 2 person in the household"
 replace fam2 = . if fam2 == 0 
 gen fam4 = (famsize == 4)
label variable fam4 "Has 4 person in the household"
replace fam4 = . if fam4 == 0 
// table for 1 person in the household 
estpost tabstat inctot ftotinc valueh incwage some_col hotwater shower kitchen, by(fam1) statistics(mean sd count) columns(statistics) 
esttab using "/Users/leewei/Desktop/stata/final/sum_tables/sum_stats2.rtf", replace cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))") noobs nonumbers title("Statistics by Subgroup: 1 person in the household") label
 //table for 2 person in the household
estpost tabstat inctot ftotinc valueh incwage some_col hotwater shower kitchen, by(fam1) statistics(mean sd count) columns(statistics) 
esttab using "/Users/leewei/Desktop/stata/final/sum_tables/sum_stats3.rtf", replace cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))") noobs nonumbers title("Statistics by Subgroup: 2 people in the household") label
// table for 4 person in the household
estpost tabstat inctot ftotinc valueh incwage some_col hotwater shower kitchen, by(fam1) statistics(mean sd count) columns(statistics) 
esttab using "/Users/leewei/Desktop/stata/final/sum_tables/sum_stats4.rtf", replace cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))") noobs nonumbers title("Statistics by Subgroup: 4 people in the household") label

//part2 

levelsof statefip, local(levels)//create a local called levels which contains every value of statefip.
qui{
foreach l of local levels {
reg incwage uhrswork hotwater shower kitchen if statefip==`l',r  
eststo maj`l'
esttab maj`l' using "/Users/leewei/Desktop/stata/final/reg_tables/reg_for_`:label (statefip) `l''.rtf", replace title("Regression for `:label (statefip) `l''") label  nonumbers drop( _cons) b(%9.3f) se(%9.3f)  starlevels(* 0.1 ** 0.05 *** 0.01) 
}
//multiple tables each named appropriately 
}












