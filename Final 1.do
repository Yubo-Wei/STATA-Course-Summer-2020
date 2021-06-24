clear all 
set more off
cd "/Users/leewei/Desktop/stata/final/hnp_stats_csv"
import delimited HNP_StatsData.csv , clear
//Drop last column of NA's and the column that won't be used 
findname , all (missing(@))
drop v65 v64
// rename vars to make them look nicer
rename v1 CountryName
rename v2 CountryCode
rename v3 IndicatorName
rename v4 IndicatorCode
forvalues num = 5/63 {    
local newnum = `num' + 1955
rename v`num' v`newnum'
}
//exercise 1
// generate variables that are associated with the question.
gen high_inc = (CountryName=="High income")
gen low_inc = (CountryName =="Low income")
gen lower_m_inc= (CountryName == "Lower middle income")
gen upper_m_inc= (CountryName =="Upper middle income")
gen birth_rate = (IndicatorCode == "SP.DYN.CBRT.IN")
gen death_rate = (IndicatorCode == "SP.DYN.CDRT.IN")
gen ferti_rate = (IndicatorCode == "SP.DYN.TFRT.IN")
gen life_expect = (IndicatorCode ==  "SP.DYN.LE00.FE.IN")
gen mortality_rate = (IndicatorCode == "SP.DYN.AMRT.FE")
//change the data from wide to long 

isid CountryName-IndicatorCode
reshape long v, i(CountryName-IndicatorCode) j(year)
rename v value 
//make time series of all variables.
//1

twoway (line value year if high_inc== 1&birth_rate==1),ytitle(birth_rate)title(high-birth)
graph save "high-birth.gph", replace
twoway (line value year if low_inc== 1&birth_rate==1),ytitle(birth_rate)title(low-birth)
graph save "low-birth.gph", replace
twoway (line value year if lower_m_inc== 1&birth_rate==1),ytitle(birth_rate)title(lower-birth)
graph save "lower-birth.gph", replace
twoway (line value year if upper_m_inc== 1&birth_rate==1),ytitle(birth_rate)title(upper-birth)
graph save "upper-birth.gph", replace
//combine four regions
graph combine "high-birth.gph" "low-birth.gph" "lower-birth.gph" "upper-birth.gph",title(Population statistics)
graph save "birth_rate.gph",replace
//2

twoway (line value year if high_inc== 1&death_rate==1),ytitle(death_rate)title(high-death)
graph save "high-death.gph", replace
twoway (line value year if low_inc== 1&death_rate==1),ytitle(death_rate)title(low-death)
graph save "low-death.gph", replace
twoway (line value year if lower_m_inc== 1&death_rate==1),ytitle(death_rate)title(lower-death)
graph save "lower-death.gph", replace
twoway (line value year if upper_m_inc== 1&death_rate==1),ytitle(death_rate)title(upper-death)
graph save "upper-death.gph", replace

graph combine "high-death.gph" "low-death.gph" "lower-death.gph" "upper-death.gph",title(Population statistics)
graph save "death_rate.gph",replace
//3

twoway (line value year if high_inc== 1&ferti_rate==1),ytitle(fetility_rate)title(high-ferti)
graph save "high-ferti.gph", replace
twoway (line value year if low_inc== 1&ferti_rate==1),ytitle(fetility_rate)title(low-ferti)
graph save "low-ferti.gph", replace
twoway (line value year if lower_m_inc== 1&ferti_rate==1),ytitle(fetility_rate)title(lower-ferti)
graph save "lower-ferti.gph", replace
twoway (line value year if upper_m_inc== 1&ferti_rate==1),ytitle(fetility_rate)title(upper-ferti)
graph save "upper-ferti.gph", replace

graph combine "high-ferti.gph" "low-ferti.gph" "lower-ferti.gph" "upper-ferti.gph",title(Population statistics)
graph save "ferti_rate.gph",replace

//4

twoway (line value year if high_inc== 1&life_expect==1),ytitle(life_exp_rate)title(high-life_expect)
graph save "high-life_expect.gph", replace
twoway (line value year if low_inc== 1&life_expect==1),ytitle(life_exp_rate)title(low-life_expect)
graph save "low-life_expect.gph", replace
twoway (line value year if lower_m_inc== 1&life_expect==1),ytitle(life_exp_rate)title(lower-life_expect)
graph save "lower-life_expect.gph", replace
twoway (line value year if upper_m_inc== 1&life_expect==1),ytitle(life_exp_rate)title(upper-life_expect)
graph save "upper-life_expect.gph", replace

graph combine "high-life_expect.gph" "low-life_expect.gph" "lower-life_expect.gph" "upper-life_expect.gph",title(Population statistics)
graph save "life_expect.gph",replace

//5

twoway (line value year if high_inc== 1&mortality_rate==1),ytitle(mortality_rate)title(high-mortality)
graph save "high-mortality.gph", replace
twoway (line value year if low_inc== 1&mortality_rate==1),ytitle(mortality_rate)title(low-mortality)
graph save "low-mortality.gph", replace
twoway (line value year if lower_m_inc== 1&mortality_rate==1),ytitle(mortality_rate)title(lower-mortality)
graph save "lower-mortality.gph", replace
twoway (line value year if upper_m_inc== 1&mortality_rate==1),ytitle(mortality_rate)title(upper-mortality)
graph save "upper-mortality.gph", replace

graph combine "high-mortality.gph" "low-mortality.gph" "lower-mortality.gph" "upper-mortality.gph",title(Population statistics)
graph save "mortality_rate.gph",replace

//exercise 2
//generate four countries' variables
gen usa = (CountryName=="United States")
gen ger = (CountryName=="Germany")
gen swe = (CountryName=="Sweden")
gen jap = (CountryName=="Japan")
//do the same thing as above
//1
twoway (line value year if usa== 1&birth_rate==1),ytitle(birth_rate)title(usa-birth)
graph save "usa-birth.gph", replace
twoway (line value year if ger== 1&birth_rate==1),ytitle(birth_rate)title(ger-birth)
graph save "ger-birth.gph", replace
twoway (line value year if swe== 1&birth_rate==1),ytitle(birth_rate)title(swe-birth)
graph save "swe-birth.gph", replace
twoway (line value year if jap== 1&birth_rate==1),ytitle(birth_rate)title(jap-birth)
graph save "jap-birth.gph", replace

graph combine "usa-birth.gph" "ger-birth.gph" "swe-birth.gph" "jap-birth.gph",title(Population statistics)
graph save "birth_rate_us_ge_sw_ja.gph",replace

//2

twoway (line value year if usa== 1&death_rate==1),ytitle(death_rate)title(usa-death)
graph save "usa-death.gph", replace
twoway (line value year if ger== 1&death_rate==1),ytitle(death_rate)title(ger-death)
graph save "ger-death.gph", replace
twoway (line value year if swe== 1&death_rate==1),ytitle(death_rate)title(swe-death)
graph save "swe-death.gph", replace
twoway (line value year if jap== 1&death_rate==1),ytitle(death_rate)title(jap-death)
graph save "jap-death.gph", replace

graph combine "usa-death.gph" "ger-death.gph" "swe-death.gph" "jap-death.gph",title(Population statistics)
graph save "death_rate_us_ge_sw_ja.gph",replace


//3

twoway (line value year if usa== 1&ferti_rate==1),ytitle(fetility_rate)title(usa-ferti)
graph save "usa-ferti.gph", replace
twoway (line value year if ger== 1&ferti_rate==1),ytitle(fetility_rate)title(ger-ferti)
graph save "ger-ferti.gph", replace
twoway (line value year if swe== 1&ferti_rate==1),ytitle(fetility_rate)title(swe-ferti)
graph save "swe-ferti.gph", replace
twoway (line value year if jap== 1&ferti_rate==1),ytitle(fetility_rate)title(jap-ferti)
graph save "jap-ferti.gph", replace

graph combine "usa-ferti.gph" "ger-ferti.gph" "swe-ferti.gph" "jap-ferti.gph",title(Population statistics)
graph save "ferti_rate_us_ge_sw_ja.gph",replace


//4

twoway (line value year if usa== 1&life_expect==1),ytitle(life_exp_rate)title(usa-life_expect)
graph save "usa-life_expect.gph", replace
twoway (line value year if ger== 1&life_expect==1),ytitle(life_exp_rate)title(ger-life_expect)
graph save "ger-life_expect.gph", replace
twoway (line value year if swe== 1&life_expect==1),ytitle(life_exp_rate)title(swe-life_expect)
graph save "swe-life_expect.gph", replace
twoway (line value year if jap== 1&life_expect==1),ytitle(life_exp_rate)title(jap-life_expect)
graph save "jap-life_expect.gph", replace

graph combine "usa-life_expect.gph" "ger-life_expect.gph" "swe-life_expect.gph" "jap-life_expect.gph",title(Population statistics)
graph save "life_expect_us_ge_sw_ja.gph",replace

//5

twoway (line value year if usa== 1&mortality_rate==1),ytitle(mortality_rate)title(usa-mortality)
graph save "usa-mortality.gph", replace
twoway (line value year if ger== 1&mortality_rate==1),ytitle(mortality_rate)title(ger-mortality)
graph save "ger-mortality.gph", replace
twoway (line value year if swe== 1&mortality_rate==1),ytitle(mortality_rate)title(swe-mortality)
graph save "swe-mortality.gph", replace
twoway (line value year if jap== 1&mortality_rate==1),ytitle(mortality_rate)title(jap-mortality)
graph save "jap-mortality.gph", replace

graph combine "usa-mortality.gph" "ger-mortality.gph" "swe-mortality.gph" "jap-mortality.gph",title(Population statistics)
graph save "mortality_rate_us_ge_sw_ja.gph",replace

//exercise 3

//clear useless vars
keep if usa==1|ger==1|swe==1|jap==1

keep if birth_rate ==1|death_rate==1|ferti_rate ==1|life_expect ==1|mortality_rate==1
//take the average minimum maximum for each var, by year
//1 
gen value_birth = value if birth_rate==1
bys year: egen birth_rate_max = max(value_birth)
bys year: egen birth_rate_min = min(value_birth)
bys year: egen birth_rate_avg = mean(value_birth)

//2
gen value_death = value if death_rate==1
bys year: egen death_rate_max = max(value_death)
bys year: egen death_rate_min = min(value_death)
bys year: egen death_rate_avg = mean(value_death)

//3

gen value_ferti = value if ferti_rate==1
bys year: egen ferti_rate_max = max(value_ferti)
bys year: egen ferti_rate_min = min(value_ferti)
bys year: egen ferti_rate_avg = mean(value_ferti)

//4

gen value_life_expect = value if life_expect==1
bys year: egen life_expect_max = max(value_life_expect)
bys year: egen life_expect_min = min(value_life_expect)
bys year: egen life_expect_avg = mean(value_life_expect)

//5

gen value_mortality = value if mortality_rate==1
bys year: egen mortality_rate_max = max(value_mortality)
bys year: egen mortality_rate_min = min(value_mortality)
bys year: egen mortality_rate_avg = mean(value_mortality)

//range plot 
//1
twoway (rarea birth_rate_max birth_rate_min year, fcolor(%20))(line birth_rate_avg year),ytitle(birth_rate) title(Time series of birth_rate)
graph save "birth_rate_rangplot4countries.gph"

//2
twoway (rarea death_rate_max death_rate_min year, fcolor(%20))(line death_rate_avg year),ytitle(death_rate) title(Time series of death_rate)
graph save "death_rate_rangplot4countries.gph"

//3
twoway (rarea ferti_rate_max ferti_rate_min year, fcolor(%20))(line ferti_rate_avg year),ytitle(ferti_rate) title(Time series of ferti_rate)
graph save "ferti_rate_rangplot4countries.gph"

//4
twoway (rarea life_expect_max life_expect_min year, fcolor(%20))(line life_expect_avg year),ytitle(life_expect) title(Time series of life_expect)
graph save "life_expect_rangplot4countries.gph"

//5
twoway (rarea mortality_rate_max mortality_rate_min year, fcolor(%20))(line mortality_rate_avg year),ytitle(mortality_rate) title(Time series of mortality_rate)
graph save "mortality_rate_rangplot4countries.gph"





