* The goal of this script is to create an imputed data set with values for 
* school term length, student teacher ratio, and percent attendance for 
* black and white children in every county, school level, and year combination
* so for each county there should be 2*3*77 values.  Steps:
	*1. Delete all observations missing key indicators
	*2. Select which observation will be used to represent that county for each school level, segregation type, and year
	*   When there are multiple options, e.g. a report for rural areas and cities in a county,
	*   choose the one with the largest number of students (many other options might be preferable)
	*3. Fillin the data set so that each county, school level, seg type and year 1900-1976 is represented
	*4. Merge with the state level data
	*5. Recode outlying values or implausible values
	*6. Impute information across school levels and between segtype for missing values, e.g. use total for whites if white is missing
	*7. Run mixed models using state average values, place level random effects, and time terms to interpolate between observed values
	*    ( many improvements on this model are possible)
	*8. Need to transform so it can be merged onto places you have lived, so structure should be:
    *state_county year age iSTr_wh iSTr_AA iTL_wh iTL_AA , where age corresponds with school type
* Important identifiers:
	* place and place_num identify each combination of FIPS, category, and categorytype
	* sgroup identifies each race and school level within each place

clear
cd "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/"

* Read in place level policy data and make sure the fips labels are sorted
use "/Users/audreymurchland/Box Sync/REGARDS/Maria's Stata Programs/HistoricalPolicyDatav13.dta", clear
destring school_year, gen(year)

do fipsdo

* 1. DELETE observations missing essential identifying information: place, race, or level

/*originally code was drop if year==. changed to school_year*/
drop if school_year==. | categorytype=="" | school_level=="" | type=="" 

rename county_state oldcounty_state
gen county_state=fips_state*1000+fips_county

* 2. SELECT Make an identifier for each school type category, by state, county, race, and level
* Designate lowest level of place to consider
* Currently state + county 
* concatenate state-county to avoid duplicate county names in diff states
* sort in reverse order by # of students and keep the first obsvn for each place/level,type,year combo.
gen FIPS_st=string(FIPS)
gen segtype=type

gen place=1000*fips_state+fips_county
egen sgroup=group(place segtype school_level)
egen sgroupyr=group(sgroup school_year)
drop if sgroupyr==.
gsort sgroupyr - total_studs 
*This takes the largest regional unit measure available within the county (i.e. in some cases the entire county)
by sgroupyr: keep if _n==1

* 3. FILLIN 
sort place school_level segtype school_year 
* Save the full data set
save "County_Q.dta" , replace

* Create a dataset to fillin, including ensuring there is one observation for
* every year from 1900 to 1975. These observations can be dropped but they 
* are necessary so the fillin command gets all years
* The final data set should have 924 observations for each place
* (77 years times 3 race groups times 4 school level groups)

gen dropobs=.
quietly foreach countyear of numlist 1900/1976{
set obs `=_N+1'
replace school_year=`countyear' if _n==_N
replace dropobs=1 if _n==_N
}
sort place  segtype school_level  school_year 
fillin place segtype school_level  school_year
drop if segtype=="" | school_level=="" | school_year==. | place==.
sort place
drop sgroup
egen sgroup=group(place segtype school_level)

save "County_Qfull.dta", replace 
tsset sgroup school_year

* Save a list of FIPS and places to merge back to filled in data set
* This is a convenience so variables such as place names get filled into the 
* observations we create with fillin

keep if _fillin==0
sort place
by place: gen idinplace=_n
keep if idinplace==1
rename category category_backup
rename categorytype categorytype_backup
keep FIPS place fips* category_backup categorytype_backup county_state seg state
sort place 
save placelist , replace

use "County_Qfull.dta"
merge m:1 place using placelist, update
rename _merge mergeplacenames
** not sure this is the right thing to do...
replace category=category_backup if category==""
replace categorytype=categorytype_backup if categorytype==""

gen segpreBrown=seg*(school_year<=1954)

* 4. MERGE with the state level quality data
gen year=school_year
sort FIPS school_year
merge m:1 FIPS year using State_Qleadcslshort
rename _merge mergestateplace

** For some places, there is no county level data so the merge is from "using" data only
** drop these places from this data set for now
drop if mergestateplace==2

* 5. CLEAN outlying values and make some convenient variables
* Make a race group variable that shuold be balanced, ie one observation at each level for each place and year.
gen     race_group  = 1 if segtype=="Black"
replace race_group  = 0 if segtype=="White"
replace race_group  = 2 if segtype=="Total"

* Make a school level variable that shuold be balanced, ie one observation at each level for each place and year.
gen     levelsort=1  if school_level=="High School"
replace levelsort=3  if school_level=="Elementary School"
replace levelsort=2  if school_level=="Middle School"
replace levelsort=0  if school_level=="Total"

tsset sgroup year
gen decade=round((year-1900)/10)
gen TL=term_length
gen days_attend=total_avgdpy
gen pAtt=days_attend/TL
gen STr=total_studs/ total_teachs

local Qvars="TL STr pAtt"
* Q variables before cleaning
sum `Qvars' days_attend  , de
 
* Outlying values
log using OutlyingValues.txt , text replace
list State year term_length total_avgdpy school_level TL if TL>200 & TL~=.
list State year category type TL total_avgdpy school_level pAtt if pAtt<.3 & pAtt~=.
list State year category type TL pAtt total_teachs total_studs school_level STr if STr<5 & STr~=. & total_studs>20
log close

*AM: 08/07/20 Aleena confirmed there was no preprocessing of TL, only one value of 450 days was corrected;
* Replace days_open values expressed in months
replace TL=20.5*TL/30 if TL>200

*AM: Aleena provided the following information on total_avgdpy:
	/*It does look like for this variable a maximum of 365 was set.  
	Total_avgdpy is a combination of a few variables in some cases. 
	We received attendance information in one of three ways. 
	We wanted average days per year, so that at times had to be calculated based on other variables.

		Average Days/Year: Average Days attended per student per year 
		
		Avg Daily attendance: If a state provides Avg daily attendance, then average daily attendance is divided 
		by the number of students enrolled and then multipled that by the days open variable.  
		(Many states provide the Avg daily attendance)

		Aggregate days attended: Total attendance for all students - If a state provides aggregate days attended, 
		then this number is divided by the number of students enrolled to get the Average Days attended per student per year
	*/
*replace with missing if above 99th percentile or equal to zero
replace STr=. if STr>=92 | STr<=0
replace TL=. if  TL<=0 |  TL>=270
replace days_attend=. if total_avgdpy<=0 | total_avgdpy>=207

* Recreating quality measures after evaluating raw variables
* Recode days attend as a fraction of days open among those not missing (i.e. not outliers)
replace pAtt=days_attend/TL if days_attend>0 & TL>0
replace pAtt=1 if pAtt>1 & pAtt<99999

*Setting reasonable lower and upper bounds for quality measures
 /*AM: Trimming TL at LB 0.1% of overall TL
 * LB: Tl<=46 - set to miss*/
replace TL=. if TL<=46 
 /* UB for TL set at 99.97% of TL*/
 replace TL=. if TL>200 
 
 /*AM: Trimming STr at LB 0.1% of overall STr*/
/* LB for STr1*/
replace STr=. if STr<2 
 /* UB for STr at ~99.9% at 84.5*/
replace STr=. if STr>84.5 

/*AM: Trimming pAtt at LB 0.1% of overall pAtt*/
replace pAtt=. if pAtt<0.116 
*AM: decided 1 is a reasonable UB for pAtt
replace pAtt=. if pAtt>1 

* Q variables after cleaning
local Qvars="TL STr pAtt"
sum `Qvars'

* Recode
gen seg_bl = type=="Black"
gen seg_wh=type=="White"
tab seg type

gen level_elem=school_level=="Elementary School"
gen level_middle=school_level=="Middle School"
gen level_hs=school_level=="High School"

* 6. BORROW DATA across school levels and segtypes
* impute group is the level at which you can impute values across school level
* prior to Brown v Board in segregated schools must distinguish black and white schools
*AM: previously used total values for whites pre Brown but now updating to keep them separate
* after Brown v Board, can impute between black and white schools
* Now need to pull information on elementary, middle or high from adjacent periods or from total;

egen imputegroup=group(place year) 
replace imputegroup=imputegroup+.1 if segpreBrown==1 & segtype=="Black"
replace imputegroup=imputegroup+.2 if segpreBrown==1 & segtype=="White"
*AM updating to make Total a separate group
replace imputegroup=imputegroup+.3 if segpreBrown==1 & segtype=="Total"

* Important to run the whole section together from here to  next ***
local Qvars="STr TL pAtt"
sum `Qvars'
foreach var in `Qvars' {  
 
* First make the variables to represent the values for total, hs, elem, and mid for each place and year
gen igroup_Tot_`var'=`var'  if school_level=="Total"
gen igroup_HS_`var'=`var'   if school_level=="High School"
gen igroup_Elem_`var'=`var' if school_level=="Elementary School"
gen igroup_Mid_`var'=`var'  if school_level=="Middle School"

* Create a value for each Qvar for each level of school from the imputation group
* note: max ignores missing values
sort imputegroup
by imputegroup: egen i`var'_Tot= max(igroup_Tot_`var')
by imputegroup: egen i`var'_HS=  max(igroup_HS_`var')
by imputegroup: egen i`var'_Elem=max(igroup_Elem_`var')
by imputegroup: egen i`var'_Mid= max(igroup_Mid_`var')

*Filling Across School Levels
	* Use the total value if HS is missing
	* if HS still missing, use the elementary school value
	* If HS is still missing, use the middle school value (hardly ever happens)
	* Use the middle school value if elementary school is missing
	* Use the HS value if elementary school is still missing
	* Use the elementary school value if middle school is missing
gen i`var'=`var' if `var' ~=.
replace i`var'=i`var'_Tot  if i`var'==. & school_level=="High School"
replace i`var'=i`var'_Elem if i`var'==. & school_level=="High School"
replace i`var'=i`var'_Mid  if i`var'==. & school_level=="High School"

replace i`var'=i`var'_Mid  if i`var'==. & school_level=="Elementary School"
replace i`var'=i`var'_HS   if i`var'==. & school_level=="Elementary School"
replace i`var'=i`var'_Tot   if i`var'==. & school_level=="Elementary School"

replace i`var'=i`var'_Elem if i`var'==. & school_level=="Middle School"
replace i`var'=i`var'_HS   if i`var'==. & school_level=="Middle School"
replace i`var'=i`var'_Tot  if i`var'==. & school_level=="Middle School"
}

*** Can stop the local loop here
sort imputegroup year school_level
* We have now filled in high, middle, and elementary school values for all places so school totals can be dropped
drop if school_level=="Total"

* Make race-specific policy variables 
egen sgroup2=group(county_state year school_level)
sort sgroup2 type
gen iSTr_Wh=iSTr if type=="White"
gen ipAtt_Wh=ipAtt if type=="White"
gen iTL_Wh=iTL if type=="White"

gen iSTr_AA=iSTr if type=="Black"
gen ipAtt_AA=ipAtt if type=="Black"
gen iTL_AA=iTL if type=="Black"

gen iSTr_Both=iSTr if type=="Total"
gen ipAtt_Both=ipAtt if type=="Total"
gen iTL_Both=iTL if type=="Total"

* Pass the race specific policy variables to a single row for each place-year combination with any observed value, 
*		using the "Total" row (the middle row for each place-year combination)
by sgroup2: replace iSTr_Wh=iSTr_Wh[_n+1] if type=="Total" & type[_n+1]=="White"
by sgroup2: replace iSTr_AA=iSTr_AA[_n-1] if type=="Total" & type[_n-1]=="Black"
by sgroup2: replace ipAtt_Wh=ipAtt_Wh[_n+1] if type=="Total" & type[_n+1]=="White"
by sgroup2: replace ipAtt_AA=ipAtt_AA[_n-1] if type=="Total" & type[_n-1]=="Black"
by sgroup2: replace iTL_Wh=iTL_Wh[_n+1] if type=="Total" & type[_n+1]=="White"
by sgroup2: replace iTL_AA=iTL_AA[_n-1] if type=="Total" & type[_n-1]=="Black"

keep if segtype=="Total"
*Filling in race-specific policy measures based on available data and segregation period
replace iSTr_Wh=iSTr_Both if iSTr_Wh==.
replace iSTr_AA=iSTr_Both if iSTr_AA==. & segpreBrown~=1
replace iSTr_AA=iSTr_Wh if iSTr_AA==. & segpreBrown~=1

replace ipAtt_Wh=ipAtt_Both if ipAtt_Wh==.
replace ipAtt_AA=ipAtt_Both if ipAtt_AA==. & segpreBrown~=1
replace ipAtt_AA=ipAtt_Wh if ipAtt_AA==. & segpreBrown~=1

replace iTL_Wh=iTL_Both if iTL_Wh==.
replace iTL_AA=iTL_Both if iTL_AA==. & segpreBrown~=1
replace iTL_AA=iTL_Wh if iTL_AA==. & segpreBrown~=1

save county_save_temp, replace
*creating year terms for prediction models
use county_save_temp, clear

mkspline yr=year,cubic di

gen year_c=year-1900
*gen year_c=year-1950 
gen year_c_sq=year_c^2
gen year_c_cb=year_c^3

gen yr_cb1=(year-1925)^3
replace yr_cb1=0 if year<1925
gen yr_cb2=(year-1950)^3
replace yr_cb2=0 if year<1950

*7. PREDICT Make prediction model, note that xtmixed and mixed appear identical in this case 
* For some places there are no observations and therefore the random effects cannot be calculated
* In these cases, use the fixed effect predictions
*AM pull R2 values of predicted on imputed 

*xtset place year

*Evaluating state-level policy measures
local StateQVars="pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6"
sum `StateQVars'

*Running prediction models for county-level data
local StateQVars="pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6"
xtmixed iSTr_AA year_c year_c_sq level_elem level_hs segpreBrown `StateQVars'||place: year_c year_c_sq, cov(un)
predict STr_AA_blup_yr STr_AA_blup_yr2 STr_AA_blup_sg ,reffects 
predict STr_AA_fixed
predict pSTr_AA , fitted
replace pSTr_AA=STr_AA_fixed if pSTr_AA==.
*spagplot pSTr year , id(sgroup) nofit 
reg iSTr_AA pSTr_AA
sum pSTr_AA
*AM reclassifying those at extremes
gen pSTr_AA_trm=pSTr_AA
replace pSTr_AA_trm=2 if pSTr_AA<2 & pSTr_AA != .
replace pSTr_AA_trm=84.5 if pSTr_AA>84.5 & pSTr_AA != .
*Evaluating Fit
reg iSTr_AA pSTr_AA_trm
sum pSTr_AA_trm

local StateQVars="pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6"
xtmixed iSTr_Wh year_c year_c_sq level_elem level_hs segpreBrown `StateQVars' ||place: year_c year_c_sq, cov(un) 
predict STr_Wh_blup_yr STr_Wh_blup_yr2 STr_Wh_blup_sg   ,reffects 
predict STr_Wh_fixed
predict pSTr_Wh , fitted
*spagplot pSTr year , id(sgroup) nofit 
replace pSTr_Wh=STr_Wh_fixed if pSTr_Wh==.
reg iSTr_Wh pSTr_Wh
sum pSTr_Wh
*AM reclassifying those at extremes
gen pSTr_Wh_trm=pSTr_Wh
replace pSTr_Wh_trm=2 if pSTr_Wh<2 & pSTr_Wh != .
replace pSTr_Wh_trm=84.5 if pSTr_Wh>84.5 & pSTr_Wh != .
*Evaluating Fit
reg iSTr_Wh pSTr_Wh_trm
sum pSTr_Wh_trm

local StateQVars="pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6"
xtmixed iTL_AA year_c year_c_sq level_elem level_hs  segpreBrown `StateQVars' ||place: year_c year_c_sq
predict TL_AA_blup_yr TL_AA_blup_yr2 TL_AA_blup_sg   ,reffects 
predict TL_AA_fixed
predict pTL_AA , fitted
*gen pTL=TL_fixed + TL_blup_sg + TL_blup_yr*year_c + TL_blup_yr2*year_c_sq
*spagplot pSTr year , id(sgroup) nofit 
replace pTL_AA=TL_AA_fixed if pTL_AA==.
reg iTL_AA pTL_AA
sum pTL_AA
*AM reclassify those at extremes
replace pTL_AA=. if pTL_AA<=46 
replace pTL_AA=. if pTL_AA>200 
*Evaluating Fit
reg iTL_AA pTL_AA
sum pTL_AA

local StateQVars="pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6"
xtmixed iTL_Wh year_c year_c_sq level_elem level_hs segpreBrown `StateQVars' ||place: year_c year_c_sq
predict TL_Wh_blup_yr TL_Wh_blup_yr2 TL_Wh_blup_sg   ,reffects 
predict TL_Wh_fixed
predict pTL_Wh , fitted
*gen pTL_Wh3=TL_Wh_fixed + TL_Wh_blup_sg + TL_Wh_blup_yr*year_c +TL_Wh_blup_yr2*year_c_sq
*spagplot pSTr year , id(sgroup) nofit 
replace pTL_Wh=TL_Wh_fixed if pTL_Wh==.
*AM reclassify those at extremes
replace pTL_Wh=. if pTL_Wh<=46 
replace pTL_Wh=. if pTL_Wh>200 
*Evaluating Fit
reg iTL_Wh pTL_Wh
sum pTL_Wh

local StateQVars="pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6"
xtmixed ipAtt_AA year_c year_c_sq level_elem level_hs segpreBrown `StateQVars' ||place: year_c year_c_sq
predict pAtt_AA_blup_yr pAtt_AA_blup_yr2 pAtt_AA_blup_sg ,reffects 
predict pAtt_AA_fixed
predict ppAtt_AA , fitted
*gen ppAtt=pAtt_fixed+pAtt_blup_sg+pAtt_blup_yr*year_c + pAtt_blup_yr2*year_c_sq
*spagplot pSTr year , id(sgroup) nofit 
replace ppAtt_AA=pAtt_AA_fixed if ppAtt_AA==.
reg ipAtt_AA ppAtt_AA
sum ipAtt_AA 
*AM reclassifying those at extremes
replace ppAtt_AA=. if ppAtt_AA<0.116 
replace ppAtt_AA=. if ppAtt_AA>1 
*Evaluating Fit
reg ipAtt_AA ppAtt_AA
sum ipAtt_AA 

local StateQVars="pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6"
xtmixed ipAtt_Wh year_c year_c_sq level_elem level_hs segpreBrown `StateQVars' ||place: year_c year_c_sq
predict pAtt_Wh_blup_yr pAtt_Wh_blup_yr2 pAtt_Wh_blup_sg ,reffects 
predict pAtt_Wh_fixed
predict ppAtt_Wh , fitted
*gen ppAtt=pAtt_fixed Att_blup_sg+pAtt_blup_yr*year_c + pAtt_blup_yr2*year_c_sq
*spagplot pSTr year , id(sgroup) nofit 
replace ppAtt_Wh=pAtt_Wh_fixed if ppAtt_Wh==.
*AM reclassifying those at extremes
replace ppAtt_Wh=. if ppAtt_Wh<0.116 
replace ppAtt_Wh=. if ppAtt_Wh>1 
*Evaluating Fit
reg ipAtt_Wh ppAtt_Wh
sum ipAtt_Wh 

**************************************************
save County_Qfull , replace
*keep FIPS fips* county_state Category CategoryType Matched_Category Matched_CategoryType sgroup2 stateab division region pSTr* pTL* ppAtt* iSTr* iTL* ipAtt* year 
sort county_state year school_level

use County_Qfull, clear
do fipsdo
keep state year fips_county fips_state county_state division region ///
category categorytype school_level seg segpreBrown ///
level_elem level_middle level_hs ///
total_avgdpy term_length male_teachs female_teachs total_teachs male_studs female_studs total_studs ///
male_salary female_salary total_salary ///
pAtt STr TL ///
iSTr_AA iSTr_Wh iSTr_Both iTL_AA iTL_Wh iTL_Both ipAtt_AA ipAtt_Wh ipAtt_Both ///
pSTr_AA pSTr_Wh pTL_AA pTL_Wh ppAtt_AA ppAtt_Wh

save County_Qshort , replace
save "HxCountyQ_091620.dta", replace

/* alternative prediction model, with splines
xtmixed iSTr yr1-yr4  level_elem level_hs seg_bl  `StateQVars' ||sgroup: 
predict STr_blup_sg ,reffects level(sgroup)
predict STr_fixed
gen pSTr=STr_fixed+STr_blup_sg
*spagplot pSTr year , id(sgroup) nofit 
reg iSTr pSTr

xtmixed iTL yr1-yr4  level_elem level_hs seg_bl  `StateQVars' ||sgroup: 
predict TL_blup_sg ,reffects level(sgroup)
predict TL_fixed
gen pTL=TL_fixed+TL_blup_sg
*spagplot pSTr year , id(sgroup) nofit 
reg iTL pTL

xtmixed ipAtt yr1-yr4  level_elem level_hs seg_bl  `StateQVars' ||sgroup: 
predict pAtt_blup_sg ,reffects level(sgroup)
predict pAtt_fixed
gen ppAtt=pAtt_fixed+pAtt_blup_sg
*spagplot pSTr year , id(sgroup) nofit 
reg ipAtt ppAtt

*xtmixed St_TL_AA year_c year_c_sq segpreBrown || region: || FIPS: year_c year_c_sq ;

/*
* How well does the past predict current missing values
xi: reg stratio yr1-yr4 stratiol1 stratiol2 days_openl1 days_openl2 days_attendl1 days_attendl2 
reg days_attend yr1-yr4 stratiol1 stratiol2 days_openl1 days_openl2 days_attendl1 days_attendl2
reg days_open yr1-yr4 stratiol1 stratiol2 days_openl1 days_openl2 days_attendl1 days_attendl2 


* Describe
graph twoway (scatter stratio year )
graph twoway (scatter days_open year )
graph twoway (scatter days_attend year )
sum stratio , de
sum days_open , de
sum days_attend, de
tab school_level if State=="California"
spagplot days_attend  year if State=="Alabama" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_attend  year if State=="California" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_open  year if State=="California" & school_level=="Elementary School" , id(sgroup) nofit
spagplot stratio  year if State=="California" & school_level=="Elementary School" , id(sgroup) nofit

tab school_level if State=="Colorado"
spagplot days_attend  year if State=="Colorado" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_open  year if State=="Colorado" & school_level=="Elementary School" , id(sgroup) nofit
spagplot stratio  year if State=="Colorado" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_attend  year if State=="Colorado" & school_level=="Total" , id(sgroup) nofit
spagplot days_open  year if State=="Colorado" & school_level=="Total" , id(sgroup) nofit
spagplot stratio  year if State=="Colorado" & school_level=="Total" , id(sgroup) nofit

tab school_level if State=="Connecticut"
spagplot days_attend  year if State=="Connecticut" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_open  year if State=="Connecticut" & school_level=="Elementary School" , id(sgroup) nofit
spagplot stratio  year if State=="Connecticut" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_attend  year if State=="Connecticut" & school_level=="High School" , id(sgroup) nofit
spagplot days_open  year if State=="Connecticut" & school_level=="High School" , id(sgroup) nofit
spagplot stratio  year if State=="Connecticut" & school_level=="High School" , id(sgroup) nofit

tab school_level if State=="Illinois"
spagplot days_attend  year if State=="Illinois" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_open  year if State=="Illinois" & school_level=="Elementary School" , id(sgroup) nofit
spagplot stratio  year if State=="Illinois" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_attend  year if State=="Illinois" & school_level=="High School" , id(sgroup) nofit
spagplot days_open  year if State=="Illinois" & school_level=="High School" , id(sgroup) nofit
spagplot stratio  year if State=="Illinois" & school_level=="High School" , id(sgroup) nofit
spagplot days_attend  year if State=="Illinois" & school_level=="Total" , id(sgroup) nofit
spagplot days_open  year if State=="Illinois" & school_level=="Total" , id(sgroup) nofit
spagplot stratio  year if State=="Illinois" & school_level=="Total" , id(sgroup) nofit

sum if State=="Oregon"
spagplot days_attend  year if State=="Oregon" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_open  year if State=="Oregon" & school_level=="Elementary School" , id(sgroup) nofit
spagplot stratio  year if State=="Oregon" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_attend  year if State=="Oregon" & school_level=="High School" , id(sgroup) nofit
spagplot days_open  year if State=="Oregon" & school_level=="High School" , id(sgroup) nofit
spagplot stratio  year if State=="Oregon" & school_level=="High School" , id(sgroup) nofit
spagplot days_attend  year if State=="Oregon" & school_level=="Total" , id(sgroup) nofit
spagplot days_open  year if State=="Oregon" & school_level=="Total" , id(sgroup) nofit
spagplot stratio  year if State=="Oregon" & school_level=="Total" , id(sgroup) nofit

tab school_level if State=="Pennsylvania"
sum if State=="Pennsylvania" & days_attend ~= .
spagplot days_attend  year if State=="Pennsylvania" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_open  year if State=="Pennsylvania" & school_level=="Elementary School" , id(sgroup) nofit
spagplot stratio  year if State=="Pennsylvania" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_attend  year if State=="Pennsylvania" & school_level=="High School" , id(sgroup) nofit
spagplot days_open  year if State=="Pennsylvania" & school_level=="High School" , id(sgroup) nofit
spagplot stratio  year if State=="Pennsylvania" & school_level=="High School" , id(sgroup) nofit
spagplot days_attend  year if State=="Pennsylvania" & school_level=="Total" , id(sgroup) nofit
spagplot days_open  year if State=="Pennsylvania" & school_level=="Total" , id(sgroup) nofit
spagplot stratio  year if State=="Pennsylvania" & school_level=="Total" , id(sgroup) nofit

tab school_level if State=="South Carolina"
sum days_open if State=="South Carolina" & days_attend ~= . & year>1960
spagplot days_attend  year if State=="South Carolina" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_open  year if State=="South Carolina" & school_level=="Elementary School" , id(sgroup) nofit
spagplot stratio  year if State=="South Carolina" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_attend  year if State=="South Carolina" & school_level=="High School" , id(sgroup) nofit
spagplot days_open  year if State=="South Carolina" & school_level=="High School" , id(sgroup) nofit
spagplot stratio  year if State=="South Carolina" & school_level=="High School" , id(sgroup) nofit
spagplot days_attend  year if State=="South Carolina" & school_level=="Total" , id(sgroup) nofit
spagplot days_open  year if State=="South Carolina" & school_level=="Total" , id(sgroup) nofit
spagplot stratio  year if State=="South Carolina" & school_level=="Total" , id(sgroup) nofit

tab school_level if State=="Texas"
sum days_open if State=="STexas" & days_attend ~= . & year>1960
spagplot days_attend  year if State=="Texas" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_open  year if State=="Texas" & school_level=="Elementary School" , id(sgroup) nofit
spagplot stratio  year if State=="Texas" & school_level=="Elementary School" , id(sgroup) nofit
spagplot days_attend  year if State=="Texas" & school_level=="High School" , id(sgroup) nofit
spagplot days_open  year if State=="Texas" & school_level=="High School" , id(sgroup) nofit
spagplot stratio  year if State=="Texas" & school_level=="High School" , id(sgroup) nofit
spagplot days_attend  year if State=="Texas" & school_level=="Total" , id(sgroup) nofit
spagplot days_open  year if State=="Texas" & school_level=="Total" , id(sgroup) nofit
spagplot stratio  year if State=="Texas" & school_level=="Total" , id(sgroup) nofit

reg stratio yr1-yr4 stratiol1 stratiol2 days_openl1 days_openl2 days_attendl1 days_attendl2 if State=="Colorado"
* Trends over time
mixed stratio year seg_bl seg_wh level_elem level_middle level_hs || State:
mixed days_open year seg_bl seg_wh level_elem level_middle level_hs || State:
mixed days_attend year seg_bl seg_wh level_elem level_middle level_hs || State:
*/
