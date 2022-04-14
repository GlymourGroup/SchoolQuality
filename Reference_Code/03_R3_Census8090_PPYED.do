/*Program pulls in 1980 and 1990 5% census samples (PUMS data) and merges with school quality and CSLs including lead variables*
	Data Citation: 
	Steven Ruggles, Sarah Flood, Ronald Goeken, Josiah Grover, Erin Meyer, Jose Pacas and Matthew Sobek. 
	IPUMS USA: Version 10.0 [dataset]. Minneapolis, MN: IPUMS, 2020. https://doi.org/10.18128/D010.V10.0

*PPYED variables are then created and saved*
*Final sets of models are run on split samples to validate in code appendix section*
*/

clear
use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/ProvidedbyThu/Census1990.dta", clear

*creating dummy variables for race
gen nhwhite=0
replace nhwhite=1 if race==1

gen nhblack=0
replace nhblack=1 if race==2

tab race

*retaining onlyl Whites or Blacks*;
drop if race>2 

*notes: 1990 census: schlyrs n =  6,876,493.
*year=1990 for Census data set*;
drop year

*generate variable to indicate census the data is originating from*;
gen census1990=1 
*n=8,659,107*;
	/*AM n=11,573,757*/

gen census=1990

gen age25=0
replace age25=1 if birthyr<1965

*to match REGARDS cohort with only data 1908-1962*;
drop if birthyr<1908
drop if birthyr>1962
	/*AM n=6,743,118*/

/*label define educd_lbl 000 `"N/A or no schooling"'
label define educd_lbl 001 `"N/A"', add
label define educd_lbl 002 `"No schooling completed"', add
label define educd_lbl 010 `"Nursery school to grade 4"', add
label define educd_lbl 011 `"Nursery school, preschool"', add
label define educd_lbl 012 `"Kindergarten"', add
label define educd_lbl 013 `"Grade 1, 2, 3, or 4"', add
label define educd_lbl 014 `"Grade 1"', add
label define educd_lbl 015 `"Grade 2"', add
label define educd_lbl 016 `"Grade 3"', add
label define educd_lbl 017 `"Grade 4"', add
label define educd_lbl 020 `"Grade 5, 6, 7, or 8"', add
label define educd_lbl 021 `"Grade 5 or 6"', add
label define educd_lbl 022 `"Grade 5"', add
label define educd_lbl 023 `"Grade 6"', add
label define educd_lbl 024 `"Grade 7 or 8"', add
label define educd_lbl 025 `"Grade 7"', add
label define educd_lbl 026 `"Grade 8"', add
label define educd_lbl 030 `"Grade 9"', add
label define educd_lbl 040 `"Grade 10"', add
label define educd_lbl 050 `"Grade 11"', add
label define educd_lbl 060 `"Grade 12"', add
label define educd_lbl 061 `"12th grade, no diploma"', add
label define educd_lbl 062 `"High school graduate or GED"', add
label define educd_lbl 063 `"Regular high school diploma"', add
label define educd_lbl 064 `"GED or alternative credential"', add
label define educd_lbl 065 `"Some college, but less than 1 year"', add
label define educd_lbl 070 `"1 year of college"', add
label define educd_lbl 071 `"1 or more years of college credit, no degree"', add
label define educd_lbl 080 `"2 years of college"', add
label define educd_lbl 081 `"Associate's degree, type not specified"', add
label define educd_lbl 082 `"Associate's degree, occupational program"', add
label define educd_lbl 083 `"Associate's degree, academic program"', add
label define educd_lbl 090 `"3 years of college"', add
label define educd_lbl 100 `"4 years of college"', add
label define educd_lbl 101 `"Bachelor's degree"', add
label define educd_lbl 110 `"5+ years of college"', add
label define educd_lbl 111 `"6 years of college (6+ in 1960-1970)"', add
label define educd_lbl 112 `"7 years of college"', add
label define educd_lbl 113 `"8+ years of college"', add
label define educd_lbl 114 `"Master's degree"', add
label define educd_lbl 115 `"Professional degree beyond a bachelor's degree"', add
label define educd_lbl 116 `"Doctoral degree"', add
label define educd_lbl 999 `"Missing"', add
label values educd educd_lbl
*/

*Note will have to change coding of edu for 1990, for schlyrs=12, perhaps include only 60-62. Also look at higher edu to make decisions*;
*new coding for 1990 edu categories*;

gen schlyrs=.
replace schlyrs=0 if educd==2 | educd==11 | educd==12
replace schlyrs = 2.5 if educd==13
replace schlyrs = 6.5 if educd==20
replace schlyrs=9 if educd==30
replace schlyrs=10 if educd==40
replace schlyrs=11 if educd==50
replace schlyrs=12 if educd==60 | educd==61| educd==62| educd==63| educd==64|educd==65
replace schlyrs=13 if educd==70 | educd==71
replace schlyrs=14 if  educd==80 |educd==81 |educd==82 |educd==83
replace schlyrs=16 if educd==101
replace schlyrs=18 if educd==114 | educd==115
replace schlyrs=20 if educd==116

tab schlyrs educd, mis

*Restricting to US Born Individuals
keep if bpl<57
tab bpl

tab schlyrs 
*n=5,016,566*;
	/*AM: 6, 201,850*/
	
*bpl variable is same as FIPS state codes
generate FIPS=bpl
generate year = birthyr
sort FIPS birthyr

save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/Census1990BWnocontract.dta", replace

use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/Census1990BWnocontract.dta", clear

/*********now pull in 1980 census***********************************/
use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/ProvidedbyThu/1980census.dta", clear

*creating dummy variables for race
gen nhwhite=0
replace nhwhite=1 if race==1

gen nhblack=0
replace nhblack=1 if race==2

*retaining only Whites or Blacks*;
drop if race>2 

tab race

*notes: 1980 census*;

*year=1990 for Census data set*;
drop year

tab educd

/*label define educd_lbl 000 `"N/A or no schooling"'
label define educd_lbl 001 `"N/A"', add
label define educd_lbl 002 `"No schooling completed"', add
label define educd_lbl 010 `"Nursery school to grade 4"', add
label define educd_lbl 011 `"Nursery school, preschool"', add
label define educd_lbl 012 `"Kindergarten"', add
label define educd_lbl 013 `"Grade 1, 2, 3, or 4"', add
label define educd_lbl 014 `"Grade 1"', add
label define educd_lbl 015 `"Grade 2"', add
label define educd_lbl 016 `"Grade 3"', add
label define educd_lbl 017 `"Grade 4"', add
label define educd_lbl 020 `"Grade 5, 6, 7, or 8"', add
label define educd_lbl 021 `"Grade 5 or 6"', add
label define educd_lbl 022 `"Grade 5"', add
label define educd_lbl 023 `"Grade 6"', add
label define educd_lbl 024 `"Grade 7 or 8"', add
label define educd_lbl 025 `"Grade 7"', add
label define educd_lbl 026 `"Grade 8"', add
label define educd_lbl 030 `"Grade 9"', add
label define educd_lbl 040 `"Grade 10"', add
label define educd_lbl 050 `"Grade 11"', add
label define educd_lbl 060 `"Grade 12"', add
label define educd_lbl 061 `"12th grade, no diploma"', add
label define educd_lbl 062 `"High school graduate or GED"', add
label define educd_lbl 063 `"Regular high school diploma"', add
label define educd_lbl 064 `"GED or alternative credential"', add
label define educd_lbl 065 `"Some college, but less than 1 year"', add
label define educd_lbl 070 `"1 year of college"', add
label define educd_lbl 071 `"1 or more years of college credit, no degree"', add
label define educd_lbl 080 `"2 years of college"', add
label define educd_lbl 081 `"Associate's degree, type not specified"', add
label define educd_lbl 082 `"Associate's degree, occupational program"', add
label define educd_lbl 083 `"Associate's degree, academic program"', add
label define educd_lbl 090 `"3 years of college"', add
label define educd_lbl 100 `"4 years of college"', add
label define educd_lbl 101 `"Bachelor's degree"', add
label define educd_lbl 110 `"5+ years of college"', add
label define educd_lbl 111 `"6 years of college (6+ in 1960-1970)"', add
label define educd_lbl 112 `"7 years of college"', add
label define educd_lbl 113 `"8+ years of college"', add
label define educd_lbl 114 `"Master's degree"', add
label define educd_lbl 115 `"Professional degree beyond a bachelor's degree"', add
label define educd_lbl 116 `"Doctoral degree"', add
label define educd_lbl 999 `"Missing"', add
label values educd educd_lbl
*/

*AM changed Thu's code from educd - extend it so includes more than 12 years of schooling;
gen schlyrs=.
replace schlyrs=0 if educd==2 | educd==11 | educd==12
replace schlyrs=1 if educd==14
replace schlyrs=2 if educd==15
replace schlyrs=3 if educd==16
replace schlyrs=4 if educd==17
replace schlyrs=5 if educd==22
replace schlyrs=6 if educd==23
replace schlyrs=7 if educd==25
replace schlyrs=8 if educd==26
replace schlyrs=9 if educd==30
replace schlyrs=10 if educd==40
replace schlyrs=11 if educd==50

replace schlyrs=12 if educd==60 | educd==61| educd==62| educd==63| educd==64|educd==65
replace schlyrs=13 if educd==70
replace schlyrs=14 if educd==80 |educd==81 |educd==82 |educd==83
replace schlyrs=15 if educd==90 
replace schlyrs=16 if educd==100 |educd==101 
replace schlyrs=17 if educd==110  
replace schlyrs=18 if educd==111 
replace schlyrs=19 if educd==112 
replace schlyrs=20 if educd==113 

tab schlyrs educd, mis
tab schlyrs

*to match REGARDS cohort with only data 1908-1962*;
drop if birthyr<1908
drop if birthyr>1952
*07/07/20 MMG and Audrey updating to restrict birth yr range to 1952 rather than 1962 for 1980 census since those born in 1962 would likely not have finished their education;

*Restricting to US Born 
keep if bpl<57
tab bpl

*generate variable to indicate census the data is originating from*
gen census1980=1
*n=6,699,402*;

gen census=1980

*n= 6,698,775 for non-missing schlyrs*;

gen age25=0
replace age25=1 if birthyr<1955

*bpl variable is same as FIPS state codes
generate FIPS=bpl
generate year = birthyr
sort FIPS birthyr

save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/Census1980BWnocontract.dta", replace

*append 1980 + 1990 censuses*;
use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/Census1990BWnocontract.dta", clear

append using "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/Census1980BWnocontract.dta"

save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/Census19801990BWnocontract.dta", replace

sort FIPS year

use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/Census19801990BWnocontract.dta", clear
contract FIPS year sex race schlyrs age25
gen birthyr = year
sort FIPS birthyr

save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/Census19801990BWcontracted.dta", replace

*merge with data set with state quality and CSL measures*;
use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/State_Qleadcslshort.dta", clear
*gen birthyr = year;
sort FIPS year

save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/State_Qleadcslshort.dta", replace
***
use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/State_Qleadcslshort.dta", clear

***************************************************************;
*Merge with state policy data
***************************************************************;
merge 1:m FIPS birthyr using "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/Census19801990BWcontracted.dta"

*Check who didn't get merged - confirm <1908 and >1962
tab FIPS year if _merge==1

*create new variables for model exploration
keep if _merge==3
drop _merge
save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/Census19801990contractedQualCSL.dta", replace

*creating squared terms
generate pSt_TL_AAsq = pSt_TL_AA*pSt_TL_AA
generate pSt_TL_Whsq = pSt_TL_Wh*pSt_TL_Wh
generate pSt_pAtt_AAsq = pSt_pAtt_AA*pSt_pAtt_AA
generate pSt_pAtt_Whsq = pSt_pAtt_Wh*pSt_pAtt_Wh
generate pSt_STr_AAsq = pSt_STr_AA*pSt_STr_AA
generate pSt_STr_Whsq = pSt_STr_Wh*pSt_STr_Wh

*creating cubic splines
mkspline tlaa=pSt_TL_AA,cubic
mkspline tlwh=pSt_TL_Wh,cubic
mkspline pattaa=pSt_pAtt_AA, cubic
mkspline pattwh=pSt_pAtt_Wh, cubic
mkspline straa=pSt_STr_AA, cubic
mkspline strwh=pSt_STr_Wh, cubic
mkspline birthyrsp=birthyr, cubic

*making race*birthyr interactions
generate birthyrsp1race = birthyrsp1*race
generate birthyrsp2race = birthyrsp2*race
generate birthyrsp3race = birthyrsp3*race
generate birthyrsp4race = birthyrsp4*race

*making race*school quality interactions (linear)
generate pSt_TL_AArace = pSt_TL_AA*race
generate pSt_TL_Whrace = pSt_TL_Wh*race
generate pSt_pAtt_AArace = pSt_pAtt_AA*race
generate pSt_pAtt_Whrace = pSt_pAtt_Wh*race
generate pSt_STr_AArace = pSt_STr_AA*race
generate pSt_STr_Whrace = pSt_STr_Wh*race

*making race*school quality interactions (quadratic)
generate pSt_TL_AAsqrace = pSt_TL_AAsq*race
generate pSt_TL_Whsqrace = pSt_TL_Whsq*race
generate pSt_pAtt_AAsqrace = pSt_pAtt_AAsq*race
generate pSt_pAtt_Whsqrace = pSt_pAtt_Whsq*race
generate pSt_STr_AAsqrace = pSt_STr_AAsq*race
generate pSt_STr_Whsqrace = pSt_STr_Whsq*race

*making race*school quality interactions (cubic)
generate tlaa1race = tlaa1*race
generate tlaa2race =  tlaa2*race
generate tlaa3race = tlaa3*race
generate tlaa4race = tlaa4*race
generate tlwh1race = tlwh1*race 
generate tlwh2race =  tlwh2*race
generate tlwh3race = tlwh3*race
generate tlwh4race = tlwh4*race 
generate pattaa1race = pattaa1*race
generate pattaa2race = pattaa2*race 
generate pattaa3race = pattaa3*race
generate pattaa4race = pattaa4*race 
generate pattwh1race = pattwh1*race
generate pattwh2race = pattwh2*race
generate pattwh3race = pattwh3*race
generate pattwh4race = pattwh4*race
generate straa1race = straa1*race
generate straa2race = straa2*race
generate straa3race = straa3*race 
generate straa4race = straa4*race 
generate strwh1race = strwh1*race
generate strwh2race = strwh2*race
generate strwh3race = strwh3*race 
generate strwh4race = strwh4*race

*Creating variables needed for model runs, with differfent leads*;

*6 year lead*
*creating squared terms
generate pSt_TL_AAsq_6 = pSt_TL_AA_6*pSt_TL_AA_6
generate pSt_TL_Whsq_6 = pSt_TL_Wh_6*pSt_TL_Wh_6
generate pSt_pAtt_AAsq_6 = pSt_pAtt_AA_6*pSt_pAtt_AA_6
generate pSt_pAtt_Whsq_6 = pSt_pAtt_Wh_6*pSt_pAtt_Wh_6
generate pSt_STr_AAsq_6 = pSt_STr_AA_6*pSt_STr_AA_6
generate pSt_STr_Whsq_6 = pSt_STr_Wh_6*pSt_STr_Wh_6

*creating cubic splines
mkspline l6tlaa=pSt_TL_AA_6,cubic
mkspline l6tlwh=pSt_TL_Wh_6,cubic
mkspline l6pattaa=pSt_pAtt_AA_6, cubic
mkspline l6pattwh=pSt_pAtt_Wh_6, cubic
mkspline l6straa=pSt_STr_AA_6, cubic
mkspline l6strwh=pSt_STr_Wh_6, cubic

*making race*school quality interactions (linear)
generate pSt_TL_AA_6race = pSt_TL_AA_6*race
generate pSt_TL_Wh_6race = pSt_TL_Wh_6*race
generate pSt_pAtt_AA_6race = pSt_pAtt_AA_6*race
generate pSt_pAtt_Wh_6race = pSt_pAtt_Wh_6*race
generate pSt_STr_AA_6race = pSt_STr_AA_6*race
generate pSt_STr_Wh_6race = pSt_STr_Wh_6*race

*making race*school quality interactions (quadratic)
generate pSt_TL_AAsq_6race = pSt_TL_AAsq_6*race
generate pSt_TL_Whsq_6race = pSt_TL_Whsq_6*race
generate pSt_pAtt_AAsq_6race = pSt_pAtt_AAsq_6*race
generate pSt_pAtt_Whsq_6race = pSt_pAtt_Whsq_6*race
generate pSt_STr_AAsq_6race = pSt_STr_AAsq_6*race
generate pSt_STr_Whsq_6race = pSt_STr_Whsq_6*race

*making race*school quality interactions (cubic)
generate l6tlaa1race = l6tlaa1*race
generate l6tlaa2race =  l6tlaa2*race
generate l6tlaa3race = l6tlaa3*race
generate l6tlaa4race = l6tlaa4*race
generate l6tlwh1race = l6tlwh1*race 
generate l6tlwh2race =  l6tlwh2*race
generate l6tlwh3race = l6tlwh3*race
generate l6tlwh4race = l6tlwh4*race 
generate l6pattaa1race = l6pattaa1*race
generate l6pattaa2race = l6pattaa2*race 
generate l6pattaa3race = l6pattaa3*race
generate l6pattaa4race = l6pattaa4*race 
generate l6pattwh1race = l6pattwh1*race
generate l6pattwh2race = l6pattwh2*race
generate l6pattwh3race = l6pattwh3*race
generate l6pattwh4race = l6pattwh4*race
generate l6straa1race = l6straa1*race
generate l6straa2race = l6straa2*race
generate l6straa3race = l6straa3*race 
generate l6straa4race = l6straa4*race 
generate l6strwh1race = l6strwh1*race
generate l6strwh2race = l6strwh2*race
generate l6strwh3race = l6strwh3*race 
generate l6strwh4race = l6strwh4*race

*10 year lead*
*creating squared terms
generate pSt_TL_AAsq_10 = pSt_TL_AA_14*pSt_TL_AA_10
generate pSt_TL_Whsq_10 = pSt_TL_Wh_14*pSt_TL_Wh_10
generate pSt_pAtt_AAsq_10 = pSt_pAtt_AA_14*pSt_pAtt_AA_10
generate pSt_pAtt_Whsq_10 = pSt_pAtt_Wh_14*pSt_pAtt_Wh_10
generate pSt_STr_AAsq_10 = pSt_STr_AA_14*pSt_STr_AA_10
generate pSt_STr_Whsq_10 = pSt_STr_Wh_14*pSt_STr_Wh_10

*creating cubic splines
mkspline l10tlaa=pSt_TL_AA_10,cubic
mkspline l10tlwh=pSt_TL_Wh_10,cubic
mkspline l10pattaa=pSt_pAtt_AA_10, cubic
mkspline l10pattwh=pSt_pAtt_Wh_10, cubic
mkspline l10straa=pSt_STr_AA_10, cubic
mkspline l10strwh=pSt_STr_Wh_10, cubic

*making race*school quality interactions (linear)
generate pSt_TL_AA_10race = pSt_TL_AA_10*race
generate pSt_TL_Wh_10race = pSt_TL_Wh_10*race
generate pSt_pAtt_AA_10race = pSt_pAtt_AA_10*race
generate pSt_pAtt_Wh_10race = pSt_pAtt_Wh_10*race
generate pSt_STr_AA_10race = pSt_STr_AA_10*race
generate pSt_STr_Wh_10race = pSt_STr_Wh_10*race

*making race*school quality interactions (quadratic)
generate pSt_TL_AAsq_10race = pSt_TL_AAsq_10*race
generate pSt_TL_Whsq_10race = pSt_TL_Whsq_10*race
generate pSt_pAtt_AAsq_10race = pSt_pAtt_AAsq_10*race
generate pSt_pAtt_Whsq_10race = pSt_pAtt_Whsq_10*race
generate pSt_STr_AAsq_10race = pSt_STr_AAsq_10*race
generate pSt_STr_Whsq_10race = pSt_STr_Whsq_10*race

*making race*school quality interactions (cubic)
generate l10tlaa1race = l10tlaa1*race
generate l10tlaa2race =  l10tlaa2*race
generate l10tlaa3race = l10tlaa3*race
generate l10tlaa4race = l10tlaa4*race
generate l10tlwh1race = l10tlwh1*race 
generate l10tlwh2race =  l10tlwh2*race
generate l10tlwh3race = l10tlwh3*race
generate l10tlwh4race = l10tlwh4*race 
generate l10pattaa1race = l10pattaa1*race
generate l10pattaa2race = l10pattaa2*race 
generate l10pattaa3race = l10pattaa3*race
generate l10pattaa4race = l10pattaa4*race 
generate l10pattwh1race = l10pattwh1*race
generate l10pattwh2race = l10pattwh2*race
generate l10pattwh3race = l10pattwh3*race
generate l10pattwh4race = l10pattwh4*race
generate l10straa1race = l10straa1*race
generate l10straa2race = l10straa2*race
generate l10straa3race = l10straa3*race 
generate l10straa4race = l10straa4*race 
generate l10strwh1race = l10strwh1*race
generate l10strwh2race = l10strwh2*race
generate l10strwh3race = l10strwh3*race 
generate l10strwh4race = l10strwh4*race


*14 year lead*
*creating squared terms
generate pSt_TL_AAsq_14 = pSt_TL_AA_14*pSt_TL_AA_14
generate pSt_TL_Whsq_14 = pSt_TL_Wh_14*pSt_TL_Wh_14
generate pSt_pAtt_AAsq_14 = pSt_pAtt_AA_14*pSt_pAtt_AA_14
generate pSt_pAtt_Whsq_14 = pSt_pAtt_Wh_14*pSt_pAtt_Wh_14
generate pSt_STr_AAsq_14 = pSt_STr_AA_14*pSt_STr_AA_14
generate pSt_STr_Whsq_14 = pSt_STr_Wh_14*pSt_STr_Wh_14

*creating cubic splines
mkspline l14tlaa=pSt_TL_AA_14,cubic
mkspline l14tlwh=pSt_TL_Wh_14,cubic
mkspline l14pattaa=pSt_pAtt_AA_14, cubic
mkspline l14pattwh=pSt_pAtt_Wh_14, cubic
mkspline l14straa=pSt_STr_AA_14, cubic
mkspline l14strwh=pSt_STr_Wh_14, cubic

*making race*school quality interactions (linear)
generate pSt_TL_AA_14race = pSt_TL_AA_14*race
generate pSt_TL_Wh_14race = pSt_TL_Wh_14*race
generate pSt_pAtt_AA_14race = pSt_pAtt_AA_14*race
generate pSt_pAtt_Wh_14race = pSt_pAtt_Wh_14*race
generate pSt_STr_AA_14race = pSt_STr_AA_14*race
generate pSt_STr_Wh_14race = pSt_STr_Wh_14*race

*making race*school quality interactions (quadratic)
generate pSt_TL_AAsq_14race = pSt_TL_AAsq_14*race
generate pSt_TL_Whsq_14race = pSt_TL_Whsq_14*race
generate pSt_pAtt_AAsq_14race = pSt_pAtt_AAsq_14*race
generate pSt_pAtt_Whsq_14race = pSt_pAtt_Whsq_14*race
generate pSt_STr_AAsq_14race = pSt_STr_AAsq_14*race
generate pSt_STr_Whsq_14race = pSt_STr_Whsq_14*race

*making race*school quality interactions (cubic)
generate l14tlaa1race = l14tlaa1*race
generate l14tlaa2race =  l14tlaa2*race
generate l14tlaa3race = l14tlaa3*race
generate l14tlaa4race = l14tlaa4*race
generate l14tlwh1race = l14tlwh1*race 
generate l14tlwh2race =  l14tlwh2*race
generate l14tlwh3race = l14tlwh3*race
generate l14tlwh4race = l14tlwh4*race 
generate l14pattaa1race = l14pattaa1*race
generate l14pattaa2race = l14pattaa2*race 
generate l14pattaa3race = l14pattaa3*race
generate l14pattaa4race = l14pattaa4*race 
generate l14pattwh1race = l14pattwh1*race
generate l14pattwh2race = l14pattwh2*race
generate l14pattwh3race = l14pattwh3*race
generate l14pattwh4race = l14pattwh4*race
generate l14straa1race = l14straa1*race
generate l14straa2race = l14straa2*race
generate l14straa3race = l14straa3*race 
generate l14straa4race = l14straa4*race 
generate l14strwh1race = l14strwh1*race
generate l14strwh2race = l14strwh2*race
generate l14strwh3race = l14strwh3*race 
generate l14strwh4race = l14strwh4*race

*Creating variables for CSL models*;

/*Predicted CSLs*/
*creating squared terms
generate pcomyrssq = pcomyrs*pcomyrs
generate pchildcomsq = pchildcom*pchildcom 

*creating cubic splines
mkspline pcom=pcomyrs,cubic
mkspline pchild=pchildcom,cubic

*making race*school quality interactions (linear)
generate pcomyrsrace = pcomyrs*race
generate pchildcomrace = pchildcom*race

*making race*school quality interactions (quadratic)
generate pcomyrssqrace = pcomyrssq*race
generate pchildcomsqrace = pchildcomsq*race

*making race*school quality interactions (cubic)
generate pcom1race = pcom1*race 
generate pcom2race =  pcom2*race
generate pcom3race = pcom3*race
generate pcom4race = pcom4*race
generate pchild1race = pchild1*race 
generate pchild2race =  pchild2*race
generate pchild3race = pchild3*race
generate pchild4race = pchild4*race 

/*Filled CSLs*/
gen miss_comfill=0
replace miss_comfill=1 if comyrs_fill==.
gen miss_childcom_fill=0
replace miss_childcom_fill=1 if childcom_fill==.

replace comyrs_fill=0 if comyrs_fill==.
replace childcom_fill=0 if childcom_fill==.

*creating squared terms
generate comyrs_fillsq = comyrs_fill*comyrs_fill
generate childcom_fillsq = childcom_fill*childcom_fill

*creating cubic splines
mkspline comfil=comyrs_fill,cubic
mkspline childfil=childcom_fill,cubic

*making race*school quality interactions (linear)
generate comyrs_fillrace = comyrs_fill*race
generate childcom_fillrace = childcom_fill*race

*making race*school quality interactions (quadratic)
generate comyrs_fillsqrace = comyrs_fillsq*race
generate childcom_fillsqrace = childcom_fillsq*race

*making race*school quality interactions (cubic)
generate comfil1race = comfil1*race 
generate comfil2race = comfil2*race
generate comfil3race = comfil3*race
generate comfil4race = comfil4*race
generate childfil1race = childfil1*race 
generate childfil2race =  childfil2*race
generate childfil3race = childfil3*race
generate childfil4race = childfil4*race 

*interactions between comyrs and term length
gen pcomyrs_tlaa= pcomyrs*pSt_TL_AA_6
gen pchild_tlaa= pchildcom*pSt_TL_AA_6
gen pcomyrs_tlwh = pcomyrs*pSt_TL_Wh_6
gen pchild_tlwh = pchildcom*pSt_TL_Wh_6

gen comfill_tlaa = comyrs_fill*pSt_TL_AA_6
gen childfill_tlaa = childcom_fill*pSt_TL_AA_6
gen comfill_tlwh = comyrs_fill*pSt_TL_Wh_6
gen childfill_tlwh = childcom_fill*pSt_TL_Wh_6

sort FIPS birthyr
save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/Census19801990contractedQualCSL.dta", replace

/*  Data Pulled from Census Brearu** or US Department of Commerce Data reported in the US Statistical Abstracts 
	https://www.census.gov/library/publications/time-series/statistical_abstracts.html
	*/
use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/Census_Data/ProvidedbyThu/statechar.dta", clear
drop e f g h j 
sort FIPS birthyr 

***************************************************************;
*Merge with existing analytic data set
***************************************************************;
merge 1:m FIPS birthyr using "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/Census19801990contractedQualCSL.dta"

*Check who didn't get merged - confirm <1908 and >1962
tab FIPS year if _merge==1

*create new variables for model exploration
keep if _merge==3
drop _merge

save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/Census19801990contractedQualCSL.dta", replace

****
use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/Census19801990contractedQualCSL.dta", clear

gen nomiss_eduqual=0
replace nomiss_eduqual=1 if (pSt_TL_AA !=. & pSt_TL_Wh !=. & pSt_pAtt_AA != . & pSt_pAtt_Wh != . & pSt_STr_AA != . & pSt_STr_Wh != .)

*log using CensusQual_LinearP_071420
*cubic splines with interaction between race and birthyr without school quality measures
*restricting to people 25+ in the census when they appear (1980 or 1990)
reg schlyrs birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_eduqual==1 & age25==1) [fweight=_freq]

*Models include school policy variables without any leads*;
*trying different models, using cubic splines for birthyr and interaction between birthyr and race*;
*restricting to people 25+ in the census when they appear (1980 or 1990)

*linear predictors
reg schlyrs pSt_TL_AA  pSt_TL_Wh pSt_pAtt_AA pSt_pAtt_Wh pSt_STr_AA pSt_STr_Wh ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrsv1

*linear + quadratic
reg schlyrs pSt_TL_AA pSt_TL_Wh pSt_pAtt_AA pSt_pAtt_Wh pSt_STr_AA pSt_STr_Wh /// 
pSt_TL_AAsq pSt_TL_Whsq pSt_pAtt_AAsq pSt_pAtt_Whsq pSt_STr_AAsq pSt_STr_Whsq  ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrsv2

*cubic splines
reg schlyrs tlaa1 tlaa2 tlaa3 tlaa4 tlwh1 tlwh2 tlwh3 tlwh4 pattaa1 pattaa2 pattaa3 pattaa4 pattwh1 pattwh2 pattwh3 pattwh4 ///
straa1 straa2 straa3 straa4 strwh1 strwh2 strwh3 strwh4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrsv3

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)
reg schlyrs pSt_TL_AA  pSt_TL_Wh pSt_pAtt_AA pSt_pAtt_Wh pSt_STr_AA pSt_STr_Wh ///
pSt_TL_AArace pSt_TL_Whrace pSt_pAtt_AArace pSt_pAtt_Whrace pSt_STr_AArace pSt_STr_Whrace ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrsv4

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)
reg schlyrs pSt_TL_AA  pSt_TL_Wh pSt_pAtt_AA pSt_pAtt_Wh pSt_STr_AA pSt_STr_Wh ///
pSt_TL_AAsq pSt_TL_Whsq pSt_pAtt_AAsq pSt_pAtt_Whsq pSt_STr_AAsq pSt_STr_Whsq ///
pSt_TL_AArace pSt_TL_Whrace pSt_pAtt_AArace pSt_pAtt_Whrace pSt_STr_AArace pSt_STr_Whrace ///
pSt_TL_AAsqrace pSt_TL_Whsqrace pSt_pAtt_AAsqrace pSt_pAtt_Whsqrace pSt_STr_AAsqrace pSt_STr_Whsqrace ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrsv5

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)
reg schlyrs tlaa1 tlaa2 tlaa3 tlaa4 tlwh1 tlwh2 tlwh3 tlwh4 pattaa1 pattaa2 pattaa3 pattaa4 pattwh1 pattwh2 pattwh3 pattwh4 ///
straa1 straa2 straa3 straa4 strwh1 strwh2 strwh3 strwh4 ///
tlaa1race tlaa2race tlaa3race tlaa4race tlwh1race tlwh2race tlwh3race tlwh4race pattaa1race ///
pattaa2race pattaa3race pattaa4race pattwh1race pattwh2race pattwh3race pattwh4race ///
straa1race straa2race straa3race straa4race strwh1race strwh2race strwh3race strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrsv6
*log close

*Using different lead variables for Model 6*;
*log using CensusQual_DiffLeads_071420
* 6 year lead*;
reg schlyrs l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
l6tlaa1race l6tlaa2race l6tlaa3race l6tlaa4race l6tlwh1race l6tlwh2race l6tlwh3race l6tlwh4race l6pattaa1race ///
l6pattaa2race l6pattaa3race l6pattaa4race l6pattwh1race l6pattwh2race l6pattwh3race l6pattwh4race ///
l6straa1race l6straa2race l6straa3race l6straa4race l6strwh1race l6strwh2race l6strwh3race l6strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_l6v6

* 10 year lead*;
reg schlyrs l10tlaa1 l10tlaa2 l10tlaa3 l10tlaa4 l10tlwh1 l10tlwh2 l10tlwh3 l10tlwh4 l10pattaa1 l10pattaa2 l10pattaa3 l10pattaa4 /// 
l10pattwh1 l10pattwh2 l10pattwh3 l10pattwh4 ///
l10straa1 l10straa2 l10straa3 l10straa4 l10strwh1 l10strwh2 l10strwh3 l10strwh4 ///
l10tlaa1race l10tlaa2race l10tlaa3race l10tlaa4race l10tlwh1race l10tlwh2race l10tlwh3race l10tlwh4race l10pattaa1race ///
l10pattaa2race l10pattaa3race l10pattaa4race l10pattwh1race l10pattwh2race l10pattwh3race l10pattwh4race ///
l10straa1race l10straa2race l10straa3race l10straa4race l10strwh1race l10strwh2race l10strwh3race l10strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_l10v6

* 14 year lead*;
reg schlyrs l14tlaa1 l14tlaa2 l14tlaa3 l14tlaa4 l14tlwh1 l14tlwh2 l14tlwh3 l14tlwh4 l14pattaa1 l14pattaa2 l14pattaa3 l14pattaa4 /// 
l14pattwh1 l14pattwh2 l14pattwh3 l14pattwh4 ///
l14straa1 l14straa2 l14straa3 l14straa4 l14strwh1 l14strwh2 l14strwh3 l14strwh4 ///
l14tlaa1race l14tlaa2race l14tlaa3race l14tlaa4race l14tlwh1race l14tlwh2race l14tlwh3race l14tlwh4race l14pattaa1race ///
l14pattaa2race l14pattaa3race l14pattaa4race l14pattwh1race l14pattwh2race l14pattwh3race l14pattwh4race ///
l14straa1race l14straa2race l14straa3race l14straa4race l14strwh1race l14strwh2race l14strwh3race l14strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_l14v6
*log close

*6 year lead Models 1-6 for school quality measures only*;
*log using CensusQual_6YrM1M6_071420
*linear predictors
reg schlyrs pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_l6v1

*linear + quadratic
reg schlyrs pSt_TL_AA_6 pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 /// 
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_l6v2

*cubic splines
reg schlyrs l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_l6v3

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)
reg schlyrs  pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_l6v4

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)
reg schlyrs pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
pSt_TL_AAsq_6race pSt_TL_Whsq_6race pSt_pAtt_AAsq_6race pSt_pAtt_Whsq_6race pSt_STr_AAsq_6race pSt_STr_Whsq_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_l6v5

* 6 year lead*;
reg schlyrs l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
l6tlaa1race l6tlaa2race l6tlaa3race l6tlaa4race l6tlwh1race l6tlwh2race l6tlwh3race l6tlwh4race l6pattaa1race ///
l6pattaa2race l6pattaa3race l6pattaa4race l6pattwh1race l6pattwh2race l6pattwh3race l6pattwh4race ///
l6straa1race l6straa2race l6straa3race l6straa4race l6strwh1race l6strwh2race l6strwh3race l6strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_l6v6
*log close

/******************* w/ Predicted CSLs *******************/
*log using CensusQual_pCSLs_071420
*linear predictors
reg schlyrs pcomyrs pchildcom ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_cslv1

*linear + quadratic
reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq /// 
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_cslv2

*cubic splines
reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_cslv3

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)
reg schlyrs pcomyrs pchildcom ///
pcomyrsrace pchildcomrace ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_cslv4

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)
reg schlyrs pcomyrs pchildcom ///
pcomyrssq pchildcomsq ///
pcomyrsrace pchildcomrace pcomyrssqrace pchildcomsqrace ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_cslv5

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)
reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
pcom1race pcom2race pcom3race pcom4race ///
pchild1race pchild2race pchild3race pchild4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_cslv6

*6 year lead for edu quality + CSLs in same model -- final models*;
*linear predictors
reg schlyrs pcomyrs pchildcom pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6cslv1

*linear + quadratic
reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 /// 
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6cslv2

*cubic splines
reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6cslv3

/*********************************************************************************************************/
/*MODEL SELECTED AS PRIMARY PPYED MODEL FOR ALL ANALYSES*/
*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)
reg schlyrs pcomyrs pchildcom pcomyrsrace pchildcomrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6cslv4   
/*********************************************************************************************************/

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)
reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq pcomyrsrace pchildcomrace pcomyrssqrace pchildcomsqrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
pSt_TL_AAsq_6race pSt_TL_Whsq_6race pSt_pAtt_AAsq_6race pSt_pAtt_Whsq_6race pSt_STr_AAsq_6race pSt_STr_Whsq_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6cslv5

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)
reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
pcom1race pcom2race pcom3race pcom4race ///
pchild1race pchild2race pchild3race pchild4race ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
l6tlaa1race l6tlaa2race l6tlaa3race l6tlaa4race l6tlwh1race l6tlwh2race l6tlwh3race l6tlwh4race l6pattaa1race ///
l6pattaa2race l6pattaa3race l6pattaa4race l6pattwh1race l6pattwh2race l6pattwh3race l6pattwh4race ///
l6straa1race l6straa2race l6straa3race l6straa4race l6strwh1race l6strwh2race l6strwh3race l6strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6cslv6
*log close

/********* w/ Fill CSLs***********/
*Running with missing indicators after evaluating with and without missing indicators
*log using CensusQual_FillCSLs_071420
*linear predictors
reg schlyrs comyrs_fill childcom_fill ///
miss_comfill miss_childcom_fill ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_fillcslv1

*linear + quadratic
reg schlyrs comyrs_fill childcom_fill comyrs_fillsq childcom_fillsq /// 
miss_comfill miss_childcom_fill ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_fillcslv2

*cubic splines
reg schlyrs comfil1 comfil2 comfil3 comfil4 childfil1 childfil2 childfil3 childfil4 ///
miss_comfill miss_childcom_fill ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_fillcslv3

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)
reg schlyrs comyrs_fill childcom_fill ///
miss_comfill miss_childcom_fill ///
comyrs_fillrace childcom_fillrace ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_fillcslv4

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)
reg schlyrs comyrs_fill childcom_fill ///
miss_comfill miss_childcom_fill ///
comyrs_fillsq childcom_fillsq ///
comyrs_fillrace childcom_fillrace comyrs_fillsqrace childcom_fillsqrace ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_fillcslv5

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)
reg schlyrs comfil1 comfil2 comfil3 comfil4 childfil1 childfil2 childfil3 childfil4 ///
miss_comfill miss_childcom_fill ///
comfil1race comfil2race comfil3race comfil4race ///
childfil1race childfil2race childfil3race childfil4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
*predict pschlyrs_fillcslv6

*6 year lead for edu quality + CSLs in same model -- final models*;
*linear predictors
reg schlyrs comyrs_fill childcom_fill pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
miss_comfill miss_childcom_fill ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6fillcslv1

*linear + quadratic
reg schlyrs comyrs_fill childcom_fill comyrs_fillsq childcom_fillsq pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 /// 
miss_comfill miss_childcom_fill ///
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6fillcslv2

*cubic splines
reg schlyrs comfil1 comfil2 comfil3 comfil4 childfil1 childfil2 childfil3 childfil4 ///
miss_comfill miss_childcom_fill ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6fillcslv3

/*********************************************************************************************************/
/*MODEL SELECTED AS SECONDARY PPYED MODEL (w/ fill CSLs)*/
*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)
reg schlyrs comyrs_fill childcom_fill comyrs_fillrace childcom_fillrace ///
miss_comfill miss_childcom_fill ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6fillcslv4   
/*********************************************************************************************************/

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)
reg schlyrs comyrs_fill childcom_fill comyrs_fillsq childcom_fillsq comyrs_fillrace childcom_fillrace comyrs_fillsqrace childcom_fillsqrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
miss_comfill miss_childcom_fill ///
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
pSt_TL_AAsq_6race pSt_TL_Whsq_6race pSt_pAtt_AAsq_6race pSt_pAtt_Whsq_6race pSt_STr_AAsq_6race pSt_STr_Whsq_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6fillcslv5

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)
reg schlyrs comfil1 comfil2 comfil3 comfil4 childfil1 childfil2 childfil3 childfil4 ///
miss_comfill miss_childcom_fill ///
comfil1race comfil2race comfil3race comfil4race ///
childfil1race childfil2race childfil3race childfil4race  ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
l6tlaa1race l6tlaa2race l6tlaa3race l6tlaa4race l6tlwh1race l6tlwh2race l6tlwh3race l6tlwh4race l6pattaa1race ///
l6pattaa2race l6pattaa3race l6pattaa4race l6pattwh1race l6pattwh2race l6pattwh3race l6pattwh4race ///
l6straa1race l6straa2race l6straa3race l6straa4race l6strwh1race l6strwh2race l6strwh3race l6strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]
predict pschlyrs_l6fillcslv6
*log close

/*********Saving Data*************/

/*Full Dataset*/
save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/Census19801990contractedQualCSL_predvals.dta",replace

/*Smaller Dataset for Sharing*/
use "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/Census19801990contractedQualCSL_predvals.dta", clear
do fipsdo
keep FIPS year segpreBrown State stateab region region_st ///
race sex ///
comyrs pcomyrs childcom pchildcom comyrs_fill childcom_fill miss_comfill miss_childcom_fill ///
St_TL_AA St_TL_Wh St_pAtt_AA St_pAtt_Wh St_STr_AA St_STr_Wh ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
nomiss_eduqual pschlyrs_l6cslv4 pschlyrs_l6fillcslv4
save "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/HxQual_PPYED_080720.dta",replace

/************************************************
	Additional Analyses to Evaluate Models
************************************************/

/*splitting sample and doing analyses on split sample*;

generate u1 = runiform()

*model 0*;
*restricting to people 25+ in the census when they appear (1980 or 1990)
reg schlyrs birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_eduqual==1 & age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv0split

reg schlyrs pschlyrs_l6cslv0split if (age25==1 & u1>0.5) [fweight=_freq]

*linear predictors
reg schlyrs pcomyrs pchildcom pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv1split

reg schlyrs pschlyrs_l6cslv1split if (age25==1 & u1>0.5) [fweight=_freq]

*linear + quadratic
reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 /// 
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv2split

reg schlyrs pschlyrs_l6cslv2split if (age25==1 & u1>0.5) [fweight=_freq]

*cubic splines
reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv3split

reg schlyrs pschlyrs_l6cslv3split if (age25==1 & u1>0.5) [fweight=_freq]

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)
reg schlyrs pcomyrs pchildcom pcomyrsrace pchildcomrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv4split

reg schlyrs pschlyrs_l6cslv4split if (age25==1 & u1>0.5) [fweight=_freq]

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)
reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq pcomyrsrace pchildcomrace pcomyrssqrace pchildcomsqrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
pSt_TL_AAsq_6race pSt_TL_Whsq_6race pSt_pAtt_AAsq_6race pSt_pAtt_Whsq_6race pSt_STr_AAsq_6race pSt_STr_Whsq_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv5split

reg schlyrs pschlyrs_l6cslv5split if (age25==1 & u1>0.5) [fweight=_freq]

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)
reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
pcom1race pcom2race pcom3race pcom4race ///
pchild1race pchild2race pchild3race pchild4race ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
l6tlaa1race l6tlaa2race l6tlaa3race l6tlaa4race l6tlwh1race l6tlwh2race l6tlwh3race l6tlwh4race l6pattaa1race ///
l6pattaa2race l6pattaa3race l6pattaa4race l6pattwh1race l6pattwh2race l6pattwh3race l6pattwh4race ///
l6straa1race l6straa2race l6straa3race l6straa4race l6strwh1race l6strwh2race l6strwh3race l6strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv6split

reg schlyrs pschlyrs_l6cslv6split if (age25==1 & u1>0.5) [fweight=_freq]

/*********** w/ Lead CSLs****************/
*miss_comfill miss_childcom_fill ///

*model 0*;
*restricting to people 25+ in the census when they appear (1980 or 1990)
reg schlyrs birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_eduqual==1 & age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv0split

reg schlyrs pschlyrs_l6cslv0split if (age25==1 & u1>0.5) [fweight=_freq]

*linear predictors
reg schlyrs comyrs_fill childcom_fill pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv1split

reg schlyrs pschlyrs_l6cslv1split if (age25==1 & u1>0.5) [fweight=_freq]

*linear + quadratic
reg schlyrs comyrs_fill childcom_fill comyrs_fillsq childcom_fillsq pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 /// 
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv2split

reg schlyrs pschlyrs_l6cslv2split if (age25==1 & u1>0.5) [fweight=_freq]

*cubic splines
reg schlyrs comfil1 comfil2 comfil3 comfil4 childfil1 childfil2 childfil3 childfil4 ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv3split

reg schlyrs pschlyrs_l6cslv3split if (age25==1 & u1>0.5) [fweight=_freq]

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)
reg schlyrs comyrs_fill childcom_fill comyrs_fillrace childcom_fillrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv4split

reg schlyrs pschlyrs_l6cslv4split if (age25==1 & u1>0.5) [fweight=_freq]

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)
reg schlyrs comyrs_fill childcom_fill comyrs_fillsq childcom_fillsq comyrs_fillrace childcom_fillrace comyrs_fillsqrace childcom_fillsqrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
pSt_TL_AAsq_6race pSt_TL_Whsq_6race pSt_pAtt_AAsq_6race pSt_pAtt_Whsq_6race pSt_STr_AAsq_6race pSt_STr_Whsq_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv5split

reg schlyrs pschlyrs_l6cslv5split if (age25==1 & u1>0.5) [fweight=_freq]

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)
reg schlyrs comfil1 comfil2 comfil3 comfil4 childfil1 childfil2 childfil3 childfil4 ///
comfil1race comfil2race comfil3race comfil4race ///
childfil1race childfil2race childfil3race childfil4race  ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
l6tlaa1race l6tlaa2race l6tlaa3race l6tlaa4race l6tlwh1race l6tlwh2race l6tlwh3race l6tlwh4race l6pattaa1race ///
l6pattaa2race l6pattaa3race l6pattaa4race l6pattwh1race l6pattwh2race l6pattwh3race l6pattwh4race ///
l6straa1race l6straa2race l6straa3race l6straa4race l6strwh1race l6strwh2race l6strwh3race l6strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (age25==1 & u1<0.5) [fweight=_freq]

predict pschlyrs_l6cslv6split

reg schlyrs pschlyrs_l6cslv6split if (age25==1 & u1>0.5) [fweight=_freq]


*Sensitivity Analyses*;

*Adding interactions between csls and term length*;

*6 year lead for edu quality + CSLs in same model*;

gen pcomyrstlaa=pcomyrs*pSt_TL_AA_6
gen pcomyrstlwh=pcomyrs*pSt_TL_Wh_6
gen pchildcomtlaa=pcomyrs*pSt_TL_AA_6
gen pchildcomtlwh=pcomyrs*pSt_TL_Wh_6


*linear predictors
reg schlyrs pcomyrs pchildcom pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pcomyrstlaa pcomyrstlwh pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv1b

*linear + quadratic

reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 /// 
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pcomyrstlaa pcomyrstlwh pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv2

*cubic splines

reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pcomyrstlaa pcomyrstlwh pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv3


*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)

reg schlyrs pcomyrs pchildcom pcomyrsrace pchildcomrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pcomyrstlaa pcomyrstlwh pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv4

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)

reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq pcomyrsrace pchildcomrace pcomyrssqrace pchildcomsqrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
pSt_TL_AAsq_6race pSt_TL_Whsq_6race pSt_pAtt_AAsq_6race pSt_pAtt_Whsq_6race pSt_STr_AAsq_6race pSt_STr_Whsq_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pcomyrstlaa pcomyrstlwh pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv5

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)

reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
pcom1race pcom2race pcom3race pcom4race ///
pchild1race pchild2race pchild3race pchild4race ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
l6tlaa1race l6tlaa2race l6tlaa3race l6tlaa4race l6tlwh1race l6tlwh2race l6tlwh3race l6tlwh4race l6pattaa1race ///
l6pattaa2race l6pattaa3race l6pattaa4race l6pattwh1race l6pattwh2race l6pattwh3race l6pattwh4race ///
l6straa1race l6straa2race l6straa3race l6straa4race l6strwh1race l6strwh2race l6strwh3race l6strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pcomyrstlaa pcomyrstlwh pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv6








*pcomyrs*tl is collinear with pchildcom*tl, so Stata model automatically drops it, here trying pchild*tl*


*linear predictors
reg schlyrs pcomyrs pchildcom pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race /// pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv1b



*linear + quadratic

reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 /// 
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv2

*cubic splines

reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv3


*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)

reg schlyrs pcomyrs pchildcom pcomyrsrace pchildcomrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv4

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)

reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq pcomyrsrace pchildcomrace pcomyrssqrace pchildcomsqrace ///
pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
pSt_TL_AAsq_6race pSt_TL_Whsq_6race pSt_pAtt_AAsq_6race pSt_pAtt_Whsq_6race pSt_STr_AAsq_6race pSt_STr_Whsq_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv5

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)

reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
pcom1race pcom2race pcom3race pcom4race ///
pchild1race pchild2race pchild3race pchild4race ///
l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
l6tlaa1race l6tlaa2race l6tlaa3race l6tlaa4race l6tlwh1race l6tlwh2race l6tlwh3race l6tlwh4race l6pattaa1race ///
l6pattaa2race l6pattaa3race l6pattaa4race l6pattwh1race l6pattwh2race l6pattwh3race l6pattwh4race ///
l6straa1race l6straa2race l6straa3race l6straa4race l6strwh1race l6strwh2race l6strwh3race l6strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
pchildcomtlaa pchildcomtlwh ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if age25==1 [fweight=_freq]

*predict pschlyrs_l6cslv6









*Holding N's constant across models with CSLS or school quality separately*;


 gen nomiss_csleduqual=0
 replace nomiss_csleduqual=1 if (pcomyrs !=. & pchildcom !=. & pSt_TL_AA !=. & pSt_TL_Wh !=. & pSt_pAtt_AA != . & pSt_pAtt_Wh != . & pSt_STr_AA != . & pSt_STr_Wh != .)

*6 year lead Models 1-6 for school quality measures only*;


*linear predictors
reg schlyrs pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_l6v1

*linear + quadratic

reg schlyrs pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 /// 
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_l6v2

*cubic splines

reg schlyrs l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_l6v3


*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)

reg schlyrs  pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_l6v4

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)

reg schlyrs pSt_TL_AA_6  pSt_TL_Wh_6 pSt_pAtt_AA_6 pSt_pAtt_Wh_6 pSt_STr_AA_6 pSt_STr_Wh_6 ///
pSt_TL_AAsq_6 pSt_TL_Whsq_6 pSt_pAtt_AAsq_6 pSt_pAtt_Whsq_6 pSt_STr_AAsq_6 pSt_STr_Whsq_6  ///
pSt_TL_AA_6race pSt_TL_Wh_6race pSt_pAtt_AA_6race pSt_pAtt_Wh_6race pSt_STr_AA_6race pSt_STr_Wh_6race ///
pSt_TL_AAsq_6race pSt_TL_Whsq_6race pSt_pAtt_AAsq_6race pSt_pAtt_Whsq_6race pSt_STr_AAsq_6race pSt_STr_Whsq_6race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_l6v5

* 6 year lead*;

reg schlyrs l6tlaa1 l6tlaa2 l6tlaa3 l6tlaa4 l6tlwh1 l6tlwh2 l6tlwh3 l6tlwh4 l6pattaa1 l6pattaa2 l6pattaa3 l6pattaa4 /// 
l6pattwh1 l6pattwh2 l6pattwh3 l6pattwh4 ///
l6straa1 l6straa2 l6straa3 l6straa4 l6strwh1 l6strwh2 l6strwh3 l6strwh4 ///
l6tlaa1race l6tlaa2race l6tlaa3race l6tlaa4race l6tlwh1race l6tlwh2race l6tlwh3race l6tlwh4race l6pattaa1race ///
l6pattaa2race l6pattaa3race l6pattaa4race l6pattwh1race l6pattwh2race l6pattwh3race l6pattwh4race ///
l6straa1race l6straa2race l6straa3race l6straa4race l6strwh1race l6strwh2race l6strwh3race l6strwh4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_l6v6



*CSLs*;


*linear predictors
reg schlyrs pcomyrs pchildcom ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_cslv1

*linear + quadratic
 

reg schlyrs pcomyrs pchildcom pcomyrssq pchildcomsq /// 
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_cslv2

*cubic splines

reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_cslv3


*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear)

reg schlyrs pcomyrs pchildcom ///
pcomyrsrace pchildcomrace ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex  i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_cslv4

*cubic splines with interaction between race and birthyr, interactions with race and school quality (linear + quadratic)

reg schlyrs pcomyrs pchildcom ///
pcomyrssq pchildcomsq ///
pcomyrsrace pchildcomrace pcomyrssqrace pchildcomsqrace ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_cslv5

*cubic splines with interaction between race and birthyr, interactions with race and school quality (cubic)

reg schlyrs pcom1 pcom2 pcom3 pcom4 pchild1 pchild2 pchild3 pchild4 ///
pcom1race pcom2race pcom3race pcom4race ///
pchild1race pchild2race pchild3race pchild4race ///
birthyrsp1 birthyrsp2 birthyrsp3 birthyrsp4 birthyrsp1race birthyrsp2race ///
birthyrsp3race birthyrsp4race i.race i.sex i.FIPS if (nomiss_csleduqual==1 & age25==1) [fweight=_freq]

*predict pschlyrs_cslv6


save "C:\Users\thutx\Dropbox\REGARDS data quality state\Census19801990contractedQualCSL122216.dta", replace
*/
