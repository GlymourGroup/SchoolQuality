* This code imputes values of state average quality variables for years between
* the years directly observed, from 1900 through 1975.
* St_ prefix indicates state level variables
* TL= term length 
* Att=days attended each term, 
* STr=student teacher ratio
* Make 3 versions of each variable, black, white, and all
* Using segregated data when available
* when no segregated data are available, it uses the overall value for white kids
* and the overall data for blacks only in non-segregated state/year combinations
* (e.g., pre-1954 in non-seg states or after 1954 in seg states).
* the prefix p indicates predicted. 
* So the final variables are: pSt_TL_AA pSt_TL_Wh pSt_pAtt_AA pSt_pAtt_Wh pSt_STr_AA pSt_STr_Wh
* where pSt_TL_AA = predicted state average term length for African American children

clear
cd "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/"

#delimit ;
 
use State_Qvars;
capture drop v6-v20;
capture drop v22-v31;

* List the variables we want to use as inputs;
local Stvars="St_TL_AA St_TL_Wh St_TL_All St_Att_AA St_Att_Wh St_Att_All St_Teach_AA St_Teach_Wh St_Teach_All  St_Stud_AA  St_Stud_Wh St_Stud_All";
sum `Stvars';
* Replace missing values;
foreach var in `Stvars' {  ;
 destring `var' , replace i(","); 
 capture replace `var'=. if `var'==-99 | `var'==99 ;
} ;

* Make sure there is at least 1 obsvn for every year in the range from 1900 to 1976;
*fillin command doesn't work unless there is an observation so we are using this forloop instead;
gen dropobs=.;
quietly foreach countyear of numlist 1900/1976{ ;
set obs `=_N+1';
replace year=`countyear' if _n==_N;
replace dropobs=1 if _n==_N;
};

*fillin FIPS year, so every possible year/state combination is represented in the data;
sort FIPS year;
tsset FIPS year;
tsfill ,full;

* Must run fipsdo again to give state names to observations created in the fillin;
do fipsdo;
drop if dropobs==1;

* Calculate attendance and student teacher ratios;
* Creating values before imputation, MMG decision 6/28/20; 
gen St_pAtt_AA=St_Att_AA/St_TL_AA;
gen St_pAtt_Wh=St_Att_Wh/St_TL_Wh;
gen St_pAtt_All=St_Att_All/St_TL_All;

gen St_STr_AA=St_Stud_AA/St_Teach_AA;
gen St_STr_Wh=St_Stud_Wh/St_Teach_Wh;
gen St_STr_All=St_Stud_All/St_Teach_All;

sum `Stvars' St_pAtt_AA St_pAtt_Wh St_pAtt_All St_STr_AA St_STr_Wh St_STr_All;

* Make year codes for use later;
mkspline yr=year,cubic;
gen year_c=year-1950;
gen year_c_sq=year_c^2;
xtset FIPS year_c;

* Make black values for each state and year, using overall values when AA vals are missing
* Except for segregated states pre-brown, in which case leave as missing;
gen segpreBrown=seg*(year<1955);
replace St_TL_AA=St_TL_All if St_TL_AA==. & segpreBrown==0;
replace St_pAtt_AA=St_pAtt_All if St_pAtt_AA==. & segpreBrown==0;
replace St_STr_AA=St_STr_All if St_STr_AA==. & segpreBrown==0;

* Make white values for each state and year, using overall values when wh vals are missing;
replace St_TL_Wh=St_TL_All if St_TL_Wh==.;
replace St_pAtt_Wh=St_pAtt_All if St_pAtt_Wh==.;
replace St_STr_Wh=St_STr_All if St_STr_Wh==.;

* Model trends, comparing alternative models;
*NB: the following could have been used to calculate the predicted values for M4s, however we kept the 
*code as-is to avoid any errors. Reviewed by MMG and ARM 07/06/20;
	*
	
* TERM LENGTH
	/* Commenting out models for exploration, M4 used for imputation
	* M1: random intercepts for states and a linear slope term;
	xtmixed St_TL_AA year_c segpreBrown || FIPS:  ;
	xtmixed St_TL_Wh year_c segpreBrown || FIPS:  ;
	* M2: random intercepts for states and a linear+quadratic slope term ;
	xtmixed St_TL_AA year_c year_c_sq segpreBrown || FIPS:  ;
	xtmixed St_TL_Wh year_c year_c_sq segpreBrown || FIPS:  ;
	* M3: random intercepts + spline terms for secular trends;
	xtmixed St_TL_AA yr1 yr2 yr3 yr4  segpreBrown|| FIPS: ;
	xtmixed St_TL_Wh yr1 yr2 yr3 yr4  segpreBrown|| FIPS: ;
	*/
* M4: random intercept for region and random intercepts & lin + quad slopes for states ;
xtmixed St_TL_AA year_c year_c_sq segpreBrown || region: || FIPS: year_c year_c_sq ;
predict St_TL_AA_blup_rg ,reffects level(region);
predict St_TL_AA_blup_yr St_TL_AA_blup_yr2 St_TL_AA_blup_fips  ,reffects level(FIPS);
predict St_TL_AA_fixed;
gen pSt_TL_AA=St_TL_AA_fixed + St_TL_AA_blup_rg + St_TL_AA_blup_fips + St_TL_AA_blup_yr*year_c + St_TL_AA_blup_yr2*year_c_sq;
*spagplot pSt_TL_AA year , id(FIPS) nofit ;
reg St_TL_AA pSt_TL_AA;

xtmixed St_TL_Wh year_c year_c_sq segpreBrown || region: || FIPS: year_c year_c_sq ;
predict St_TL_Wh_blup_rg ,reffects level(region);
predict St_TL_Wh_blup_yr St_TL_Wh_blup_yr2 St_TL_Wh_blup_fips  ,reffects level(FIPS);
predict St_TL_Wh_fixed;
gen pSt_TL_Wh=St_TL_Wh_fixed + St_TL_Wh_blup_rg + St_TL_Wh_blup_fips + St_TL_Wh_blup_yr*year_c + St_TL_Wh_blup_yr2*year_c_sq;
*spagplot pSt_TL_Wh year , id(FIPS) nofit ;
reg St_TL_Wh pSt_TL_Wh;


* ATTENDANCE RATIO
	/* Commenting out models for exploration, M4 used for imputation
	* M1: random intercepts for states and a linear slope term;
	xtmixed St_pAtt_AA year_c segpreBrown || FIPS:  ;
	xtmixed St_pAtt_Wh year_c segpreBrown || FIPS:  ;
	* M2: random intercepts for states and a linear+quadratic slope term ;
	xtmixed St_pAtt_AA year_c year_c_sq segpreBrown || FIPS:  ;
	xtmixed St_pAtt_Wh year_c year_c_sq segpreBrown || FIPS:  ;
	* M3: random intercepts + spline terms for secular trends;
	xtmixed St_pAtt_AA yr1 yr2 yr3 yr4  segpreBrown|| FIPS: ;
	xtmixed St_pAtt_Wh yr1 yr2 yr3 yr4  segpreBrown|| FIPS: ;
	*/
* M4: random intercept for region and random intercepts & lin + quad slopes for states ;
xtmixed St_pAtt_AA year_c year_c_sq segpreBrown || region: || FIPS: year_c year_c_sq ;
predict St_pAtt_AA_blup_rg ,reffects level(region);
predict St_pAtt_AA_blup_yr St_pAtt_AA_blup_yr2 St_pAtt_AA_blup_fips  ,reffects level(FIPS);
predict St_pAtt_AA_fixed;
gen pSt_pAtt_AA=St_pAtt_AA_fixed + St_pAtt_AA_blup_rg + St_pAtt_AA_blup_fips + St_pAtt_AA_blup_yr*year_c + St_pAtt_AA_blup_yr2*year_c_sq;
*spagplot pSt_pAtt_AA year  , id(FIPS) nofit ;
reg St_pAtt_AA pSt_pAtt_AA;

xtmixed St_pAtt_Wh year_c year_c_sq segpreBrown || region: || FIPS: year_c year_c_sq ;
predict St_pAtt_Wh_blup_rg ,reffects level(region);
predict St_pAtt_Wh_blup_yr St_pAtt_Wh_blup_yr2 St_pAtt_Wh_blup_fips  ,reffects level(FIPS);
predict St_pAtt_Wh_fixed;
gen pSt_pAtt_Wh=St_pAtt_Wh_fixed + St_pAtt_Wh_blup_rg + St_pAtt_Wh_blup_fips + St_pAtt_Wh_blup_yr*year_c + St_pAtt_Wh_blup_yr2*year_c_sq;
*spagplot pSt_pAtt_Wh year  , id(FIPS) nofit ;
reg St_pAtt_Wh pSt_pAtt_Wh;

* STUDENT TEACHER RATIO
	/* Commenting out models for exploration, M4 used for imputation
	* M1: random intercepts for states and a linear slope term;
	xtmixed St_STr_AA year_c segpreBrown || FIPS:  ;
	xtmixed St_STr_Wh year_c segpreBrown || FIPS:  ;
	* M2: random intercepts for states and a linear+quadratic slope term ;
	xtmixed St_STr_AA year_c year_c_sq segpreBrown || FIPS:  ;
	xtmixed St_STr_Wh year_c year_c_sq segpreBrown || FIPS:  ;
	* M3: random intercepts + spline terms for secular trends;
	xtmixed St_STr_AA yr1 yr2 yr3 yr4  segpreBrown|| FIPS: ;
	xtmixed St_STr_Wh yr1 yr2 yr3 yr4  segpreBrown|| FIPS: ;
	*/
* M4: random intercept for region and random intercepts & lin + quad slopes for states ;
xtmixed St_STr_AA year_c year_c_sq segpreBrown || region: || FIPS: year_c year_c_sq ;
predict St_STr_AA_blup_rg ,reffects level(region);
predict St_STr_AA_blup_yr St_STr_AA_blup_yr2 St_STr_AA_blup_fips  ,reffects level(FIPS);
predict St_STr_AA_fixed;
gen pSt_STr_AA=St_STr_AA_fixed + St_STr_AA_blup_rg + St_STr_AA_blup_fips + St_STr_AA_blup_yr*year_c + St_STr_AA_blup_yr2*year_c_sq;
*spagplot pSt_STr_AA year  , id(FIPS) nofit ;
reg St_STr_AA pSt_STr_AA;

xtmixed St_STr_Wh year_c year_c_sq segpreBrown || region: || FIPS: year_c year_c_sq ;
predict St_STr_Wh_blup_rg ,reffects level(region);
predict St_STr_Wh_blup_yr St_STr_Wh_blup_yr2 St_STr_Wh_blup_fips  ,reffects level(FIPS);
predict St_STr_Wh_fixed;
gen pSt_STr_Wh=St_STr_Wh_fixed + St_STr_Wh_blup_rg + St_STr_Wh_blup_fips + St_STr_Wh_blup_yr*year_c + St_STr_Wh_blup_yr2*year_c_sq;
*spagplot pSt_STr_Wh year , id(FIPS) nofit ;
reg St_STr_Wh pSt_STr_Wh;

sum pSt_TL_AA St_TL_AA pSt_TL_Wh St_TL_Wh pSt_pAtt_AA St_pAtt_AA pSt_pAtt_Wh St_pAtt_Wh pSt_STr_AA St_STr_AA pSt_STr_Wh St_STr_Wh; 
corr pSt_TL_AA St_TL_AA pSt_TL_Wh St_TL_Wh pSt_pAtt_AA St_pAtt_AA pSt_pAtt_Wh St_pAtt_Wh pSt_STr_AA St_STr_AA pSt_STr_Wh St_STr_Wh;

*creating leads for state quality measures*;
#delimit ;	
sort FIPS year;

*AM added "by FIPS:" to each command on 12.07.18 after consult with MMG;
by FIPS: gen pSt_TL_AA_1= pSt_TL_AA[_n+1];
by FIPS: gen pSt_TL_AA_6= pSt_TL_AA[_n+6];
by FIPS: gen pSt_TL_AA_10= pSt_TL_AA[_n+10];
by FIPS: gen pSt_TL_AA_14= pSt_TL_AA[_n+14];

by FIPS: gen pSt_TL_Wh_1= pSt_TL_Wh[_n+1];
by FIPS: gen pSt_TL_Wh_6= pSt_TL_Wh[_n+6];
by FIPS: gen pSt_TL_Wh_10= pSt_TL_Wh[_n+10];
by FIPS: gen pSt_TL_Wh_14= pSt_TL_Wh[_n+14];

by FIPS: gen pSt_pAtt_AA_1= pSt_pAtt_AA[_n+1];
by FIPS: gen pSt_pAtt_AA_6= pSt_pAtt_AA[_n+6];
by FIPS: gen pSt_pAtt_AA_10= pSt_pAtt_AA[_n+10];
by FIPS: gen pSt_pAtt_AA_14= pSt_pAtt_AA[_n+14];

by FIPS: gen pSt_pAtt_Wh_1= pSt_pAtt_Wh[_n+1];
by FIPS: gen pSt_pAtt_Wh_6= pSt_pAtt_Wh[_n+6];
by FIPS: gen pSt_pAtt_Wh_10= pSt_pAtt_Wh[_n+10];
by FIPS: gen pSt_pAtt_Wh_14= pSt_pAtt_Wh[_n+14];

by FIPS: gen pSt_STr_AA_1= pSt_STr_AA[_n+1];
by FIPS: gen pSt_STr_AA_6= pSt_STr_AA[_n+6];
by FIPS: gen pSt_STr_AA_10= pSt_STr_AA[_n+10];
by FIPS: gen pSt_STr_AA_14= pSt_STr_AA[_n+14];

by FIPS: gen pSt_STr_Wh_1= pSt_STr_Wh[_n+1];
by FIPS: gen pSt_STr_Wh_6= pSt_STr_Wh[_n+6];
by FIPS: gen pSt_STr_Wh_10= pSt_STr_Wh[_n+10];
by FIPS: gen pSt_STr_Wh_14= pSt_STr_Wh[_n+14];

save "State_Qimputeindallvarlead.dta", replace;

/*Adding CSL Data to School Quality Measures*/
use "State_Qimputeindallvarlead.dta", clear;

keep FIPS year segpreBrown State stateab ///
St_TL_AA St_TL_Wh St_pAtt_AA St_pAtt_Wh St_STr_AA St_STr_Wh region region_st ///
pSt_TL_AA pSt_TL_Wh pSt_pAtt_AA pSt_pAtt_Wh pSt_STr_AA pSt_STr_Wh ///
pSt_TL_AA_1 pSt_TL_Wh_1 pSt_pAtt_AA_1 pSt_pAtt_Wh_1 pSt_STr_AA_1 pSt_STr_Wh_1 ///
pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_10 pSt_TL_Wh_10 pSt_pAtt_AA_10 pSt_pAtt_Wh_10 pSt_STr_AA_10 pSt_STr_Wh_10 ///
pSt_TL_AA_14 pSt_TL_Wh_14 pSt_pAtt_AA_14 pSt_pAtt_Wh_14 pSt_STr_AA_14 pSt_STr_Wh_14;

sort FIPS year;
save "State_Qlead.dta", replace;

/****************************************/
/*			ADDING CSLs					*/
/****************************************/
clear ;
cd "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/";

import delimited "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_CSL/cslprep.csv";
*(49 vars, 3,577 obs)
save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_CSL/cslprep.dta", replace;

gen FIPS = fips;
sort FIPS year;

save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_CSL/cslprep.dta", replace;

use "State_Qlead.dta", clear;
merge 1:1 FIPS year using "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_CSL/cslprep.dta";
save "State_Qleadcsl.dta", replace;

*Creating Leads for CSL measures*;
*AM: Added "by FIPS:" so that csl measures are fips specific
use "State_Qleadcsl.dta", clear;
sort FIPS year;
by FIPS: gen enrolage_6=enrolage[_n+6];
by FIPS: gen drop_age_14=drop_age[_n+14];
by FIPS: gen work_age_14=work_age[_n+14];

/*AM UPDATED 07/01/20 with MMG*/
gen comyrs = drop_age_14 - enrolage_6;
replace comyrs=. if drop_age_14==0 | enrolage_6==0;
replace comyrs=. if drop_age_14 < enrolage_6;
gen comyrs_miss=1 if comyrs==.;
replace comyrs_miss=0 if comyrs!=.;

gen childcom = work_age_14 - enrolage_6;
replace childcom=. if work_age_14==0 | enrolage_6==0;
replace childcom=. if work_age_14 < enrolage_6;
gen childcom_miss=1 if childcom==.;
replace childcom_miss=0 if childcom!=.;

*Creating Fillin CSL variables by pulling forward policy info until updated
*AM added 07/08/20;
tsset FIPS year;
bysort FIPS: carryforward childcom, gen(childcom_fill);
bysort FIPS: carryforward comyrs, gen(comyrs_fill);

*Creating Analysis Variables
mkspline yr=year,cubic;
gen year_c=year-1950;
gen year_c_sq=year_c^2;
xtset FIPS year_c;

*PREDICTED COMPULSORY SCHOOLING LAWS
	/* Commenting out models for exploration, M4 used for imputation
	* M1: random intercepts for states and a linear slope term;
	xtmixed comyrs year_c segpreBrown || FIPS:  ;
	xtmixed childcom year_c segpreBrown || FIPS:  ;
	* M2: random intercepts for states and a linear+quadratic slope term ;
	xtmixed comyrs year_c year_c_sq segpreBrown || FIPS:  ;
	xtmixed childcom year_c year_c_sq segpreBrown || FIPS:  ;
	* M3: random intercepts + spline terms for secular trends;
	xtmixed comyrs yr1 yr2 yr3 yr4  segpreBrown|| FIPS: ;
	xtmixed childcom yr1 yr2 yr3 yr4  segpreBrown|| FIPS: ;
	*/

* M4: random intercept for region and random intercepts & lin + quad slopes for states ;
xtmixed comyrs year_c year_c_sq segpreBrown || region: || FIPS: year_c year_c_sq ;
predict comyrs_blup_rg ,reffects level(region);
predict comyrs_blup_yr comyrs_blup_yr2 comyrs_blup_fips  ,reffects level(FIPS);
predict comyrs_fixed;
gen pcomyrs=comyrs_fixed + comyrs_blup_rg + comyrs_blup_fips + comyrs_blup_yr*year_c + comyrs_blup_yr2*year_c_sq;

xtmixed childcom year_c year_c_sq segpreBrown || region: || FIPS: year_c year_c_sq ;
predict childcom_blup_rg ,reffects level(region);
predict childcom_blup_yr childcom_blup_yr2 childcom_blup_fips  ,reffects level(FIPS);
predict childcom_fixed;
gen pchildcom=childcom_fixed + childcom_blup_rg + childcom_blup_fips + childcom_blup_yr*year_c + childcom_blup_yr2*year_c_sq;

/*Filling in State and state abbreviations*/
/*AM Added 07/09/20*/
do fipsfill;

/*Removing Alaska and Hawaii and years after 1976*/
/*AM Added 07/09/20*/
drop if FIPS==2 | FIPS==15;
drop if year>1976;

save "State_Qleadcsl.dta", replace;

/*Saving Smaller Version of Dataset*/
keep FIPS year segpreBrown State stateab region region_st ///
St_TL_AA St_TL_Wh St_pAtt_AA St_pAtt_Wh St_STr_AA St_STr_Wh ///
pSt_TL_AA pSt_TL_Wh pSt_pAtt_AA pSt_pAtt_Wh pSt_STr_AA pSt_STr_Wh ///
pSt_TL_AA_1 pSt_TL_Wh_1 pSt_pAtt_AA_1 pSt_pAtt_Wh_1 pSt_STr_AA_1 pSt_STr_Wh_1 ///
pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_10 pSt_TL_Wh_10 pSt_pAtt_AA_10 pSt_pAtt_Wh_10 pSt_STr_AA_10 pSt_STr_Wh_10 ///
pSt_TL_AA_14 pSt_TL_Wh_14 pSt_pAtt_AA_14 pSt_pAtt_Wh_14 pSt_STr_AA_14 pSt_STr_Wh_14 ///
comyrs childcom enrolage drop_age work_age enrolage_6 drop_age_14 work_age_14 pcomyrs pchildcom ///
comyrs_miss childcom_miss childcom_fill comyrs_fill; 
save "State_Qleadcslshort.dta", replace;
save "HxStateQ_080720.dta", replace;
