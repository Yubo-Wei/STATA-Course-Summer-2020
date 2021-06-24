/*
Date: 7/20/20
Author: Antoine Deeb (antoinedib@ucsb.edu)
Pupose: Lecture 5 & 6 - Stata Skills Summer 2020
Economics Department UC Santa Barbara

What we will learn this week:
 1. Summary Statistics 
 2. Conditions: If statements.
 3. Sorting Data.
 4. _n and _N.
 5. Generating Variables 2: egen command 
 6. Duplicates and Distinct. 
*/
clear all // clears all data
set more off
*Set directory:
    if c(username)=="antoi" {
cd "C:\Users\antoi\Dropbox\STATA class - Summer 2020\week 3"
  }
    if c(username)=="Antoine" {
cd "D:\Dropbox\Dropbox\STATA class - Summer 2020\week 3"
  }

  log using week3, replace text name("Week_3_Log") //opening a log
* First we load a data set:
use census00.dta, clear
drop perwt // We don't need this variable 
*label our variables for simplicity:
label variable age "Age of Respondent"
label variable educ "Years of Education"
label variable logwk "Log Wages"
label variable exper "Years of Experience"
label variable exper2 "Years of Experience Squared"
label variable black "Binary Variable for Race"
label define race 1 "Black" 0 "White",add
label values black race

*having a look at our variables:
des 
tab black,m
tab age,m

/*
tab is good for looking at the values of your variables, but it's also only good for discrete variable.
for example let's use it for logwk and see what it does */

tab logwk,m // it just floods our screen with information that isn't useful.

*This is where the summarize command (sum for short) is useful, it gives us info to describe our data like the mean, standard deviation etc.
*Let's try it for logwk:
sum logwk
*Now let's try summarizing all of our data:
sum
*Later in the course we will see where this info is stored, and how to retrieve it to make tables.
*The sum command can also gives us more detailed info:
sum logwk,d

/*Now so far, everything we have done has been getting and displaying information for the entire sample.
Most of the time, we are interested in certain statistics and things to describe subgroups in our data,
for example what if we wanted to know the average years of experience among black respondents in our sample? 
Or what if we wanted to see the average  wages for people between 40 and 45 in our sample?

This is where if statements are useful. Most commands in stata allow you to have an "if statement" after them that will only run the command 
for the subset of the data where the statement is true. To see if a command allows if statements, check their help file.

if statements require conditions, to write down conditions we can use:
1) == is the expression required to check if things are equal.
2) != is the expression required to check if things are not-equal.
3) > stricly greater.
4) >= greater than or equal.
5) < stricly lower.
6) <= lower than or equal.
7) & for and.
8) | for or.
*/

gen wages=exp(logwk) // we currently have wages in logs, to get them in levels we use generate and the function exp() which is the exponential function.
decode black, generate(race) // creates a string variable using the value-label associated with black,  i'm doing this to show you if statements with strings.

*Let's see how we can tell that the sum command takes if statements:
help sum

*First let's see the average years if experience among black respondents:
sum exper if black==1
*or:
sum exper if race=="Black" // will give us the same thing because race was created from the value label race and the variable black.
* Note that for all stata commands, the if statement has to come before the options:
sum exper if black==1, d

* Now what if we wanted the statistics for wages of black respondents over 45 in our sample?
sum wages if black==1 & age >45

*We can do it for tabulate as well:
tab age if black==1

*If statements are useful to compare groups, let's see for example:
sum exper // the mean is about 24 years.
*Let's compare wages for people with more than 24 years and less than 24 years of experience:
sum wages if exper<=24
sum wages if exper>24
*People with less experience seem to have higher wages on average, why? Let's check education levels to see:
sum educ if exper<=24
sum educ if exper>24
*It's because they have 2 more years of education on average.
*Let's do it again while controlling for education:
sum wages if exper<=24 & educ==13
sum wages if exper>24 & educ==13


/* If statements are very useful to work with data, and can be very powerful when combined with some of the commands we will be seeing. In a bit
Now we turn our attention to sorting data: 
We can sort data in stata using the sort command, and it allows us to start using two useful things: _n and _N.
_n refers to the position of an observation in your data set, the first observation has _n=1 the second has _n=2 and so on.
_N refers to the total number of observations in your data.
The true use of _n and _N will become apparent when we look at a more complicated use of sorting (bysort).
*/
 
*For now to sort variables we can use:
sort age educ exper  // this will sort the dataset in ascending order by age first, then by educ, then by exper.

*For example we can use _n to create differences:
gen example_difference= educ[_n] - educ[_n-1] // the brackets are used to indicated the row we want to consider in the data
gen number=_n // will create a variable that records the position of rows in the data under this sorting scheme.
gen total=_N // will create a variable with the total number of observations.
br 
*notice that the first row has a missing value for example_difference.
*A note about missing values in stata: They are coded as being a huge number, this can be a problem when using if statements, for example:
sum number if _n==2 | example_difference>10000 // This should only return info about row 2 since example_difference never takes a value larger than 1, but unfortunately missing are counted as a huge number.
*To fix this:
sum number if (_n==2 | example_difference>10000) & example_difference!=. // will only return info on row 2, as we wanted.

*Let's switch to another dataset for the rest of this file:
use student.dta, clear // this is a fake dataset I created containing student ID and sex, year, a class ID, a teacher ID, the student's grade in the class.
br
*We can see how many distinct students, teachers, classes etc we have by using the command distinct (install using ssc intall distinct):
distinct ID teacher class

*now suppose we had duplicates in our data (the following command creates them, don't worry about it, it's rarely if ever used)
expand 2 // this will make an extra copy of each observation
br
help duplicates // the duplicates command can help us take care of this.
duplicates drop // returns our dataset to normal by deleting all duplicates

*we now move to the egen command. egen allows us to create more intricate variables in a simple way:
help egen

*First let's create a classroom indicator, let's define a classroom as: the same class, teacher, and year cell.
egen classroom= group(teacher year class) // the group function for egen will create a new identifying variable that groups people with the same values of the specified varlist.

*we can use egen to standardize our data:
egen avgrade= mean(grade) //creates a variable containing the mean of grade for the whole sample
egen sdgrade=sd(grade) // creates a variable containing the standard deviation of grade for the whole sample
gen stgrade= (grade-avgrade)/(sdgrade)
egen stgrade2= std(grade) // does this in one go, we don't always use this one for reasons you will see in a bit.
 drop avgrade sdgrade stgrade stgrade2
*egen becomes even more powerful for creating variables when combined with bysort. What is bysort?
/* bysort (bys for short) will allow us to manipulate data for subgroups in our data. 
When you specify bysort stata will go over each category specified by itself and perform the demanded data manipulations.
The syntax is bys varlist: command, it is best to only used it with discrete variables.
Notes:
bys teacher year class: gen classroomobs1=_N     
will create a variable where within each classroom cell it will have the total number of observations in that classroom, no longer _N in the whole dataset.
an equivalent thing woulde be:
bys classroom: gen classroomobs2=_N     
*/
*Let's see:
bys teacher year class: gen classroomobs1=_N  
bys classroom: gen classroomobs2=_N
br 
drop classroomobs*

*We can now also create an Id number for someone within a classroom:
bys classroom: gen classID=_n
br
drop classID

*We can have bysort sort by mutliple variables but only loop over some by using:
*bys var1 var2 (var3)
*this will sort by var1 var2 var3, but only consider categories defined by var1 and var2
*how could this be useful? 
*Let's create a variable that tells us if a student had the same teacher in his first and last year:
bys ID (year): gen same_teach_first_last=(teacher[1]==teacher[_N]) // this will only go by categories of ID but sort by ID year.
*This command creates a dummy variable equal to 1 when teacher in a student's first year (we sorted by ID year but are categorizing by ID only, teacher[1] will corespond to teacher in the student's first year)
*is the same as last (we sorted by ID year but are categorizing by ID only, teacher[_N] will corespond to teacher in the student's last year)
tab same* // to see our results, however this counts the same student multiple times to see by student we have to collapse:
preserve 
collapse same*, by(ID)
tab same*
restore 


*We can generate a variable with the mean grade of a student:
bys ID: egen meangrade=mean(grade)
br
*We can standardize grades by classroom (egen std() doesn't work with bys):
bys classroom: egen avgrade= mean(grade) //creates a variable containing the mean of grade for each classroom
bys classroom: egen sdgrade= sd(grade) //creates a variable containing the sd of grade for each classroom
gen stgrade= (grade-avgrade)/(sdgrade)
br

*We can calculate the proportion of females or males per classroom:
tab sex, gen(sex)
rename sex1 female
drop sex2

bys classroom: egen propfemale=mean(female) // gives the proportion of women in a given classroom

*We can also create the proportion of female peers for a student in a classroom exlcuding the student:
bys classroom: gen student_in_classroom=_N-1 // gives the total amount of students in a given classroom minus one
*or:
bys classroom: egen student_in_classroom2=count(female) 
// gives the total amount of students in a given classroom when female is not missing
bys classroom: egen student_in_classroom3=student_in_classroom2-1
br
bys classroom: egen totfem=sum(female) // gives the total amount of females in a given classroom
gen leavemeout= totfem-female // removes student from total if she is female
gen femalepeers= leavemeout/student_in_classroom // calculates the proportion
br


*there is a lot you can do with bysort and egen and being creative will allow you to create complicated stuff quickly, so explore as much as you can!

*We can also use egen to see how many missing value a certain row has:
egen missingvals=rowmiss(*) //here I use the * as shortcut for my whole varlist, we could pick and choose variables if we wanted to.
*or we could calculate the sum of stuff in one row:
egen rowsum=rowtotal(avgrade sdgrade) 
*or we could calculate the standard deviation of stuff in one row:
egen rowsd=rowsd(avgrade sdgrade) 

*these are useful for when we have comparable variables for a given row, something like time-series data etc.

*egen and bysort vs collapse? Both can serve similar functions for creating within groups etc? Let's see what's faster:

*we can use the timer command to see how much times different sections of our code take to run!

timer on 1 // first we start a timer, here i've started timer number 1
bys classroom: egen example=mean(female)
timer off 1 // here i'm setting timer 1 off

timer on 2 // first we start a timer, here i've started timer number 3
preserve 
collapse female, by(classroom)
tab female
restore
timer off 2 // here i'm setting timer 2 off

timer list //shows my timers
timer clear // resets my timers
// It seems bysort was faster but what if we want more variables?

drop example*
 
timer on 1 // first we start a timer, here i've started timer number 1
bys classroom: egen example=mean(female)
bys classroom: egen example2=mean(grade)
bys classroom: egen example3=mean(stgrade)
timer off 1 // here i'm setting timer 1 off

timer on 2 // first we start a timer, here i've started timer number 2
preserve 
collapse female grade stgrade, by(classroom)
tab female
restore
timer off 2 // here i'm setting timer 2 off

timer list //shows my timers
timer clear // resets my timers


//collapse seems a bit faster now, but keep in mind collapse we will need to save another data set and then merge them! That can take more time, we will cover merging soon.


log close Week_3_Log  // closing the log

