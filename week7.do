/* 
Date: 8/18/20
Author: Antoine Deeb (antoinedib@ucsb.edu)
Purpose: Lecture 13 & 14 - Stata Skills Summer 2020
Economics Department UC Santa Barbara

What we will learn this week:

 0. Matrices. 
 1. How stata stores output: return and ereturn.
 2. Making summary tables.
 3. Regressions and Hypothesis testing.
 4. Making regression tables. 
 5. Combining it all with loops to efficiently make a lot of tables.
 */
clear all // clears all data
set more off
*Set directory:
  if c(username)=="antoi" {
cd "C:\Users\antoi\Dropbox\STATA class - Summer 2020\week 7"
  }
    if c(username)=="Antoine" {
cd "D:\Dropbox\Dropbox\STATA class - Summer 2020\week 7"
  }
use ACS_2018.dta,clear

*Some light data cleaning:
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




*Let's start with how to define matrices in stata:

*To define matrices in stata: separate the columns by using a comma "," and the rows using the backslash "\". 
/* For example to define the matrix:
1 3
0 1
*/ 
*We use:
matrix myMatrix1 = 1,3\0,1
/* For example to define the matrix:
0 3
1 0
*/ 
*We use:
matrix myMatrix2 = 0,3\1,0 




* To see our matrices we can use the commands:
matrix list myMatrix1
matrix list myMatrix2

*We can also display specific elements of the matrix:

display "The entry 1,1 of matrix myMatrix1 is" myMatrix1[1,1]
display "The entry 2,2 of matrix myMatrix3 is" myMatrix2[2,2]

* or do any sort of matrix operations
matrix define myMatrix3 = myMatrix1 + myMatrix2
matrix list myMatrix3
* we can also add a new row to a matrix:
matrix myMatrix4=myMatrix3\4,4
matrix list myMatrix4

*Finally we can also save a matrix into our data, stata will do this by saving each column as a new variable:
svmat myMatrix4
br
drop myMatrix4*
*We will see how matrices can be useful shortly.


*Before we start making summary tables we're going to need some new commands:
ssc install estout //we will see how to make use of it in a bit

*First let's see how stata saves output for us to export:
help return 

*Let's see with summarize:
sum inctot
return list
ereturn list
// sum stores results in r() but not e(), in order to be able to export results we're going to need them stored in e().
//This is where the estpost (installed with estout) command comes in:
help estpost // estpost will make it so that the results from summarize are saved in e()

estpost sum inctot
ereturn list // now that stuff is saved in e() we can start exporting stuff!


*Suppose we want to make a summary stats table for our entire sample, including the mean standard deviations and number of observations:
estpost sum inctot high_sch
label variable high_sch "Has High-School Degree"
help esttab // we will be using the esttab command
esttab using sum_stats.rtf, cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))")  replace label title("Statistics for Whole Sample") noobs  nonumbers
/* we need to define a bunch of things for this:
cells("") states what statistics we want displayed, here I chose the mean standard deviation and number of observations.
notice i wrote down: mean(fmt(%9.3f)) what's in the parantheses is the format I want the mean to be displayed in
*/
help format // to see all the different possible format %9.3f means i want exactly 3 decimal points, %9.0f means i want exactly 0 points, there are a lot of different combinations to see.
/*
the label option tell stata to replace variable names by the label, which is much more informative usually.
Since I include count, I specify the noobs option.
nonumbers makes it so columns aren't numbered.
title() allows us to generate a title for the table
esttab can output in many different formats, here we chose rtf which will result in a word file. For those of you interested in grad school I suggest leanring and looking into LaTeX.
*/

*There are a ton of options and things you can change here so make sure to explore the commands more.
* Let's see how we can use this with the tabstat command:
estpost tabstat inctot high_sch, by(region) statistics(mean sd count) columns(statistics) // tabstat's advantage is being able to do it by category, we can use by() to do that.
*There are multiple ways to output all of this: 
esttab using sum_stats2.rtf, replace cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))") noobs nonumbers title("Statistics by Subgroup") label
*or we can make it prettier
 esttab using sum_stats3.rtf, replace main(mean %9.3f) aux(sd %9.3f)  nostar  noobs unstack  nonumbers label  title("Statistics by Subgroup")
 // The unstack option makes it so that each category is in one column, main() and aux() tell stata to display the mean and then sd under it in parantheses.
 
*What if I wanted a table for each category alone?
levelsof region, local(levels) // this will create a local called levels which contains every value of region.
// remember than region is numeric with a value label attached.
foreach l of local levels {
estpost sum inctot high_sch if region==`l'
esttab using "../week 7/Tables/stats_`:label (region) `l''.rtf", replace cells("mean(fmt(%9.3f)) sd(fmt(%9.3f)) count(fmt(%9.0f))") noobs nonumbers title("Statistics for `:label (region) `l''") label
}
// `:label (region) `l'' tells stata to use the  value label attached to the value of region specified by the local `l'. This will give us files with the actual names of the region instead of the numbers.
// you can use this levelsof trick to make graphs by categories etc as well.


*To run regression is stata, we will use the regress command (for those of you who might need more advanced stuff to efficiently handle a lot of fixed effects look into: ssc install reghdfe)
help reg

reg valueh inctot high_sch // will run a regression of valueh on inctot and high_sch

reg valueh inctot high_sch,r // will run a regression of valueh on inctot and high_sch using heteroskedasticity robust standard errors.

reg valueh inctot high_sch,cluster(state) // will run a regression of valueh on inctot and high_sch

*what if I want to include a binary variable for each state without having to generate them?

reg valueh inctot high_sch i.state,r // will run a regression of valueh on inctot and high_sch

// you could also interact dummies using i.birthyear##i.state, this for example will interact every birthyear binary variable with every state binary variable.

*how is regression output stored?
reg valueh inctot high_sch,r 
return list
ereturn list

*I can get the coefficient attached to inctot in a scalar using:
scalar coef1=_b[inctot]
*or
matrix coefs=e(b) // since reg stores all coefficients in e(b)
matrix list coefs
scalar coef2=coefs[1,1]
di coef1 " and " coef2

*We can also see linear combinations of coefficients using lincom:
lincom inctot+high_sch
lincom 3*inctot+(10/7)*high_sch
return list //lincom stores it's output in r()

*We can test a null hypothesis using test:
reg valueh inctot high_sch,r 
test inctot+high_sch=1000
test inctot+high_sch=0


*Now what if I want to estimate the coefficient of inctot in each state separately and then create a histogram of all 51 coeffecients:
preserve // preserve data
matrix R=. // initialize an empty matrix
levelsof state, local(levels)  
qui{
foreach l of local levels {
reg valueh inctot high_sch if state==`l',r 
scalar coef_inc=_b[inctot]
matrix R=R\coef_inc
}
}
svmat R
hist R1
restore

*How to export regression results?
reg valueh inctot high_sch,r 
*we can use esttab right after the regression
esttab using "..\week 7\reg_tables\example.rtf", replace title("Regression Example") label nonumbers  drop( _cons) b(%9.3f) se(%9.3f)  starlevels(* 0.1 ** 0.05 *** 0.01) 
*but a better way to do this is to store the estimates:
reg valueh inctot high_sch,r 
eststo example1 // eststa stands for estimates store.
esttab example1 using "..\week 7\reg_tables\example2.rtf", replace title("Regression Example") label nonumbers  drop( _cons) b(%9.3f) se(%9.3f)  starlevels(* 0.1 ** 0.05 *** 0.01) 
* drop() allows us to not include certain coefficients, here i'm dropping the constant. b() and se() specify that we want the coefficients and standard errors reported with a certain format
* starlevels tells stata how i want it to allocate stars for statistical significance, here i'm doing one star for 10% level, two for 5% level, and three for 1% level.

*why is it better to store estimates? You can make tables with multiple regressions:
reg valueh inctot high_sch 
eststo maj1
reg valueh inctot high_sch,r 
eststo maj2
reg valueh inctot high_sch,cluster(state) 
eststo maj3
esttab maj* using "..\week 7\reg_tables\example3.rtf", replace title("Regression Example") label   drop( _cons) b(%9.3f) se(%9.3f)  starlevels(* 0.1 ** 0.05 *** 0.01) //here i remove no number to know which equation is which.



*You can also use levelsof to make a table with multiple regression or multiple regression tables

*one table 
levelsof region, local(levels) // this will create a local called levels which contains every value of region.
// remember than region is numeric with a value label attached.
qui{
foreach l of local levels {
reg valueh inctot high_sch if region==`l',r 
eststo maj`l'
}
}
esttab maj* using "..\week 7\reg_tables\example4.rtf", replace title("Regression by Region") label   drop( _cons) b(%9.3f) se(%9.3f)  starlevels(* 0.1 ** 0.05 *** 0.01) 

*multiple tables each named appropriately:
levelsof region, local(levels)
qui{
foreach l of local levels {
reg valueh inctot high_sch if region==`l',r 
eststo maj`l'
esttab maj`l' using "..\week 7\reg_tables\reg_for_`:label (region) `l''.rtf", replace title("Regression for `:label (region) `l''") label  nonumbers drop( _cons) b(%9.3f) se(%9.3f)  starlevels(* 0.1 ** 0.05 *** 0.01) 

}
}


*Note that you can also estout any matrix you like to make a table out of it:
reg valueh inctot high_sch,r
ereturn list
matrix list e(V) //for example I want the variance covariance matrix of the coefficients that I can get from ereturn list

*for e() matrices:
estout e(V, fmt(%9.3f)) using matrix1.rtf, replace 
*any general matrix:
estout matrix(myMatrix4, fmt(%9.0g)) using matrix2.rtf, replace 
