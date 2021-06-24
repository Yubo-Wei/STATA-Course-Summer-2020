*********************** Week 1: Introduction to STATA ***********************

/* 

First everyone should:
1- Create a main folder for the class.
2- Create have multiple subfolders, one for each week (and put the relevant files for that week in them).

Being really organized with your files will help a lot with research and work
(and this class as we will see later). This is usually a lesson most of us ended up learning the hard way but hopefully we can spare you some of that. 


This will start with a lot of text but we'll get to practice right after, the idea is not just to teach you the basics but also the "best practices".

Let's start with the different windows in the program, their use will become clearer as we progress:
There are 5 windows:

1- The Command window: While most operations in stata can be performed by selecting them from dropdown menus, it is incredibly inefficient to do so. This is where the Command window at the bottom of the screen comes in, commands are basically words followed by specific input that are linked to stata operations, by using them we will be able to do stuff more efficiently and to provide other people with code to replicate our work.

2- The Result window: This is where the results from your commands will be displayed, it's usually the biggest window in the middle.

3- The History window: Stata does something really useful for us, it keeps track of exactly what we told it to do (aka what commands we used), this information is stored in the history window on the left hand side of the screen.

4- The Variables window: Data in Stata is stored as a variable, the Variables windows is at the top right as contains a list of all the variables, their names and any label we might have attached to them.

5- The Properties window: It's located at the bottom right and contains information on a variable you selected as well as your dataset.


There are also two other important tabs: The data editor and do-file editor, more on these later.

Don't worry if some things above don't make sense yet, we're going to go through all of it step by step:

Let's start with commands in Stata: 

They all take the following structure: "commandname inputs, options"
There are a lot of commands in stata and the only way to know them is practice! Don't worry if you find yourself googling a lot at first, it means you're doing it right.
You can also see the help file for any command by using the help command, this is done by typing "help commandname" in the Command window. Stata help files are a very important resource and contain a lot of information about what a command does, what input it requires and so on.
We'll go through examples of this later.


 
Do-files: As mentioned before, Stata works best when used with commands, and using commands in the most efficient way possible requires using a do-file. A do-file is what we call a script: It is a series of commands that the computer will go through line by line (you can see line numbers on the side) and execute in that order. Do-files can be accessed from the do-file editor and are important for a number of reasons but the main points are: 
1- They automate the process of obtaining results and manipulating your data, by writing a do-file instead of just typing in the command window you can replicate your work at a later time with just one click.
2- They keep track of your work and can be shared with coauthors, coworkers etc.
3- We can add comments describing what our code does.

Point 3 is an important feature of do-files, comments are crucial to any research project: You have to be very generous while commenting your code, leave no details out, this will help you in the future when you want to work on files so that you don't have to spend hours remembering what every line does. Also it makes it possible for other people to follow your code.

To insert a single line comment begin the line with"*", or the comment with "//" , to insert a multiline comment use "/*" to start and "*/" to end it. Again: ALWAYS COMMENT YOUR CODE.


Log-files: Log-files are basically a way to save the output from the result window as a text file, at the begining of the stata session we open a log file and we close it at the end. This will produce a text file containing everything that appeared on the Results window. Let's type help log and see how to do this, we will also see how stata help files look at the same time.

Log files are important for being able to replicate your results, they keep track of what commands you used and the results they produced.

*/

help log 

/*

Why do we set a directory: Setting a directory is basically telling Stata what folder we will be working in. It's useful because when we tell Stata to use a file, save a file, or do anything of the sort, it will know in which folder it should look for it/save it without us having to specify it every time. 

To see what your current working directory is type "pwd" in the command window, pwd stands for "print working directory".

Before setting a working directory, it is useful to check what your user name is, to do so we use the display command: display c(username).
You will see why in a second.


Let's get started with a little of what we have seen
*/
display c(username)

********* How to Properly Start a Do-file *********
* Each command will be followed by a comment explaining it
clear all  

* the clear command clears the workspace, by specifying the input "all" I'm telling Stata to get rid of everything. we will see more uses for this command later.
set more off

* This enables Stata to print results in the Results window without you having to click show more, you can also set it off forever by: "set more off, perm"

    if c(username)=="antoi" {
cd "C:\Users\antoi\Dropbox\STATA class - Summer 2020\week 1"
  }
    if c(username)=="Antoine" {
cd "D:\Dropbox\Dropbox\STATA class - Summer 2020\week 1"
  }
*Note that for stata to know we are looking at words and not numbers we need to use "" around the words.
* cd is the command for setting the work directory. Here you can see the benefit of checking your username with display c(username), we're not going to get into if statements just yet but here's what this basically does here: I work on two computers, and my preferred directories are in two different locations. I ask stata to check what the username is, and then accordingly it will pick the right directory to set! Remember you can check your directory with pwd.

dir 
*the dir command allows you to see all the files in your working directory, always useful to check.
log using week1, replace text name("Week_1_Log")

* this starts a log file as we discussed before. The replace option means that if the file exists it will be replaced with a new one (the append option doesn't replace the file, it instead adds to it), the text option makes sure it's a text file, and name just gives the log a name. Note that at any point you can type "log on" or "log off" to temporarily stop logging. To permanently stop logging type "log close".

use auto.dta, clear

* use is the command to load a Stata dataset (.dta extension) into Stata. Notice we did not have to specify a path or anything because we made sure to specify the directory and that the file was in that directory.
* We will see how to import data from excel and csv at the end of this class.

*Note that you can directly load datasets from the internet as well using the webuse command, let's look at the helpfile.
help webuse
* "webuse querry" is the command to tell us what online directory we have set, this is basically the "pwd" but for web pages.
* we can set a new online directory using "webuse set URL" and return to the default one by just using "webuse set"
* For example the auto dataset we are using is a default stata dataset available on the default online directory, you can access it by: webuse auto.dta, clear

*Now that we have our data loaded in we want to look at our data, the brow command will open the data editor. Note that you can also choose to look at only certain variables by naming them after brow.

browse
*Note that Stata also uses abbreviations. You can use br for browse:
br //  in any help file stata will underline the letters needed for a command's abbreviation:
help browse

/* Notice in the data editor there are different kind of variables (there are different formats to store those in but you don't need to worry about that):
In red we have string variables, a string variable usually contains something like names or a sentence etc. We will see how to deal with those later, but remember that when we want something to be a string we need to have "".
In black we have regular numerical variables.
In blue we have encoded data, we will talk more about this later but the main idea is the following: although what you see is a word in blue, what the computer actually has stored is a number associated with the word. The word is what we call a value label, for example here in the variable "foreign"  we have Domestic being the value label for 0.
*/



/*
Let's look at what a variable label is and why it's useful:
While you should always choose variable names that give you an idea of what the variable actually is, it is often good to add a detailed label to that variable. A label should be a sentence describing what the variable is. This can be done with a simple command as we will see shortly, labels are useful as they help other people read through your work but also because we can later use them when automatically generating graphs and tables.
*\ 

\* To label a variable we should use the following command 
label variable varname "label"

The first word label is the name of the command, the second word variable is us telling Stata we're labeling a variable and not a value label, then varname is just the name of the variable we want to label, and "label" is the label we want attached to that variable
*/

* to see a variable type and it's label, we use the describe command: describe varname

describe make
*this allows us to have a look at the make variable type and it's label.

*Although the variables in this dataset are labeled, let's try replacing one.

label variable make "A car's make and model"

*Let's check the new label:
describe make

*Now let's look at value labels. First it's useful to see if there are any value labels defined in our data:
label list 

*This command gives you the name of the value label, in this case "origin" and then it tells us that "Domestic" is the value label for 0 and "Foreign" is the value label for 1.

*To create add a value label to a variable we need to do 2 things: 1- Create a value label. 2- Attach it to the variable.

*To define a value label:
label define testlabel 1 "foreign" 0 "domestic", add

*Here the first word is the command, the second is telling stata we want to define a new label, the third is the name of this label, then we have the values and their value-label
*This code creates a label called "testlabel"  which assign value label "foreign" to 1 and "domestic" to 0. With the option "add", Stata will create this  label if it doesn't already exist
*The option add can also be used to add more value labels to values (i.e I could add 2 "unknown" for example)
*If we use the option modify, we can add/delete/modify value-label from an existing label.
*If we use the option replace, we will redefine all the value labels in the existing label.


*Now that we have created our label "testlabel" let's just assign it to the variable foreign:
label values foreign testlabel


*we can see that the label testlabel has been assigned to foreign by:
describe foreign
*and we can check the content of it by:
label list


log close Week_1_Log
* Here I'm closing the log

exit
/* exit is a useful command for do-files. When we run a do-file in stata it will run the whole file, sometimes we don't want it to do that, when it gets to exit the do-file will stop. Think about a do-file that contains both data cleaning work and analysis, it's usually a good idea to have an exit after the data cleaning part
so that Stata doesn't continue and run the whole analysis as well before we have a chance to look at the data.


A small note about stata versions, see class recording for more clarity: 
Stata updates almost yearly, we are now up to stata 16. However, certain commands and things change with time, but keep in mind that it's always possible to access the old versions of command by just telling stata what version you want to use!
 https://www.stata.com/features/integrated-version-control/
This website goes over that. This can be useful for those of you who will do RA work and be given possibly old do-files. 

Another note is that while newer versions of stata can read all .dta files, if you have an old version like 12 or 13 certain .dta files won't open. In which case you need to have access
to a newer version and then from there you can save the data as a stata 13 dta or stata 12 dta. 


*/

*Now let's see how to get data from excel or a csv:
clear all

*first we clear everything

*To get data from excel we need to use the import command, see "help import excel for more details:
import excel auto.xlsx, sheet("Sheet1") firstrow clear

*First word is the import command, the second word is us telling stata we're gonna be getting an excel file, third is the name of the file. Then sheet() specifies the name of the sheet we'll get the data from
* firstrow is an option that makes stata treat the first row of Excel data as variable names
* clear tells stata to replace the data in memory in case you forgot to clear before.

save newdata.dta, replace
*to save it as a dta file, help save has more details.

clear all

* to get data from a csv:

import delimited auto.csv, delimiters(",") clear varnames(1)

*First word is the import command, the second word is us telling stata we're gonna be getting csv file, third is the name of the file. 
* Then delimiters refers to the character that will be separating columns. CSV stands for comma separated values, so our delimiter has to be a ",".
* varnames(1) is an option that makes stata treat the first row of data as variable names
* clear tells stata to replace the data in memory in case you forgot to clear before.

*Notice again for both import commands we didn't need to specify a path for the file because we set a directory.


*A small note: Stata also has a bunch of user written commands, these can be installed using the following command "ssc install commandname", ssc stands for Statistical Software Components is an archive of user written commands maintained by Boston College. What "ssc install commandname" basically does is tell stata to go online to the archive and install the relevant files for commandname. Again we will make use of this later so keep it in mind, it is also very helpful for your own research/jobs! User written commands can often really simplify certain tasks.

