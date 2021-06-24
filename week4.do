/*
Date: 7/25/20
Author: Jaime Ramirez (jramirezcuellar@ucsb.edu)
Purpose: Lecture 7 & 8 - Stata Skills Summer 2020
Economics Department UC Santa Barbara

What we will learn this week:

 0. Recap from previous week 
 1. Primary keys
 2. Merging datasets 
 3. The append and cross commands
 4. Reshaping datasets
 5. Introduction to date and time values and variables

*/



***************************************
***** 0. Recap from previous week *****

clear all // clears all data
set more off // to avoid telling stata to show more every time you run commands

webuse nlswork

*** 0.1 the summarize command ***
tab race 
summarize age if race == "black" // *Careful* it prompts and error. Why? 

label list 

summarize age if race == 2 // it should work now to summarize for black women

summarize age if race != 1 // summary for age for non-white women 

summarize ln_wage if age < 24 & race == 2 // summary of log wages for women who are at most 24 years old and black

summarize ln_wage if (age == 24 & race == 2) | collgrad == 1 // summary of log wages for women who are either 24 years old and black, or have college
/* look at the use of parenthesis to subset the observations */ 

*** 0.2 the _n and _N variables *** 
sort ln_wage 

gen wage_ranking1 = _n // creates a variable with the ranking of wages from lowest to highest

gsort -ln_wage // sorts observations from the highest wage to the lowest wage

gen wage_ranking2 = _n // creates a variable with the ranking of wages from highest to lowest 

display "The number of observations is " _N // the display command is very useful to print informations to the results window/ write text to your log file

*** 0.3 the distinct command ***
* How many groups can be created using the combination of race age and union?
distinct race age union // 3*33*2 = 198 combinations

*** 0.4 The egen command *** 
egen ln_wage_avg = mean(ln_wage) // creates a constant accross observations equal to the average log wage
br ln_wage*

bysort race age union: egen lnwg_avg_grps = mean(ln_wage) // creates a  the average log wage among each combination of race, age and union
br race age union ln_wage lnwg_avg_grps



*********************************
*** 1. Primary & foreign keys ***

/* 
A primary key is a variable (column) or list of variables that uniquely identifies each row in the dataset

Primary keys can't have null values.

*/

webuse nlswork, clear

* What variables uniquely identify observations in the dataset?
* A good candidate seems to be idcode
describe idcode

** 1.1 the duplicates command (again) **

* The duplicates command help us check whether multiple observations (rows) have the same idcode
help duplicates

* 1.1.1 duplicate report 
duplicates report idcode // it does not seem that idcode is a primary key
*  from the table there are 547 observations with no copies, i.e., idcode uniquely identifies only 547 observations of the 28534 observations in the dataset

* 1.1.2 duplicate examples: How can we identify some duplicates? 
duplicates examples // gives some examples of duplicates
sort idcode
br if idcode == 5158 // there are two rows with the same idcode

* 1.1.2 duplicate tag 
* We can create a variable that tells how many duplicates we have per variable
duplicates tag idcode, generate(dupli_idcode) 
br idcode dupli_idcode
br idcode dupli_idcode if dupli_idcode == 0 // browse observations with no duplicates
br idcode dupli_idcode if dupli_idcode != 0 // browse observations with at least one duplicate

* Overall idcode is not a primary key

/*  Fortunately, we know that the data comes from the National Longitudinal Survey.
	
	A longitudinal survey tracks the same individuals across different years
	
	The observations should be uniquely identified using two variables idcode and year!
*/

duplicates report idcode year // no duplicates!

** 1.2 the isid command **
/* This command tells whether a dataset is uniquely identified by a given list of variables */
isid idcode // *CAREFUL* error: the variables do not uniquely identify the dataset
isid idcode year // no error

* 1.3.1. Load dataset nlswork_constant.dta and find what variables uniquely identify the observations (you can repeat steps 1.1-1.2 as well)
use nlswork_constant, clear
isid idcode // nlswork_constant is uniquely identified by idcode

* 1.3.2. Load dataset nlswork_yearly.dta and find what variables uniquely identify the observations (you can repeat steps 1.1-1.2 as well)
use nlswork_yearly, clear
isid idcode year // nlswork_yearly is uniquely identified by idcode and year



***************************
*** 2. Merging datasets ***

/*
Merging datasets is very common when using Stata or data in general

let's think of two datasets:

 1) dataset families_age.dta: each row is a person with variables last_name, first_name and age 

	last_name	first_name	age
	Smith		John		26
	Smith		Anne		24
	Smith		John A		2
	Romano		Carl		25
	Romano		Julia		26

 2) dataset families_head.dta : each row is a person with variables last_name, first_name and head_household
 
	last_name	first_name	head_household
	Smith		John		1
	Romano		Julia		1

	Only people in this dataset are household heads
	
We want a final dataset where we have each person with a variable that tells whether the person is a head of the household or not

	last_name	first_name	age		head_hosuehold
	Smith		John		26		1
	Smith		Anne		24		0
	Smith		John A		2		0
	Romano		Carl		25		0
	Romano		Julia		26		1

We will see the command  **** merge ****

*/

** 2.1 Let's load dataset families_age.dta and find the variables that uniquely identify it **

use families_age.dta, clear
isid last_name // *CAREFUL* error
isid last_name first_name // these two variables uniquely identify the dataset*/

** 2.2 Let's load dataset families_head.dta and find the variables that uniquely identify it ** 
use families_head.dta, clear
isid last_name // this variable uniquely identifies the dataset 

/*	A foreign key is variable in the dataset that is a primary key in another dataset */

* ex: last_name is a foreign key in dataset families_age.dta, because last_name uniquely identifies the observations in dataset families_head.dta

** 2.3 Merge **

* let's load dataset families_age.dta again
use families_age.dta, clear

* 2.3.1 Help merge
help merge 

* 2.3.2 Merge the two datasets using both last_name and first_name
merge 1:1 last_name first_name using families_head.dta

** 2.4 Analyzing results of merge **

/*
merge creates a new variable call _merge

_merge == 1 if the observation was in the original dataset, which is usually called the ***master dataset***, and it was not matched

_merge == 2 if the observation was in the dataset we are calling in merge, which is usually called the ***using dataset***, and it was not matched

_merge == 3 if the observation was in both the master and the using datasets, i.e., it was matched

*/

* 2.4.1 Not matched observations 
list if _merge != 3 // In this merge, there are 3 observations not matched

* 2.4.2 Not matched observations from master dataset
list if _merge == 1 // In this merge, there are 3 observations not matched from the master dataset
 
* 2.4.3 Not matched observations from using dataset
list if _merge == 2 // In this merge, there are 0 observations not matched from the using dataset

* 2.4.5 Matched observations
list if _merge == 3 // In this merge, there are 2 matched observations

* If we know that people in families_head.dta correspond to all hosuehold heads we can infer that all the people that were not matched are not household heads

* 2.4.6 Replace observations with head_hosuehold == . with head_hosuehold = 0 
replace head_household = 0 if head_household == .
br
drop _merge
save families_age_head.dta, replace

** 2.5 A 1:m merge 

* 2.5.1 Load dataset families_location.dta
use families_location.dta, clear

* 2.5.2 families_location.dta is uniquely identified by last_name
isid last_name

* 2.5.3 Merge using last_name and families_age_head.dta
merge 1:m last_name using families_age_head.dta // all observations were matched

** 2.6 A m:1 merge ** 

* 2.6.1 Load dataset families_age_head.dta
use families_age_head.dta, clear

* 2.6.2 Merge using variable last_name and dataset families_location.dta
use families_age_head.dta, clear

merge m:1 last_name using families_location.dta // all observations were matched

/*  Comments: resulting dataset is similar to the dataset in 2.5
	
	The only two differences are in the order of the variables and _merge takes different values
 */

** 2.7 The assert command **
/*	assert help us check if some logical condition is met in our dataset
	
	If condition is true then stata displays "."
	
	If condition is not true then stata displays an error
*/
assert _merge == 3 // we can check if all observations were matched
* It is useful when our data changes, i.e., we have new or updated data

** 2.8 DO NOT TRY TO USE a m:m merge ** 
* Those merges are quite messy and can be more problematic than helpful
use families_age.dta, clear
merge m:m last_name using families_head.dta // all observations were matched
browse // however, all people are now head of households


****************************************
*** 3. The append and cross commands ***

/*	The append command also joins two datasets.

	It is equivalent to paste new observations below position _N (the last position)
	
	No need to worry about primary keys or if there are variables that uniquely identify the observations

*/
use nlswork_first_half.dta, clear

display "The number of observations is " _N // 14,267 observations

** 3.1 Append **
append using nlswork_second_half.dta

display "The number of observations is " _N // 28,534 observations

tab first_half

/*	When using append, it is sometimes convenient to create a variable that tells you where the data comes from 

	In this example, we have done so using a variable called first_half
*/

** 3.2 Append 2 **
webuse nlswork, clear

append using families_age_head.dta // this append does not make sense but it illustrates that append is very flexible and won't propmt an error message so easily
browse

** 3.3 The cross command **

* Cross is less often used
use nlswork_idcode.dta, clear // loads variable idcode from nlswork
isid idcode
display "The number of unique idcode entries is " _N

use nlswork_year.dta, clear // loads variable year from nlswork
isid year
display "The number of unique year entries is " _N

cross using nlswork_idcode.dta // creates all posible combinations of idcode and year
display "The number of combinations idcode and year is " _N

* it might be useful to create some panel/longitudinal data and check what year & individual combinations are missing


*****************************
*** 4. Reshaping datasets ***

/* 	Tidy data (taken from Wickham's tidy data article https://vita.had.co.nz/papers/tidy-data.pdf)

	Tidy data is a standard way of mapping the meaning of a dataset to its structure. 

	A dataset is messy or tidy depending on how rows, columns and tables are matched up with observations, variables and types. 

	In tidy data:

	1. Each variable forms a column.
	2. Each observation forms a row.
	3. Each type of observational unit forms a table.

	Ex 4.1: Table 4.1: data not in a tidy format
	
		Name 			treatmenta 	treatmentb
		John Smith 		. 			2
		Jane Doe		16 			11
		Mary Johnson 	3 			1

	Ex 4.2: Table 4.2: Data in a tidy format

		name 			trt 	result
		John Smith 		a 		.
		Jane Doe 		a 		16
		Mary Johnson 	a 		3
		John Smith 		b 		2
		Jane Doe 		b 		11
		Mary Johnson 	b 		1
		
	We use reshape to go from the table in example 4.1 to the one in example 4.2	
*/

use ex4.1.dta, clear
browse

help reshape

/*	In Stata, 
	Table 4.1 is in wide format
	Table 4.2 is in long format
*/

* 4.1 We should do a reshape long to go from wide to long

reshape long treatment, i(name) j(trt) string

browse // data is now in a tidy representation

rename treatment result

* 4.2 Let's do a long-to-wide reshape
reshape wide result, i(name) j(trt) string

rename result* treatment* 

browse // we have the same database we started with


* 4.3 What could go wrong?

* 4.3.1 wide-to-long reshape
reshape long treatment, i(name) j(trt) // *CAREFUL* this produces an error

/* 	The above code produces an error because the new variable trt is string and we did not tell Stata that it was
	
	Stata does not reshape the data in this case
*/

reshape long treatment, i(name) j(trt) string // data is in long format now


* 4.3.2 long-to-wide reshape 
reshape wide treatment, i(name) j(trt) // *CAREFUL* this produces an error

/* 	The above code produces an error because the new variable trt is string and we did not tell Stata that it was
	
	Stata does not reshape the data in this case
*/

reshape wide treatment, i(name) j(trt) string // data is in wide format now

* 4.4 Go back to previous dataset
reshape long // wide-to-long reshape
reshape wide // long-to-wide reshape


*************************************************************
*** 5. Introduction to date and time values and variables ***

** 5.1 date formatting **

* NASDAQ composite index from 7/25/19 to 7/25/20
import delimited "^IXIC.csv", clear // downloaded from Yahoo Finance on 7/25/20

browse 

describe date

* 5.1.1 The split command
help split

split date, parse(-)

* 5.1.2 Renaming
rename date1 year
rename date2 month
rename date3 day

* 5.1.3 Destring
destring year month day, replace

* 5.1.4 Function mdy
help mdy

gen date_sif = mdy(month, day, year) // creates date in Stata internal form (SIR)

browse date date_sif // stata assigns a number to each day starting with (01jan1960 = 0); this is a convention within Stata

* 5.1.5 the format command 
help format

format date_sif %td

browse date date_sif // looks good now

* 5.1.6 the mofd function (month of day)
gen month_sif = mofd(date_sif) // it takes a date in SIF and generates the month  
format month_sif %tm // formats in terms of month