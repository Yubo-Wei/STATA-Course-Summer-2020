/* 
Date: 7/25/20
Author: Jaime Ramirez (jramirezcuellar@ucsb.edu)
Purpose: Lecture 11 & 12 - Stata Skills Summer 2020
Economics Department UC Santa Barbara

What we will learn this week:

 0. Recap from previous weeks 
 1. Plots and Graphs
 2. Locals and globals
 3. Loops
 4. Return list, scalars, and matrices 
 5. More on locals
 6. Temporary files and variables 
 
*/



***************************************
***** 0. Recap from week 4 *****

clear all
set more off

** 0.1 Merging dataset **
use nlswork_constant, clear

merge 1:m idcode using nlswork_yearly
assert _merge == 3

** 0.2 Reshape **
webuse iris, clear

generate id_obs = _n
label variable id_obs "Observation ID"
isid id_obs

* A long reshape 
reshape long sep pet, i(id_obs) j(measurement) string

rename sep valuesepal
rename pet valuepetal

* A second reshape
reshape long value, i(id_obs measurement) j(part) string

replace measurement = "length" if measurement == "len"
replace measurement = "width" if measurement == "wid"

****************************
***  1. Plots and Graphs ***

/*
	When done well, plots are extremely useful to communicate ideas or data
*/

** 1.1 Scatterplots **

* 1.1.1 Let's open the Nasdaq and S&P 500 dataset
use nasdaq_sp500.dta, clear
browse  
isid month_sif index
isid year month index

* 1.1.2 Let's do first a scatter plot of variables open and volume (are they correlated?)

* 1.1.2.1 We'll use the click menus 

* 1.1.2.2 in Stata syntax:
twoway (scatter open volume)

* 1.1.3 Do a scatter plot of variables open and volume (are they correlated?) by index ("ixic" and "gspc")

* 1.1.3.1 We'll use the click menus 

* 1.1.3.2 in Stata syntax:
twoway (scatter open volume if index == "ixic") (scatter open volume if index == "gspc") // red points are NASDAQ; blue points are S&P 500

* 1.1.4 Do two scatter plots of variables open and volume (are they correlated?) one plot by index value ("isix" and "gspc")
twoway (scatter open volume if index == "ixic")
twoway (scatter open volume if index == "gspc")

** 1.2 Time series plots **

/* Time series plots are lineplots in Stata that have time or dates on the x axis and some economic variable on the y axis.
*/

* 1.2.1 Plot close as a time series plot for index == "ixic" (using menu clicks)

* 1.2.2 Plot close as a time series plot (using Stata syntax)
twoway (line close month_sif if index == "ixic")

* 1.2.3 Do the same as in 1.2.2 using index == "gspc"
twoway (line close month_sif if index == "gspc")

* 1.2.4 Plot close as a time series plot for both index == "isix" and index == "gspc"
twoway (line close month_sif if index == "ixic") (line close month_sif if index == "gspc")

* 1.2.5 Plot close_pgrowth as a time series plot for both index == "isix" and index == "gspc"
twoway (line close_pgrowth month_sif if index == "ixic") (line close_pgrowth month_sif if index == "gspc")

* 1.2.6 Plot high and low as a time series plot for both index == "isix" and index == "gspc"
twoway (line close_pgrowth month_sif if index == "ixic") (line close_pgrowth month_sif if index == "gspc") (line high_pgrowth month_sif if index == "ixic") (line high_pgrowth month_sif if index == "gspc")

** 1.3 Legends and titles **

* 1.3.1 Let's come back to the scatterplot of open and volume for NASDAQ (index == "ixic")
twoway (scatter open volume if index == "ixic") // no title, no axes' titles

* 1.3.2 Click on menus to input titles
twoway (scatter open volume if index == "ixic"), ytitle(Index) xtitle(Volume) title(NASDAQ Index and Volume (2019-2020)) 

* 1.3.2 Close index growth (From 1.2.6 )
twoway (line close_pgrowth month_sif if index == "ixic") (line close_pgrowth month_sif if index == "gspc") // legend and y axis title are not readable

* 1.3.4 Customize plot using click-on menus

* 1.3.5 Customize using legend and order
twoway (line close_pgrowth month_sif if index == "ixic") (line close_pgrowth month_sif if index == "gspc"), ytitle(monthly change (%)) title(US Stock Exchange Indexes) legend(on order(1 "NASDAQ" 2 "S&P500"))
 
** 1.4 Range plots **

* Useful for confidence bands or forecast regions
* We will plot the range of the NASDAQ and S&P500 index 

* 1.4.1 Click-on menus 
 
* 1.4.2 
twoway (rarea high low month_sif if index == "ixic", fcolor(%20)), ytitle(Index) title(NASDAQ High-Low Index)

** 1.5 Histograms ** 
webuse nlswork, clear

* 1.5.1 Click on menus: histogram of log wage

* 1.5.2 Stata syntax: histogram of log wage
histogram ln_wage

* 1.5.3 A nicer histogram of log wage by race 
twoway (histogram ln_wage if race == 1, fcolor(green%20) lcolor(%20)) (histogram ln_wage if race == 2, fcolor(cranberry%20) lcolor(%20))

* 1.5.4  An even nicer histogram of log wage by race
twoway (histogram ln_wage if race == 1, fcolor(green%20) lcolor(%20)) (histogram ln_wage if race == 2, fcolor(cranberry%20) lcolor(%20)), legend(order(1 "White" 2 "Black"))

** 1.6 Saving your plots **
webuse nlswork, clear

histogram ln_wage

* 1.6.1 click-on menus

* 1.6.2 Stata syntax
graph export "nls_ln_wage.png", as(png) replace

** 1.7 Table of graphs ** 

* 1.7.1.1 histogram of log wage by race in 1968
twoway (histogram ln_wage if race == 1, fcolor(green%20) lcolor(%20)) (histogram ln_wage if race == 2, fcolor(cranberry%20) lcolor(%20)) if year == 68, title(1968) legend(order(1 "White" 2 "Black"))

graph save "lnWageByRace_y68.gph", replace

* 1.7.1.2 histogram of log wage by race in 1973
twoway (histogram ln_wage if race == 1, fcolor(green%20) lcolor(%20)) (histogram ln_wage if race == 2, fcolor(cranberry%20) lcolor(%20)) if year == 73, title(1973) legend(order(1 "White" 2 "Black"))

graph save "lnWageByRace_y73.gph", replace

* 1.7.1.3 histogram of log wage by race in 1978
twoway (histogram ln_wage if race == 1, fcolor(green%20) lcolor(%20)) (histogram ln_wage if race == 2, fcolor(cranberry%20) lcolor(%20)) if year == 78, title(1978) legend(order(1 "White" 2 "Black"))

graph save "lnWageByRace_y78.gph", replace

* 1.7.1.4 histogram of log wage by race in 1983
twoway (histogram ln_wage if race == 1, fcolor(green%20) lcolor(%20)) (histogram ln_wage if race == 2, fcolor(cranberry%20) lcolor(%20)) if year == 83, title(1983) legend(order(1 "White" 2 "Black"))

graph save "lnWageByRace_y83.gph", replace

* 1.7.2 Use command graph combine to create table of plots
graph combine "lnWageByRace_y68.gph" "lnWageByRace_y73.gph" "lnWageByRace_y78.gph" "lnWageByRace_y83.gph" 

*****************************
*** 2. Locals and globals ***

/* locals and globals are examples of macros (help macro)

	Fomal definition of a macro by Stata:
	
	"A macro has a macro name and macro contents. Everywhere a punctuated macro name appears in a command— punctuation is defined below—the macro contents are substituted for the macro name." (available on https://www.stata.com/manuals13/pmacro.pdf)

	a macro is some information that you input to Stata that can be recovered for later use
	
	globals can be restored anytime during a Stata session
	
	locals can be only restore within a specific program or do file
	
	global names can be up to 32 characters long
	
	local names can be up to 31 characters long
	
	although, they are very useful do not overdo it
	
	Let's see some examples
*/

webuse nlswork, clear

** 2.1 Assigning globals & locals ** 
* Use command global to assign globals
global 	myglobal_1 	= 2 			// first way of assigning globals
global 	myglobal_2  "some text"	// second way of assigning globals
global 	myglobal_3 	newvar			// second way of assigning globals
local 	mylocal_1 	= 2
local 	mylocal_2 	"some text"
local 	mylocal_3 	newvar

** 2.2 What macros are active in the current session? **
macro list // it will print the current macros (globals and locals) to the results windows

** 2.3 Using globals **
* use $ and the name of your global to call your globals
display "$myglobal_1"
display "$myglobal_2"
display "$myglobal_3"

gen $myglobal_3 = ln_wage

** 2.4 Using locals **
* use `' and the name of your local to call your locals: `namelocal'

local 	mylocal_1 	= 2
local 	mylocal_2 	"some text"
local 	mylocal_3 	newvar2

display "`mylocal_1'"
display "`mylocal_2'"
display "`mylocal_3'"

gen `mylocal_3' = ln_wage

** 2.5 Assigning macros with embedded text **
decode race, generate(race_text) // converts numerical variable race into string with text from original variable's labels
br race race_text

local if_text `" if race_text == "black" "' // use `" "' when the local's content has text 
tab age `if_text' // tabulates if race_text == black

** 2.6 Using macros to write repetitive blocks of code **

// Do you remember the histogram of ln_wage by race in 1968?
twoway (histogram ln_wage if race == 1, fcolor(green%20) lcolor(%20)) (histogram ln_wage if race == 2, fcolor(cranberry%20) lcolor(%20)) if year == 68, title(1968) legend(order(1 "White" 2 "Black")) // histogram of ln_wage by race

local hist_opt1 "fcolor(green%20) lcolor(%20)"
local hist_opt2 "fcolor(cranberry%20) lcolor(%20)"
local legend_opt `"legend(order(1 "White" 2 "Black"))"'

// 2 lines instead of 3:
twoway (histogram ln_wage if race == 1, `hist_opt1') (histogram ln_wage if race == 2, `hist_opt2') if year == 68, title(1968) `legend_opt' 

/* 	name your locals with meaningful names
	
	ex: hist_opt1 stands for histogram 1 options 
		hist_opt2 stands for histogram 2 options 
		legend_opt stands for legend options
	
	this naming favors readability for easy access and screening	
*/



****************
*** 3. Loops ***

/* 	Loops are very important to automatize your code
	
	They make repetitive tasks easier
	
	They are two types of loops
	
	foreach
	
	forvalues (faster for numbers)
*/

** 3.1 foreach basic usage **
webuse nlswork, clear
foreach item in idcode year birth_yr { // open brace in same line as foreach
	
	//	nothing may follow the open brace except, of course, 
	//	comments; the first command to be executed must appear on a
    //	new line;
	
	describe `item'
	
} // the close brace must appear on a line by itself

/*	Comments:

	idcode year birth_yr is a list (of variables)
	
	item is a local that we call using `item'
	
	item will sucessively take the values of each member of the list
*/

* 3.1.1 another example
foreach text in "text 1" "text 2" "text 3"{ // the list could include anything
	
	// this list include strings "text 1" "text 2" "text 3"
	
	display "`text'"
	
}

* 3.1.2 foreach + local 

// Stata recommends using this syntax because is the fastest

local myvars_loc "idcode year birth_yr"

foreach var of local myvars_loc {
	
	describe `var'
	
}

* 3.1.3 foreach + globals

// Stata recommends using this syntax because is the fastest

global myvars_glob "idcode year birth_yr"

foreach var of global myvars_glob {
	
	describe `var'
	
}

* 3.1.4 foreach + varlist

* specify list of variables writing each variable 
* specify list of variables writing var1-varn (all variables between var1 and varn in the current variable order; see variables menu)
* example: idcode-race is short for idcode year birth_yr age race

foreach var of varlist idcode year-age { // this syntax tells Stata that whatever is after varlist is a list of variables
	
	describe `var'
	egen `var'_avg = mean(`var')
	
}

browse idcode year-age *_avg
drop *avg

* 3.1.5 Specifying varlist might be useful

foreach var in idcode year-age { // we don't tell Stata that we are looping through a varlist
	
	describe `var'
	egen `var'_avg = mean(`var') // *CAREFUL* this will generate an error
}
browse idcode year-age *_avg

// in the above example Stata does not interpret year-age as a list of variables but as another element of the list "idcode year-age"


/* 	Comments:

	There are other options for foreach such 
	
	***foreach num of numlist***: to loop over a list of numbers not necessarily equally spaced
	
	and
	
	***foreach nvar of newlist***: to loop over new variables
	
	but they are rarely used 
	
	since the previous foreach options (4.1.1-4.1.4) and forvalues (4.2) are quite versatile
*/



** 3.2 forvalues **

/* forvalues is more efficient for consecutive items like numbers 1, 2, 3,..., n */

forvalues i = 1/10 { // look at the use of "=" and "/"
	local mySeries = `mySeries' + `i'
	display `mySeries' // it consecutively displays the sum of the first i numbers from 1 to 10
}

** 3.3 Using loops for automation 1 **

* Let's use loops and locals to automate the plots in 1.7.1
webuse nlswork, clear

local hist_opt1 "fcolor(green%20) lcolor(%20)"
local hist_opt2 "fcolor(cranberry%20) lcolor(%20)"
local legend_opt `"legend(order(1 "White" 2 "Black"))"'

foreach yr in 68 73 78 83 87 88 {
	
	twoway (histogram ln_wage if race == 1, `hist_opt1') (histogram ln_wage if race == 2, `hist_opt2') if year == `yr', title(19`yr') `legend_opt'

	graph save "lnWageByRace_y`yr'.gph", replace

}

* 11 lines of code versus 18 lines in 1.7.1 
* we are less likely to make coding mistakes
* we can easily plot more years with no extra lines of code!

/*	Finally, there is a tradeoff between the use of locals, globals and loops versus writing your code extensively:
	
	if you use too many locals and globals, it might difficult to read what your program is executing
*/ 




**********************************
*** 4. Return list, scalars, and matrices ***

/* 	Some commands produce data that might be useful 

	we can access some of that information using
	
	return list
	
	check the help of each command to see if it will have any available return data
*/

** 4.1 The return list command ** 

summarize union
return list // it will show you some statistics such as 

/*
	r(N)	- number of observations
	r(sum)	- sum of values for variable ln_wage
	r(mean)	- average of the values of ln_wage (r(sum) / r(N))
	r(sd)	- standard deviation of values of ln_wage
	
	among others
*/

* You can access these values using the local syntaxis
* Let's assign to a local the average of ln_wage

summarize ln_wage
local ln_wage_avg = `r(mean)'

display "The average of ln_wage is " `ln_wage_avg'

** 4.2 The scalar variables ** 

/*	Stata scalar variables are different from variables in the dataset. 	

	Variables in the dataset are columns of observations in your data. 

	Stata scalars are named entities that store single numbers or strings,
which may include missing values.
  
*/

* 4.2.1 Assigning scalars

* use command scalar to assign scalars

scalar myScalar = 1
scalar myScalar2 = "some text"

display myScalar myScalar2 // to call a scalar variable simply write its name

* you can use scalars to store return stored results

summarize union
scalar union_avg = `r(mean)'
display "The fraction of unionized women is " union_avg

* in general, scalars are not used very often

* 4.2.2 Naming scalars

* do not name scalars as other variables in the dataset to avoid confusion

scalar ln_wage = 2 // AVOID THIS since ln_wage is already a variable name

display ln_wage // displays the first value of ln_wage, i.e., ln_wage if _n == 1

br ln_wage if _n == 1

** 4.3 Matrices **

* 4.3.1 Define a matrix
matrix myMatrix1 = 1, 0 \ 0 , 1 // matrix with zeros in main diagonal
matrix myMatrix2 = 1, 0 \ 0 , 1 // zeros everywhere else

* 4.3.1 Matrix operations
matrix define myMatrix3 = myMatrix1 + myMatrix2

* 4.3.3 Subsetting a matrix
display "The entry 1,1 of matrix myMatrix1 is" myMatrix1[1,1]
display "The entry 2,2 of matrix myMatrix3 is" myMatrix3[2,2]



*************************
*** 5. More on locals ***

/* 	Multiple commands have an option to store data in locals

	We will see three of those commands:
	
	describe
	
	levelsof
	
	local localname: variable label

*/

** 5.1 The describe command and locals ** 

/* We know the describe command since week 1 */
webuse iris, clear

describe sep* pet* // describes variables that start with "sep" and "pet"

* describe has an option to save the variables called by the command

describe sep* pet*, varlist

return list

local vars_startWith_sep_pet `r(varlist)' // we save return stored results in local vars_startWith_sep_pet
macro list

* We can then use it within a loop of varlists

foreach var of local vars_startWith_sep_pet {
	
	egen `var'_avg = mean(`var') // concise way to make multiple calculations
}
drop *avg

** 5.2 The levelsof command basic usage ** 

/* The levelsof command prints the values a variable takes */
webuse nlswork, clear

help levelsof

levelsof union

* we can store the output of levelsof in a local
levelsof union, local(lvls_union)

display "The values that the variable union can take are `lvls_union'"

** 5.3 Storing labels from variables
webuse iris, clear

local label_seplen : variable label seplen

display `"The label of variable "seplen" is "`label_seplen'" "'

* compare with
display "The label of variable seplen is `label_seplen' "

* 5.3.1 Using local localname: variable label

describe sep* pet*, varlist

local vars_startWith_sep_pet `r(varlist)' // we save return stored results in local vars_startWith_sep_pet

foreach var of local vars_startWith_sep_pet {
	
	egen `var'_avg = mean(`var') // concise way to make multiple calculations
	
	local label_`var' : variable label `var' // saves label of variable `var'
	
	label variable `var'_avg "Average of `label_`var''" // assigns label to variable `var'_avg
	
	// note the double usage of `' in `label_`var''
	
}
drop *avg


******************************************
*** 6. Temporary files and variables.  ***

/* 	Temporary files and variables help reduce memory requirements 
	
	They will be only used when you execute lines from your do file

*/

** 6.1 Temporary files ** 
webuse nlswork, clear

keep if union == .

tempfile mytemp // this lines tells Stata we would use `mytemp' as a temporary dataset

save `mytemp', replace // saves current dataset to mytemp
use `mytemp', clear // loads dataset mytemp

** 6.2 Temporary files while working with multiple datasets **

/*	We'll see a case calling the merge command multiple times */

* Families dataset from week 4
use families_age.dta, clear
browse

* Merge the datasets using families_head.dta both last_name and first_name
merge 1:1 last_name first_name using families_head.dta

* Replace observations with head_hosuehold == . with head_hosuehold = 0 
replace head_household = 0 if head_household == .
br
drop _merge

tempfile families_age_head
save `families_age_head', replace

* load families_location
use families_location.dta, clear
isid last_name

merge 1:m last_name using `families_age_head' // all observations were matched

** 6.3 Temporary variables **
webuse nlswork, clear
tempvar aux1 aux2 aux3 // similar to temporary files, you tell stata that you will use the following temporary variables

* 6.3.1 Calculating a standard deviation
egen `aux1' = mean(ln_wage)
gen `aux2' = (ln_wage - `aux1')^2
egen `aux3' = mean(`aux2' * _N / (_N - 1))  // degrees of freedom adjustment
gen ln_wage_sd = sqrt(`aux3')

* aux1, aux2 and aux3 are created on the go and then dropped

* Let's check our calculation is correct
summarize ln_wage, detail
scalar ln_wage_sd_2 = `r(sd)' 

* This is a trivial example for illustrational purposes

* You may want to calculate statistics that are not already coded in stata