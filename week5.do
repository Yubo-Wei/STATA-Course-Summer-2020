/*
Date: 8/06/20
Author: Antoine Deeb (antoinedib@ucsb.edu)
Pupose: Review Lecture  - Stata Skills Summer 2020
Economics Department UC Santa Barbara

*/
clear all // clears all data
set more off
*Set directory:

    if c(username)=="antoi" {
cd "C:\Users\antoi\Dropbox\STATA class - Summer 2020\week 5"
  }
    if c(username)=="Antoine" {
cd "D:\Dropbox\Dropbox\STATA class - Summer 2020\week 5"
  }
use ACS_2018.dta,clear
 
log using week5, replace text name("Week_5_Log") //opening a log

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
