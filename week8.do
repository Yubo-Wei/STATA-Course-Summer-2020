/* 
Date: 7/25/20
Author: Jaime Ramirez (jramirezcuellar@ucsb.edu)
Purpose: Lecture 15 & 16 - Stata Skills Summer 2020
Economics Department UC Santa Barbara

What we will learn this week:

 0. Recap from previous week
 1. Working with a dataset
	charlist and findname commands
 
*/



********************************
***** 0. Recap from week 7 *****

clear all
set more off

** 0.1 Exporting summary statistics
webuse nlswork, clear	

estpost summarize ln_wage wks_work
esttab using sum_stats.rtf, cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))")  replace label title("Statistics for Whole Sample") noobs  nonumbers

** 0.2 Create table of summary statistics of log wage and hours work by race
estpost tabstat ln_wage wks_work, by(race) statistics(mean sd count) columns(statistics) // tabstat's advantage is being able to do it by category, we can use by() to do that.

* 0.2.1 Output in word file
esttab using sum_stats2.rtf, replace cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))") noobs nonumbers title("Statistics by Subgroup") label

** 0.3 Regression
regress ln_wage wks_work race age
esttab using "reg_ln_wage.rtf", replace title("Log Real Wage") label nonumbers  drop( _cons) b(%9.3f) se(%9.3f)  starlevels(* 0.1 ** 0.05 *** 0.01) 


******************************************
***** 1. Importing the CDIS data set *****
import delimited "CDIS_08-24-2018 23-13-53-61_timeSeries.csv", encoding(UTF-8) clear

* 1.1 Describe variables
describe

* df is in wide format (years in columns)
* What is the primary key? (Country.Code, CounterPart.Country.Name and Indicator.Code)

* 1.2 Use list + if to print first 5 rows
list if _n <= 5

* 1.3 Use tabulate to show absolute frequency of a specific variable
tabulate indicatorname
tabulate countrycode
tabulate countryname

* 1.4 Use browse to see data
browse

*****************************************************************

*** 2 Tidy the df  *******

* 2.1 Drop last column of NA's (not desired when reading csv)
* Let's use a user written command by Nick Cox
help findname // it is likely it is not in your database
cap ssc install findname // it installs the package
findname, all(missing(@))
drop v17

* 2.1.1 Let's save variable names from v (year names) 
forvalues num = 8/16{
	global v`num'_name : variable label v`num'
}
macro list // labels saved; we'll use them later

** 2.2 change from wide to long
isid countrycode-attribute
reshape long v, i(countrycode-attribute) j(year)

* 2.2.1 New variable v takes character (string) values "" and "C"
describe v
cap ssc install charlist // installs charlist
help charlist // list characters in a string variable
charlist v // it takes sometime to run 
* the result should be: -.0123456789CE
br v if strpos(v,"C")>0 // shows observations with "C" in variable v
* C stands for condifendtial (CDIS documentation)
br v if strpos(v,"E")>0 // shows observations with "E" in variable v
* observations with E are in a number format

* 2.2.2 We should replace those values with "C" before trying to destring
replace v = "" if v == "C"

* 2.2.3 Destring v 
destring v, generate(value)
br v* if strpos(v,"E")>0 // shows observations with "E" in variable v
* they look good

* 2.3 tabulate variable year
tabulate year // odd year convention
describe year

* 2.3.1 Replace year with their true meaning
forvalues num = 8/16 {
	replace year = ${v`num'_name} if year == `num'
	// note the use of {} to specify the global
}

* 2.4.1 Observations when Attribute=="Status"
tabulate attribute

* 2.4.2 What is "Status"? "Value"?

* 2.4.3 What values does "vv" take when attribute=="Status"?
tab value if attribute=="Status"
* Status has two values "C" and ""
* We might delete these observations to ease computations and memory

* Delete observations (rows) where attribute == "Status"
drop if attribute=="Status"

* We do have tons of missings in our column value
* We might not want to delete them

compress // compress the data for efficient saving; it will help with merge later too
save cdis0.dta, replace

*******************************************************

* 3.1 We could have replaced all values "C" and "" using original data
import delimited "CDIS_08-24-2018 23-13-53-61_timeSeries.csv", encoding(UTF-8) clear

forvalues num = 8/16 {
local newnum = `num' + 2000
rename v`num' v`newnum'
}
drop v17

/*
Alternatively,
ren v8 v2008
ren v9 v2009
ren v* v20*
*/

* 3.2 Using a loop to replace variable v with "C" and destring
forvalues num = 2008/2016 {
	replace v`num' = "" if v`num' == "C"    // check positions in column i where the condition is met
	destring v`num', replace
 }


reshape long v, i(countrycode-attribute) j(year)
rename v value
drop if attribute == "Status" // (1,164,096 observations deleted)

*******************************************************

* 4. Split columns

* 4.1 Print unique values of indicatorname
tab indicatorname

* 4.2 We want to split indicatorname into 3 columns
split indicatorname, parse(,) 
tab indicatorname1
tab indicatorname2, m
tab indicatorname3, m

* 4.2.1 Check if it is doing what you expected
assert strpos(indicatorname,"US Dollars")>0 // "US Dollars" appears in all observations
replace indicatorname3 = "US Dollars"
replace indicatorname2 = "" if strpos(indicatorname2,"US Dollars")>0 

rename indicatorname3 currency
encode indicatorname2, generate(derived)
drop indicatorname2

* 4.3 There's still information in indicatorname0
br indicatorname1
 
* 4.3.1 We want to create a new variable that tells "Net" or "Gross" depending on indicatorname0
generate gross = 1 if strpos(indicatorname1,"Gross")>0
replace gross = 0 if strpos(indicatorname1,"Gross") == 0
generate net = 1 if strpos(indicatorname1,"Net")>0
replace net = 0 if strpos(indicatorname1,"Net") == 0
gen sum = net + gross
tab sum, m // not all observations are either gross==1 or net==1
drop sum
cap assert net==1 | gross==1 // other way to check

* 4.3.2 Remove info from indicatorname0
replace indicatorname1 = subinstr(indicatorname1,"(Gross)","",.)
replace indicatorname1 = subinstr(indicatorname1,"(Net)","",.)

* 4.3.3 Trim indicatorname1
replace indicatorname1 = stritrim(indicatorname1)

drop indicatorname indicatorname1 currency derived gross net

*****************************************************
* 5.1 Reshape the data to be wide using Indicator.Code
reshape wide value, i(countrycode countryname counterpartcountryname counterpartcountrycode attribute year) j(indicatorcode) string

* 5.2 Save data for use
compress 
save cdis_wide, replace

****************************************************
* 6 Create a database by country where columns are the iso codes

* 6.1.1 Read metadata from CDIS
import delimited "Metadata_CDIS_08-24-2018 23-13-53-61_timeSeries.csv", encoding(UTF-8) clear

* 6.1.2 Select columns Country.Name,Metadata.Attribute,Metadata.Value and filter by Country.Name not equal to ""
keep countryname metadataattribute metadatavalue
keep if countryname != ""

* 6.1.3 Create names for each code
replace metadataattribute = subinstr(metadataattribute,"Country ","",.)
replace metadataattribute = subinstr(metadataattribute," ","_",.)

* 6.1.4 Reshape from long to wide
br
isid countryname metadataattribute
reshape wide metadatavalue, i(countryname) j(metadataattribute) string
br
rename metadatavalue* *

* 6.1.5 Check if it is uniquely identified by ISO_2_Code
cap isid ISO_2_Code

* 6.1.6 Check for NA's and ""
list countryname if ISO_2_Code == ""
	// Bouvet Island, Heard Island and McDonald Islands,
	// Not Specified (including Confidential)
list countryname if ISO_2_Code == "NA"
	// Namibia

* 6.1.7 Change manually
replace ISO_2_Code = "BV" if countryname == "Bouvet Island"
replace ISO_2_Code = "HM" if countryname == "Heard Island and McDonald Islands"

* 6.1.8 Filter observations where ISO_2_Code is not deleted
list if ISO_2_Code == ""
drop if ISO_2_Code == ""

* 6.1.9 Check that ISO_2_Code uniquely identifies data
isid ISO_2_Code

assert countryname == Name
rename Name CDIS_Name
rename Code CDIS_Code

* 6.1.10 Make a copy
compress
save cdis_country.dta, replace

******************************************************

* 6.2.1 Read iso codes from website
import delimited "https://raw.githubusercontent.com/lukes/ISO-3166-Countries-with-Regional-Codes/master/all/all.csv", clear

* 6.2.2 Clean iso_3166.2
tab iso_3166
replace iso_3166 = subinstr(iso_3166,"ISO 3166-2:","",.)

* 6.2.3 Check that iso_3166 and alpha2 are equal
assert iso_3166 == alpha2

* 6.2.4 Check if iso_3166 and alpha2 uniquely identify the dataset
isid iso_3166
isid alpha2

* 6.2.6 Check that primary keys have equal names in both cdis_country and current dataset
* cdis_country is uniquely identified by ISO_2_Code (see 6.1.9)

* 6.2.7 Rename if necessary
rename iso_3166  ISO_2_Code
rename alpha3  ISO_3_Code

* 6.3 Join datasets
merge 1:1 ISO_2_Code using cdis_country

* 6.3.1 Check whatever was not matched
br if _merge == 1
br if _merge == 2
list if _merge != 3
br if _merge != 3

* 6.3.2 It does not matter so we drop those observations
drop if _merge != 3

compress
save codes.dta, replace

***********************************************************
* Create variable region == 1 if territory is a region in original dataset

* 7.1 Change name of Country.Code
use cdis_country.dta, clear 
rename CDIS_Code countrycode // to merge with cdis0.dta (see 2.4)

destring countrycode, replace

* 7.2 Perform merge of cdis0 and cdis_country
merge 1:m countrycode using cdis0


* 7.4 Create region if row was not matched with country data
tab countryname if ISO_2_Code == ""
gen region = 1 if ISO_2_Code == ""
compress 
save cdis1, replace

***********************************************************
* 8. Read region

* 8.1 Read data
import delimited "cdis_region.csv", varnames(1) clear 

* 8.2 Rename, sort, isid by countryname
rename *countryname countryname
sort region countryname
isid countryname 

* 8.3 Create new variable in both datasets
gen countryname2 = countryname

preserve
	use cdis_country, clear
	gen countryname2 =  countryname
	compress 
	tempfile cdis_country
	save `cdis_country', replace
restore	

compress 
save cdis_region.dta, replace

* 8.4 Join with cdis_country
merge 1:1 countryname2 using `cdis_country'

* 8.4.1 Some names were not matched
sort countryname2
br if _merge != 3

* 8.4.2 Manual Match: change manually names of countryname in region data
use cdis_region, clear

replace countryname="Afghanistan, Islamic Republic of" if countryname == "Afghanistan, Islamic State of"
replace countryname="Azerbaijan, Republic of" if countryname == "Azerbaijan"
replace countryname="Armenia, Republic of" if countryname == "Armenia"
replace countryname="British Indian Ocean Territory" if countryname == "British Indian Ocean Territories"
replace countryname="Bahrain, Kingdom of" if countryname == "Bahrain"
replace countryname="China, P.R.: Hong Kong" if countryname == "China,P.R.: Hong Kong"
replace countryname="China, P.R.: Macao" if countryname == "China,P.R.: Macao"
replace countryname="China, P.R.: Mainland" if countryname == "China,P.R.: Mainland"
replace countryname="Congo, Democratic Republic of" if countryname == "Congo, Dem. Rep. of"
replace countryname="Congo, Republic of" if countryname == "Congo, Rep. of"
replace countryname="Cote d'Ivoire" if countryname == "CÃ´te d'Ivoire"
replace countryname="Equatorial Guinea" if countryname == "Equatorial  Guinea"
replace countryname="Falkland Islands" if countryname == "Falkland Islands (Malvinas)"
replace countryname="French Territories: French Polynesia" if countryname == "French Polynesia"
replace countryname="French Territories: New Caledonia" if countryname == "New Caledonia"
replace countryname="Guiana, French" if countryname == "French Guiana"
replace countryname="Heard Island and McDonald Islands" if countryname == "Heard Island and McDonald"
replace countryname="Kosovo, Republic of" if countryname == "Kosovo"
replace countryname="Korea, Democratic People's Rep. of" if countryname == "Korea, Democratic People's Republic of"
replace countryname="Libya" if countryname == "Libyan Arab Jamahiriya"
replace countryname="Marshall Islands, Republic of" if countryname == "Marshall Islands"
replace countryname="Montenegro" if countryname == "Montenegro, Republic of"
replace countryname="Northern Mariana Isl" if countryname == "Northern Mariana Islands"
replace countryname="Pitcairn Islands" if countryname == "Pitcairn"
replace countryname="Reunion" if countryname == "RÃ©union"
replace countryname="Saint Helena" if countryname == "St. Helena"
replace countryname="Saint Pierre and Miquelon" if countryname == "St. Pierre and Miquelon"
replace countryname="Sao Tome and Principe" if countryname == "SÃ£o TomÃ© and PrÃ­ncipe"
replace countryname="South Georgia and Sandwich Islands" if countryname == "South Georgia and Sandwich"
replace countryname="Timor-Leste, Dem. Rep. of" if countryname == "Timor-Leste"
replace countryname="Tokelau Islands" if countryname == "Tokelau"
replace countryname="US Virgin Islands" if countryname == "Virgin Islands, U.S."
replace countryname="Vatican" if countryname == "Vatican City State"
replace countryname="Venezuela, República Bolivariana de" if countryname == "Venezuela, RepÃºblica Bolivariana de"
replace countryname="Wallis and Futuna" if countryname == "Wallis and Fatuna Islands"
replace countryname="West Bank and Gaza" if countryname == "West Bank and Gaza Strip"

* 8.3 Create new variable in both datasets
drop countryname2
gen countryname2 = countryname

* 8.4.3 Try merge again

preserve
	use cdis_country, clear
	gen countryname2 =  countryname
	compress 
	tempfile cdis_country
	save `cdis_country', replace
restore	

merge 1:1 countryname2 using `cdis_country'

* 8.4.1 Some names were not matched?
assert _merge == 3
drop _merge 

* 8.5 Rename dataset
destring CDIS_Code, replace
rename CDIS_Code countrycode
compress
keep countryname countrycode region
save cdis_region, replace


***********************************************************
* 9 Merge country data with region variable (cdis_wide and cdis_country)

* 9.1 Merge data
use cdis_wide, clear
merge m:1 countrycode using cdis_region
tab countryname if _merge == 1, m // not matched rows correspond to regions
assert _merge == 1 | region != "" // using conditionals
drop _merge

* 9.2 Add region for counterpart country
* 9.2.1 Change name in country-region dataset
preserve
	 use cdis_region, clear
	 rename countrycode counterpartcountrycode
	 rename region counterpartcountryregion	 
	 tempfile cdis_region
	 save `cdis_region', replace
restore

* 9.2.2 Merge data
merge m:1 counterpartcountrycode using `cdis_region'
tab counterpartcountryname if _merge == 1, m // not matched rows correspond to regions
assert _merge == 1 | counterpartcountryregion != "" // using conditionals
drop _merge

* 9.3 Order data
order countryname countrycode region counterpart* 

* 9.4 Save as cdis_wide2\
save cdis_wide2.dta, replace

***********************************************************
* 10 Summary tables

* 10.1 Sum all variables that are numeric by country and year
use cdis_wide2, clear
 
des value*, varlist
global vars = "`r(varlist)' "
br if counterpartcountryregion == "" 
br if region == "" 
drop if region == "" | counterpartcountryregion == "" // drop observations that are country groupings
collapse (sum) $vars, by(countrycode countryname year)

export excel using "cdis_summary", sheet("country_level") sheetreplace firstrow(varlabels)
	
* 10.2 Sum all variables that are numeric by region and year
use cdis_wide2.dta, clear
drop if region == "" | counterpartcountryregion == "" // drop observations that are country groupings
collapse (sum) $vars, by(region year)

export excel using "cdis_summary", sheet("region_level") sheetreplace firstrow(varlabels)
 
* 10.3 Sum all variables that are numeric by counterpart country and year
use cdis_wide2.dta, clear
drop if region == "" | counterpartcountryregion == "" // drop observations that are country groupings
collapse (sum) $vars, by(counterpartcountrycode counterpartcountryname year)

export excel using "cdis_summary", sheet("counterpartcountry_level") sheetreplace firstrow(varlabels)

* 10.4 Sum all variables that are numeric by counterpart country's region and year
use cdis_wide2.dta, clear
drop if region == "" | counterpartcountryregion == "" // drop observations that are country groupings
collapse (sum) $vars, by(counterpartcountryregion year)

export excel using "cdis_summary", sheet("counterpartcountryregion_level") sheetreplace firstrow(varlabels)
