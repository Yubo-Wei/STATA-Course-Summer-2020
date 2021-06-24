/* 
Date: 8/12/20
Author: Jaime Ramirez (jramirezcuellar@ucsb.edu)
Purpose: Solution question 1
Economics Department UC Santa Barbara
 
*/

** Reading data and organizing years
clear all
import delimited "..\data\HNP_StatsData.csv", varnames(1) encoding(UTF-8) clear

describe v*, varlist
local vars = r(varlist)

local year = 1960  // first year is 1960; see HNP_StatsData.csv
foreach var of local vars {
	rename `var' value`year'
	local year = `year' + 1
}

* Reshape wide to long
isid countryname-indicatorcode
reshape long value, i(countryname-indicatorcode) j(year)
isid countryname-indicatorcode year

** Select sample 5 series
keep if indicatorname == "Birth rate, crude (per 1,000 people)" | ///
	indicatorname == "Death rate, crude (per 1,000 people)" | ///
	indicatorname == "Fertility rate, total (births per woman)" | ///
	indicatorname == "Life expectancy at birth, female (years)" | ///
	indicatorname == "Mortality rate, adult, female (per 1,000 female adults)" 
	
* Select sample 4 regions	
keep if countryname == "High income" | ///
	countryname == "Low income" | ///
	countryname == "Lower middle income" | ///
	countryname == "Upper middle income" | ///
	countryname == "United States" | ///
	countryname == "Sweden" | ///
	countryname == "Germany" | ///
	countryname == "Japan" 
	
* Select sample	years
keep if year <= 2018

* New short name
gen short_name = ""
replace short_name = "birth_rate" if indicatorname == 	"Birth rate, crude (per 1,000 people)" 
replace short_name = "death_rate" if indicatorname == "Death rate, crude (per 1,000 people)" 
replace short_name = "fertility_rate" if indicatorname == "Fertility rate, total (births per woman)" 
replace short_name = "life_exp" if indicatorname == "Life expectancy at birth, female (years)" 
replace short_name = "mortality_rate" if indicatorname == "Mortality rate, adult, female (per 1,000 female adults)" 

* Reshape long to wide and rename
reshape wide value, i(countryname-indicatorcode year) j(short_name) string
rename value* *

* Label
label variable birth_rate "Birth rate, crude (per 1,000 people)" 
label variable death_rate "Death rate, crude (per 1,000 people)"
label variable fertility_rate "Fertility rate, total (births per woman)"
label variable life_exp "Life expectancy at birth, female (years)"
label variable mortality_rate "Mortality rate, adult, female (per 1,000 female adults)"

* Plot and save
local if_high `"if countryname == "High income" "'
local if_low `"if countryname == "Low income" "'
local if_lowmid `"if countryname == "Lower middle income" "'
local if_upmid `"if countryname == "Upper middle income" "'

foreach var of varlist birth_rate death_rate fertility_rate life_exp mortality_rate {
	twoway (line `var' year `if_high') (line `var' year `if_low') ///
	(line `var' year `if_lowmid') (line `var' year `if_upmid'), ///
	legend(order(1 "High income" 2 "Low income" 3 "Lower middle income" 4 "Upper middle income")) title(Population Statistics)
	graph export "../figs/`var'.jpg", as(jpg) replace
}

** Problem 2

* Plot and save
local if_ger `"if countryname == "Germany" "'
local if_ja `"if countryname == "Japan" "'
local if_swe `"if countryname == "Sweden" "'
local if_usa `"if countryname == "United States" "'

foreach var of varlist birth_rate death_rate fertility_rate life_exp mortality_rate {
	twoway (line `var' year `if_ger') (line `var' year `if_ja') ///
	(line `var' year `if_swe') (line `var' year `if_usa'), ///
	legend(order(1 "Germany" 2 "Japan" 3 "Sweden" 4 "USA")) title(Population Statistics)
	graph export  "../figs/`var'_GE_JA_SW_US.jpg", as(jpg) replace
}

** Problem 3

* save labels for later usage
local vars "birth_rate death_rate fertility_rate life_exp mortality_rate"
foreach var of local vars {
	local l`var': variable label `var'
}
macro list
* Select sample of four countries
preserve
keep if countryname == "United States" | ///
	countryname == "Sweden" | ///
	countryname == "Germany" | ///
	countryname == "Japan" 

local tocollapse ""
foreach var of varlist birth_rate death_rate fertility_rate life_exp mortality_rate {
	local tocollapse "`tocollapse' (mean) `var'_avg = `var' "
	local tocollapse "`tocollapse' (min) `var'_min = `var' "
	local tocollapse "`tocollapse' (max) `var'_max = `var' "
}	
	
collapse `tocollapse', by(year)

* Plot range plots
local vars "birth_rate death_rate fertility_rate life_exp mortality_rate"
foreach var of local vars  {
	twoway (rarea `var'_max `var'_min year, fcolor(%20) lcolor(%20)) ///
	(line `var'_avg year), ytitle("`l`var''") legend(order(1 "min-max" 2 "average")) title("Population statistics for Germany, Japan, Sweden, USA") 
	graph export "../figs/`var'_rangeplot4countries.jpg", as(jpg) replace
}
