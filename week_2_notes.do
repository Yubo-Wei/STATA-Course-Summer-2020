/*
Date: 7/14/20
Author: Jaime Ramirez (jramirezcuellar@ucsb.edu)
Pupose: Lecture 3 & 4 - Stata Skills Summer 2020
Economics Department UC Santa Barbara

What we will learn this week:

 0. Recap from previous week 
 1. Creating new variables: The generate command 
 2. The drop and keep commands 
 3. Exploring your variables: The tabulate command 
 4. The preserve and restore commands 
 5. The collapse command 
 6. Working with string variables 
 7. Playing with data: Breaking up strings 

*/

***************************************
***** 0. Recap from previous week *****

clear all // clears all data
set more off // to avoid telling stata to show more every time you run commands

pwd // current directory

* 0.1 Log to keep records of the commands you run
log using week2, replace text name("Week_2_Log")

* 0.2 Load dataset from World Bank
webuse lifeexp, clear

* 0.3 Exploring datasets
describe // prints variable names, storage type, display format, vlaue label, variable label

notes // some datasets have notes (we'll see more about this)

browse // see data

list // print data to results window

* 0.4 Load the dataset Iris from Fisher (1936) and Anderson (1935)
use "http://www.stata-press.com/data/r16/iris", clear

describe // prints variable names, storage type, display format, vlaue label, variable label
notes // some datasets have notes (we'll see more about this)

browse // see data

list // print data to results window

log close Week_2_Log // closing log; let's go and see it!

*******************************************************
*** 1. Creating new variables: The generate command ***

webuse nlswork
describe
notes // it does not have notes

/*
The generate command helps create new variables
*/

generate example = 1 // creates a new numerical variable with value 1 for all rows
br // let's go and check if the variable was created; br is short for? 

* we can also create string variables
generate database = "nlswork" // generates a string variable with the name of the database
generate database2 = "(National Longitudinal Survey. Young Women 14-26 years of age in 1968)" // generates a string variable with a more detailed name of the database


*** 1.2 More on the generate command ***

* gen is short for generate

gen missing_num = . // missing numerical variables
gen missing_str = "" // missing string variables

* 1.2.1 Strings
gen str5 my_string = "hello" // creates a string of 5 characters long
gen str2 my_string2 = "hello" // creates a string of 2 characters long 
br my_string*

* Most of the times we do not worry about the length of the strings

* 1.2.2 Integer type
gen byte dummy1 = 0 // uses 1 byte
gen int dummy2 = 0 // uses 2 bytes
gen long dummy3 = 0 // uses 4 bytes

* 1.2.3 Non-integer type 
gen float dummy4 = 0  // uses 4 byte
gen double dummy5 = 0 // uses 8 bytes

/*	Comments:
	byte is ideal for yes or no categories
	
	long is ideal for identification numbers of 9 or less digits
	
	double is ideal for identification numbers of 10 or more digits
  
	floats have about 7 digits of accuracy:  the magnitude of the number does
    not matter.  Thus, 1234567 can be stored perfectly as a float, as can
    1234567e+20.	
*/

* An example with floats
gen float x = 0.1
list if x == 0.1 // it does not show any output
list if x == float(0.1) // it shows some output
* important because we sometimes want to check if two variables are the same, i.e., we might have two codes to produce a variable and want to check if both methods produce the same variable with our data
* we will see more on this in the following weeks

*** 1.3 The replace command ***
/* The replace command is fairly close to the generate command*/
replace dummy1 = 1 in 1 // replaces 1 in row 1
replace dummy1 = 1 in 0 // *CAREFUL* it produces an error because there's no row 0!
replace my_string2 = "hi" // replace my_string2 with "hi" in all rows/positions

**************************************
*** 2. The drop and keep commands ****

/* keep & drop help us select variables that will remain in a dataset*/

* 1.4.1 Drop
drop dummy1 // drops dummy1 from the dataset
describe dummy1 // *CAREFUL* it will create an error

* 1.4.2 Keep
keep dummy2

/* We can drop or keep specific rows/positions */

* 1.4.1 Drop
drop if _n == 1 // drops row 1 (see hidden variable _n that registers the sorting of the data)

* 1.4.2 Keep
keep if _n != 1 // drops row 1 (see hidden variable _n that registers the sorting of the data)

* we will se more uses of _n and if statements in the following weeks

*********************************************************
*** 3. Exploring your variables: The tabulate command ***
use "http://www.stata-press.com/data/r16/iris", clear

/*
	Tabulate creates frequency tables
	Useful for checking missing frequencies
	Useful for variables with few categories
*/

** 3.1 Basic usage of the tabulate command
tabulate iris // creates a table with the absolute and relative frequencies for each value of iris
tabulate iris, missing // check whether iris have missing values

** 3.2 Creating dummies with tabulate ** 
tabulate iris, generate(species) // creates 
br iris species* 

/*	Comments:
	variable iris has 3 values
	the above command creates 3 dummies for each of the values of tabulate
	
	species1 takes values 1 for those rows where iris is equal to "setosa", and 0 otherwise
	species2 takes values 1 for those rows where iris is equal to "versicolor", and 0 otherwise
	species3 takes values 1 for those rows where iris is equal to "virginica", and 0 otherwise
	
	this code is specially useful to create dummies for regression with dummies
	Do not use with non-categorical variables, for example, income, wages, wealth, etc.
	Or transform those variables into categorical, i.e., low income, medium income, high income, etc.
*/

** 3.3 Tabulate with two variables**
webuse nlswork, clear

* We can tabulate a single variables
tabulate year
tabulate race

* We can also tabulate two variables
tabulate year race
tabulate year race, m // check if there are missing by categories
tabulate race year // order matters for nice display of results 

** 3.4 tab2: tabulate all possible pairs of a list of variables** 
tab2 year race // same result as tabulate
tabulate year race collgrad // *CAREFUL* error; we tried to tabulate three variables; 
tab2 year race collgrad // it works; it produces 3 tables

* We will see more on making tables later in the course

*********************************************
*** 4. The preserve and restore commands ***

/*
	preserve and restore are commands that help recover a database to a previous saved value

	preserve is always used before restore	
	 
	preserve tells Stata the current state of the dataset we want to save temporarily

	restore tells Stata that we want to have back the dataset that was saved previously 

	It helps when we compute certain aggregate statistics (see below)

	It can take a lot of time for large datasets  
*/

* Run the following code line by line
preserve
	drop _all	
restore

* What happens?

* Run the above code as a block (select the lines XXX-XXX and then hit ctrl+D or command+D depending of your OS)

********************************
*** 5. The collapse command ***
/*
	collapse is a very powerful command that helps us create summarized information
	at a more aggregate/group level	
*/

* usage: command (stat) varlist (stat2) varlist2 ...[, options]

help collapse

** 5.1 Compute means  **
use "http://www.stata-press.com/data/r16/iris", clear
collapse (mean) seplen sepwid petlen petwid // it creates one observation as the average for all 150 observations

* Browse the new dataset
br

* Describe the variables in the new dataset
des // labels are not that nice

* Relabelling
label variable seplen "Average sepal length in cm" 
label variable sepwid "Average sepal width in cm" 
label variable petlen "Average sepal length in cm" 
label variable petwid "Average sepal width in cm" 

* Let's export the output
export excel using "C:\Users\jdram\Documents\iris_summary.xls", sheet("average") firstrow(variables) replace

** 5.2 Compute means for each iris **
use "http://www.stata-press.com/data/r16/iris", clear
collapse (mean) seplen sepwid petlen petwid, by(iris) // it creates one observation as the average for all 150 observations

* Browse the new dataset
br

* Describe the variables in the new dataset
des // labels are not that nice

* Relabelling
label variable seplen "Average sepal length in cm" 
label variable sepwid "Average sepal width in cm" 
label variable petlen "Average sepal length in cm" 
label variable petwid "Average sepal width in cm" 

* Let's export the output
export excel using "C:\Users\jdram\Documents\iris_summary.xls", sheet("average_by_iris", replace) firstrow(variables) 

** 5.3 Compute means and standard deviation for each iris**
* Now we want to calculate other statistic, standard deviation
use "http://www.stata-press.com/data/r16/iris", clear
collapse (mean) seplen sepwid petlen petwid (sd) seplen sepwid petlen petwid, by(iris) 
* CAREFUL* it produces an error. Why?

* Now try this other way
collapse (mean) seplen_avg = seplen sepwid_avg = sepwid petlen_avg = sepwid petwid_avg = petwid (sd) seplen_sd = seplen sepwid_sd = sepwid petlen_sd = sepwid petwid_sd = petwid

* Browse the new dataset
br

* Describe the variables in the new dataset
des // labels are not that nice

* Relabelling
label variable seplen_avg "Average sepal length in cm" 
label variable sepwid_avg "Average sepal width in cm" 
label variable petlen_avg "Average sepal length in cm" 
label variable petwid_avg "Average sepal width in cm" 
label variable seplen_sd "Standard deviation sepal length in cm" 
label variable sepwid_sd "Standard deviation sepal width in cm" 
label variable petlen_sd "Standard deviation sepal length in cm" 
label variable petwid_sd "Standard deviation sepal width in cm"

* Let's export the output
export excel using "C:\Users\jdram\Documents\iris_summary.xls", sheet("avg_std", replace) firstrow(variables) 

** 5.4 Using collapse with preserve/restore **

use "http://www.stata-press.com/data/r16/iris", clear
* We can use preserve/restore to help us recover the dataset before collapsing
preserve
	collapse (mean) seplen_avg = seplen sepwid_avg = sepwid petlen_avg = sepwid petwid_avg = petwid (sd) seplen_sd = seplen sepwid_sd = sepwid petlen_sd = sepwid petwid_sd = petwid, by(iris)  // I like to use tab (on the keyboard)

	* Describe the variables in the new dataset
	des // labels are not that nice

	* Relabelling
	label variable seplen_avg "Average sepal length in cm" 
	label variable sepwid_avg "Average sepal width in cm" 
	label variable petlen_avg "Average sepal length in cm" 
	label variable petwid_avg "Average sepal width in cm" 
	label variable seplen_sd "Standard deviation sepal length in cm" 
	label variable sepwid_sd "Standard deviation sepal width in cm" 
	label variable petlen_sd "Standard deviation sepal length in cm" 
	label variable petwid_sd "Standard deviation sepal width in cm"	
	
	* Let's export the output
export excel using "C:\Users\jdram\Documents\iris_summary.xls", sheet("avg_std", replace) firstrow(variables) 
	
restore

* we avoid saving and loading the dataset with preserve/restore 

*** 6. Working with string variables ***

** 6.1 Converting string variables to numeric variables**
use "http://www.stata-press.com/data/r13/hbp2" , clear

tab sex
tab sex, m

** 6.1.1 The encode command **
encode sex, gen(gender)
tab gender

* encodes coverts a string variable into a numerical variable with a attached value

** 6.1.2 The destring/tostring commands **

/* tostring converts numeric into string variables */
tostring year, generate(year_str) 
des year year_str

/* destring converts string to numeric */
destring year_str, replace
des year_str

************************************************
*** 7. Playing with data: Breaking up strings ***
import excel "enrolled_students.xlsx", sheet("Sheet1") firstrow
 
* What is this dataset?
br 
describe

/* It is a dataset with the people enrolled in the class! */

** 7.1 Let's rename the variables
rename Whatisyourgraduationyear graduation_year
rename Whatisyourmajor major
rename Areyouenrolledorintendingto enrolled
rename Whatsyourintendedcareerpath intended_career
rename Doyouplanondoingoneconomic econ_research_interest

** You will complete renaming the variables in the assignment for this week

* Is graduation_year looking nice?
tab graduation_year // it looks disorganized

/*
	We are going to use some of the text variables to make this dataset look better
*/
 
* 7.2 The substr function 
/*	Note:
	Functions and commands are different in Stata
	We can type commands directly into the command window, whereas
	we cannot type functions into the command window without first calling a command
*/

help substr
* Generate a new variable containing the first two characters of graduation_year
generate first_two_chars = substr(graduation_year,1,2)

* 7.3 The substr function 
help strpos
* Generate position of "20" within string graduation_year 
gen position_of_string = strpos(graduation_year,"20") 
 
* Let's extract four characters of graduation_year that start with "20"
generate graduation_year0 = substr(graduation_year,position_of_string,4)  

* Let's check the new variable
tab graduation_year0 // looks better

* missing within graduation_year0 ?
tab graduation_year0, m // yes, 6 missing values but we cannot inferred them 

* check those observations closely
br if graduation_year0 == "" // it seems we can drop some of them

* 7.4 Transform graduation_year0 to numerical
destring graduation_year0, replace

* 7.5 lowercase and UPPERCASE 
gen major_lower = strlower(major)
gen major_proper = strproper(major)
gen major_upper = strupper(major)
