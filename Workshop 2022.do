


	********************************
	********************************

			*Data Management*
			
	********************************
	********************************
	clear all
		global datasource "Pest your data soruce path"
		global project	  "Pest path where you want to save your worked data"
	
	 cmdlog using newname // It creates a text file with extension .txt that saves all subsequent  commands that are entered in the Command window.
						// it does not save commands that are executed within a do-file)
						// This is handy because it allows you to use Stata interactively and then make a do-file based on what you have done.
						// load cmdlog, delete commands you nolonger want, and execute the new do-file.
						
	cmdlog close    // close after you finish the work. 
	*Note that it is not useful when you work with do file.
	
set scrollbufsize # //where 10,000<=#<=500,000. By default, the buffer size is 32,000. The change will take effect the next time you lunch stata.


	cd  // let us know the directory we are currently working. If you save without path then your work will be saved in the displayed path
	
	cd "your desired path" //you can change the desired path so that your saved file will be saved there without specifying it again while saving
	
log using filename , append replace [smcl|test] name(logname) //name(logname)-specifies an optional name for the log file to be used while it is open.
log close

translate mylog.mcl mylog.log, replace // tells Stata to convert the SMCL ffile mylog.smcl to a plain-text file called mylog.log

translate mylog.smcl mylog.ps, replace // to convert to a PostScript file, which is useful if you are using TEX or LATEX or 
										// if you want to convert your output into Adobe's Portable Documant Format
				
							*Note:- During previous session, someone said that they prefer .smcl as log file over .log as we cannot manually manupelate the numbers.
									*That is not ture. You can manupelate in log formate and can change it to .smcl. 
									*Only way to check/replicate the result is through 'do' file.
									*So, making do file replicable is very important to publish the Journle in high ranking Journals with empirical works. 

	
	use "$datasource/xh02_s02", clear   // $datasource --is the path of datasource you are using in your work. xh02_s02 is the data file you are using. 
	
	****Before we start***
	
	
	codebook, compact // provide detail information of variables that is in your data sets
	
	
	count // total number of observations. It helps us to quickly check what level of data we are using right now. 
	
	misstable sum  // it gives information on missing variables. 
	
	numlabel, add  // shows the label value
	
	tab v02_01, miss // tabulate if there is any missing
	replace v02_01=0 if v02_01==2  // replacing 2, means no, to zero to make dummy. Remember that value that takes the minimum value becomes the base unless you specify.
	
	label drop V02_01 // droping the label attached to variable value. Often not in use. 
	
	
	**How to label the value of variables.
	label define V02_01 0 "NO" 1 "YES"
	label value v02_01 V02_01
	
	**Creating the dewelling ownership variable
	gen dewelling_ownership=1 if v02_01==1       //it will assign the value 1 in dewelling_ownership (new variable created) if variable v02_01 takes the value 1. 
												//For other attached value in v02_01 (2 in this example)  it generate missing.
	replace dewelling_ownership=0 if v02_01==2 //now assinging the value 0 to dewelling_ownership when  v02_01 takes the value 2.
	
	*****Another way to create same variable. Note- drop dewelling_ownership first before executing the below command as we cannt have same variable name twice in STATA.
	
	gen dewelling_ownership =v02_01==1  // dewelling_ownership takes the value 1 if v02_01 takes the value 1 otherwis takes the value zero. i.e. variable v02_01 takes
										// value zero if v02_01 is other than 1 including missing value (.,.a)
	
	****Creating same variable using recode. Note:-drop before executing as before
	recode v02_01 (1=1) (2=0), gen(dewelling_ownership)
	
	***Another way to create same variable using inlist*****
	 gen dewelling_ownership = 1 if inlist(v02_01,1)
	replace dewelling_ownership = 0 if inlist(v02_01,2)
	
	*Note that they have their own advantages and disadvantages. You will learn as you keep on using it over time. 
	
	***Example  in practice*****
	
	***Creating categories of Age*****
	use "$datasource/xh01_s01.dta" , clear
	
	***using gen***
gen     age_cat=1 if v01_03<=5                    //created new variable called age_cat, takes value one if v01_03 (i.e age) takes value less than or equal to 5
replace age_cat =2 if v01_03>5 & v01_03<=30		 // assign value 2 to variable age_cat if v01_03 (i.e. age) variable is on the range 6 to 30.
replace age_cat=3 if v01_03>30 & v01_03<=60		// similar
replace age_cat=4 if v01_03 >60					// assing value 4 to variable age_cat if v01_03 (i.e. age) is greater than 60 (including missing) 
								
						*Note:- Missing (.) is treated as largest number in STATA
						*To ignore the missing in last command you have to write command as (adding & v01_03!=.)
						*replace age_cat=4 if v01_03 >60	&	v01_03!=.
						* v01_03!=. means variable v01_03 not equal to miss.
						*you can use ~ insteat of ! also.'

 tab age_cat
 
 *** Labeling new variable age_cat,*****
 
 *** It is two step process.
	** First define the label
	** Second attache the define label with variabe.	
label define ac 1 "age 0-5" 2 "age 6-30" 3 "age 31-60" 4 "age 60 plus"  
label value age_cat ac // ac is label name we defined

*or
*** using recode*****

recode v01_03 (0/5=1 "age 0-5" ) (6/30= 2 "age 6-30" )  (31/60=3 "age 31-60" ) (*=4 "age 60 plus") ,  pre(R) label(abc)
								
								*Note '*' mean other values including missing, you can use '61/max' to ignore missing
									* pre(R) uses 'R' as first letter to create new variable. It generate new variable Rv01_03(combining 'R' and v01_03 (variabe name under use))
									*pre(R) is alternative to gen.
									*label(abc) is defining label name as 'abc' like 'ac' first step before. 
tab Rv01_03
***Normally one command line is written in same line. If we write same command line in two or three line using 'Enter' it wont execute.

***Two write same command in different line for asthetic propose and for easyness. 
*You can do it in two ways. using 'delimit' or '///'

*1st using delimit
#delimit ;	
recode v01_03 (0/5=1 "age 0-5" )
 (6/30= 2 "age 6 -30" ) 
 (31/60=3 "age 31-60" ) (*=
 4 "age 60 plus") ,  pre(R) label(abc);
 #delimit cr
 
 *2nd using '///'
 *or
 recode v01_03 (0/5=1 "age 0-5" ) ///
 (6/30= 2 "age 6-30" ) ///
 (31/60=3 "age 31-60" ) (61/max=  ///
 4 "age 60 plus") ,  pre(Rcm) label(abc)
 
*changing  change 1 to 2 and 2 to 1.
 recode v01_02 (1=2 male) (2=1 female), pre(M) label(mf) 
 
 ****** Choose whichever way you find comfortable********
 
 
 ******* Creating Zone******
 
 recode v01_05a (1 9 11 15 =1 "zone1 nepal") (20 10 5 =2 zone2) (* =3 zone3), gen(zone) label(zon)
 
 *or
gen zone=1 if inlist( v01_05a, 1, 9, 11, 15)
replace zone =2 if inlist( v01_05a, 20, 10, 5)
replace zone = 3 if inlist( v01_05a, 1, 9, 11, 15, 20, 10, 5)

*or

gen zone=1 if v01_05a==1|v01_05a==9|v01_05a==11|v01_05a==15
replace zone=2 if v01_05a==20|v01_05a==10|v01_05a==5
replace zone=3 if zone==.
 
***Extracting Head Characteristics, age, sex, marital status, caste-ethnicity
use "$datasource/xh01_s01.dta" , clear
keep xhpsu xhnum v01_02 v01_03 v01_04 v01_06 v01_08 v01_09   // keeping only those variable that are important to us. 
									
									*Note- always remember to keep desired level unique id. 
										  * here I want to extract head information. So, household unique id (i.e. xhpsu xhnum) serves the propose here.
										  * as my interest level of analysis is household and each household has head. 
										  *If you want to do individual level of analysis you have to keep individual level of unique id.
										  *But if you want head information in your individual level of analysis (i.e head information will be same for 
										  *individual of same household) you need to keep household unique id
										  * and merge using 1:m into individual level information
										  

tab v01_04
numlabel, add
tab v01_04

keep if v01_04==1  // keeping only head observations to make it household level information as each household has head.
drop v01_04       //

***Creating Four cateragory of Marrital Status
recode v01_06 (1 2 =1 single) (3 4=2 married) (5 6 7 = 3 divourced_wid), gen(marita_status) label(ms) //marrital stauts
tab marita_status 
drop v01_06

***Generating 
sum v01_03
return list  // just to let you know after some calculation like sum, reg, lots of information are stored internally in scalers and macros.
			// here mean is stored as r(mean)
			// you can use it while creating new variables or for other proposes.
			// also try ereturn list 

*** Creating variables using scalers.

generate agedv = v01_03-r(mean)  // creates a variable called agedv which capture how far a age is from mean.


save "$project/headage,sex", replace  // saving the data we manupelated in our desired path.
									* if you only use 	save headage,sex, replace it will be saved in you current path.
									* to know your current path use 'cd' code.

****Head education and highest education in household******
use "$datasource/xh10_s07", replace
rename v07_idc v01_idc 
merge 1:1 xhpsu xhnum v01_idc using "$datasource/xh01_s01.dta" 
	
	****Highest Education Completed by Individuals******
	
	replace v07_11=0 if v07_11==16  // counting levelless as zero. Only one observation
	gen edu_completed= v07_11  //completed education level for individual aged more than 3
	replace edu_completed= v07_18-1 if edu_completed ==. // one level is reduced from currently attending to get sense of completed level.
	replace edu_completed= 0 if (edu_completed ==.|edu_completed==-1) & v01_03>=3 //who does not have formal education or  they never 
																				 *attended formal education treated as pre-school formal 
																				 *level of education for individual age greater than equal to 3. 

*****label variable edu_completed "completed education level"
recode edu_completed ( 0 =0 "no formal edu") (1/5= 2 "primary 1-5") (6/10=3 "middle 6-10") (11/max=4 higher) if v01_03 >=3, gen(completed_education_label_category) label(edu)
																							*Note-This is individual level information
																							*you can save it along with desired variables if you are doing individual level
																							*analysis
																							*But here I want to create highest level of education in a particular household
																							*as below
					
****Highest Education level in a particular household******
	egen highest_edulev_hhld = max( edu_completed ) if edu_completed!=. & v01_03 >=3, by (xhpsu xhnum ) //creating max eduation level at household level (xhpsu xhnum is
																										*household id).
																			*Notes;- egen command comes with many functional command like max
																					*count,	min, rowtotal	etc. use help egen to know more.					
	

	***Education expenditure to particular individual (particular individual coz its individual level file, we will calculate household level total edu exp as well)****	
		 egen edu_exp=rowtotal(v07_26a v07_26b v07_26c v07_26d v07_26e v07_26f v07_26g)
											*alt code- egen edu_exp=rowtotal(v07_26*) '*' in command means what ever comes after, in our case a b c d e f g comes after v07_26
																*Notes; rowtotal adds all the value of specified variables in row
																		* It treat missing as zero. And missing does mean zero expenditure in our case.
																		*Anways try to know why something is missing and treat them accordingly, like 
																		*treating them as zero or making different categories or dropping depending on 
																		*your objectives. But befor dropping be very careful about it.
		 
		 bys xhpsu xhnum : egen hhld_edu_exp=sum(edu_exp)  //It sum the individual expenditures at household level. bys xhpsu xhnum code ask it to do so.
		
		
  duplicates drop xhpsu xhnum, force // Will it be appropriate here? No coz we will lose head education information in this particular case. If we do not want household head
									// information we can do it. If we use this only useful variable will be highest_edulev_hhld and hhld_edu_exp as this is household level 
									// variables. 
                                     // what is the way out to keep head education as well? The way out is following code.
									 
 keep if v01_04==1 // keeping if head id is one. 
						*How is this command help here?
							*Only head individual level information is kept.
							*As all household has head it also keep household level information like hhld_edu_exp and highest_edulev_hhld.
									
 
 keep xhpsu xhnum edu_completed completed_education_label_category  highest_edu // keep desired information
							*Note: now edu_completed is completed level of education of household head as we kept only household head info. 
								* Similar for this
		
		
 save "$project/eduinfo", replace
 
 ******Above command could be confusing as it contain both individual info and then creating household level******
      *****A way out is to go one at a time with desired variabe like below to calculate household level education exp***
 
 ****Education Expenditure at household level********
 
 use "$datasource/xh10_s07", replace
recode v07_26* (.=0)
gen edu_exp= v07_26a + v07_26b + v07_26c+ v07_26d+ v07_26e +v07_26f+ v07_26g // or egen edu_exp=rowtotal(v07_26a v07_26b v07_26c v07_26d v07_26e v07_26f v07_26g)
										
collapse (sum) edu_exp, by(xhpsu xhnum) // to get household level exp on edu. it sum the individual level expenditure at household and makes the data at household level.
										// For example if individual A and B has exp or 100 and 200 in a praticular household it add total to 300
										// command bys xhpsu xhnum : egen hhld_edu_exp=sum(edu_exp) does the same but this info will be be repeated at household level in 
										// indiviudal level file. To make it household data you have to drop the duplicates or keep only if head. 
										
save "$project/eduexp", replace


 *******merging*******
 
 use "$project/eduexp", clear
 merge 1:1 xhpsu xhnum using "$project/eduinfo" // keeping only matched information
 keep if _merge ==3  //keeping only match info. if you add option keep(3) in above command you dont need to write this command.
 tab _merge
 drop _merge
 save "$project/file1", replace
 *or
 use "$project/eduexp", clear
 merge 1:1 xhpsu xhnum using "$project/eduinfo", keep(3) nogen  // nogen will not generate _merge variable after merging
 misstable sum
  save "$project/file2", replace
  
  merge 1:1 xhpsu xhnum using "$project/headage,sex"
  misstable sum
  drop _merge
  save "$project/file3", replace
  
  *************Calculating Child labour in agriculture*********
  
	********identify who are child adult male and female******
 use "$datasource/xh01_s01", clear
 gen child= v01_03<15
 gen male= (v01_03>=15) & v01_02==1
 gen female=(v01_03>=15) & v01_02==2
  keep xhpsu xhnum v01_idc child male female
 save "$project/hhld dem0", replace
 
 *or Long way three extra line
 
  use "$datasource/xh01_s01", clear
  gen child= 1 if v01_03<15
  replace child=0 if child==.
  gen male=1 if v01_02==1 & v01_03>=15
  replace male=0 if male ==.
  gen female=1 if v01_02==2 & v01_03>=15
  replace female=0 if female==.
  keep xhpsu xhnum v01_idc child male female
	save "$project/hhld dem0", replace
	
	*****lets go to job information*****
	
	use "$datasource/xh17_s10b", clear
	isid xhpsu xhnum v10_02 v10_02_job   // one individual can work in more than one job. Of job id is part of unique id in this file.
	rename v10_02 v01_idc  // in this file individual id name is v10_02 but code is same. individua id name is changing according to section of questionnair. 
						  // to merege individual level file with another individual level file you should make the individua variabe name same. Here we changed v10_02
						  // to v01_idc which is individual id name in 'hhld dem0' data.
	merge m:1 xhpsu xhnum v01_idc using "$project/hhld dem0"
	*tab _merge if  v01_03>=5 & v01_10==1
	keep if _merge ==3
	recode v10_04* (2=0)  // I want know total number of months worked. So want to add it at row level. But yes is coded as 1 and no is coded as 2.
						  // so adding only 1 gives me total number of months worked at different jobs
						  // so making 2 zero and adding 
	egen total_months=rowtotal( v10_04*)  // gives total number of months worked in particular jobs
	tab v10_05a, miss
	recode v10_05a .=0
	recode v10_05b .=0
	gen hours_12months= total_months* v10_05a* v10_05b // hours past 12 months
	gen days_ayear=hours_12months/8 //days past 12 months assuming 8 hours equal to day.
	
	*** To calculate how many days children, adult male and female worked in particular job. 
	gen childdays=child* days_ayear
    gen maledays= male* days_ayear
    gen femaledays= female* days_ayear
	
	*self employment child
	gen childownagdays=childdays* (v10_07==3)
	gen childselfnonag=childdays* (v10_07==4)
	
	***with loop***aso called nested loop. you can disaggregate how many days particular child, adult, male, and female, has worked in particular jobs identified by v10_07
	
	forvalues i= 1/4 {
	foreach var of varlist child male female {
	local j =`i'
	gen `var'_`j'_days= days_ayear*`var' if v10_07==`j'
	local ++j
	}
	}


collapse (sum) childdays maledays femaledays child_1_days- female_4_days , by(xhpsu xhnum) // to know total sum of interest variables at household level and converting it
																					    	//	at household level information.
  
  save "$project/labourdays", replace
  
  ***merging all file
  use "$project/labourdays", clear
  merge 1:1 xhpsu xhnum using "$project/file3"
  drop if _merge ==3
  drop _merge
  order v01_02 v01_03 v01_08 v01_09 marita_status, after( xhnum)
  save "$project/reg_ready", replace
  
  
  
  ********Reshape and Creating Wealth Index****
  
  use "$datasource/xh08_s06c", clear
  count
  isid xhpsu xhnum v06c_idc
  *reshape wide v06_06, i(xhpsu xhnum ) j( v06c_idc)  // will showes error
  keep xhpsu xhnum v06c_idc v06_06  // keep only interest variables
  reshape wide v06_06, i(xhpsu xhnum ) j( v06c_idc)
  recode v06_065* (.=0) 
  
 factor s04q03- s09q6512 , fa(1)
predict pc1_wealth, r
keep hhid pc1_wealth

save "$project/wealthindes", replace
*xtile quantile = pc1_wealth, nquantiles(5)
save "$newdata_wave1\hh_wealth", replace


  *reshape long  // you can switch between long and wide easily once you transform
  *reshape wide  // make your data wide
  reshape long v06_065  , i(xhpsu xhnum) j(items)
  save "$project/longwide", replace
  use "$project/longwide", clear
   reshape long v06_0650  , i(xhpsu xhnum) j(items)
   
  **********Extra We we have Time left**********
  net from "http://www.indiana.edu/~jslsoc/stata/" // the available packages will be listed.
net install spost9_ado
net get spost9_ado  //to download supplementary files (e.g., datasets, sample do-files)

ado uninstall spost9_ado // to uninstall Spost.

***Graphs and Figure****
dotplot race 

graph export myname.emf, replace

graph matrix earnings height weight age educ , half

twoway scatter educ  height || lfit educ height

twoway lfitci educ height, stdp || scatter educ height

tab race mrd, col 

tab race mrd, col nofreq

tab race mrd, row 

tab race mrd, row nofreq

table race region ,  c( mean earnings )   format(%9.2f)

table race region, by (sex) c(n earnings mean earnings sd earnings  sem earnings p1 earnings)   format(%9.2f) sc col row
 
 tabstat race, by (region) stats (mean v n)
 outreg2 using ols.doc, replace/append ctitle(OLS)

cmdlog close