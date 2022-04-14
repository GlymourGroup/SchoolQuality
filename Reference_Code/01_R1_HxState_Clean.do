* This code creates the data set State_Qvars from the original State Admin School Quality CSV files, 
* covering students, teachers, term length, and attendance days average
* in each state and separately for black and white segregated schools when available
* The output data is tall, 1 observation per state per year for years of available data.  
clear
cd "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual/"

*** IMPORT FILES
insheet using State_TL_AA.csv , comma n
do fipsdo
reshape long y, i(FIPS) j(year)
destring y , replace ignore(",")
rename y St_TL_AA
sort FIPS year
save State_TL_AA , replace

clear
insheet using State_TL_Wh.csv , comma n
do fipsdo
reshape long y, i(FIPS) j(year)
rename y St_TL_Wh
sort FIPS year
save State_TL_Wh, replace

clear
insheet using State_TL_All.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
rename y St_TL_All
sort FIPS year
save State_TL_All , replace

clear
insheet using State_Att_AA.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
rename y St_Att_AA
sort FIPS year
save State_Att_AA , replace

clear
insheet using State_Att_Wh.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
rename y St_Att_Wh
sort FIPS year
save State_Att_Wh , replace

clear
insheet using State_Att_All.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
rename y St_Att_All
sort FIPS year
save State_Att_All , replace

clear
insheet using State_Teach_AA.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
destring y , replace ignore(",")
rename y St_Teach_AA
sort FIPS year
save State_Teach_AA, replace

clear
insheet using State_Teach_Wh.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
destring y , replace ignore(",")
rename y St_Teach_Wh
sort FIPS year
save State_Teach_Wh, replace

clear
insheet using State_Teach_All.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
destring y , replace ignore(",")
rename y St_Teach_All
sort FIPS year
save State_Teach_All, replace

clear
insheet using State_Stud_AA.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
destring y , replace ignore(",")
rename y St_Stud_AA
sort FIPS year
save State_Stud_AA, replace

clear
insheet using State_Stud_Wh.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
destring y , replace ignore(",")
rename y St_Stud_Wh
sort FIPS year
save State_Stud_Wh, replace

clear
insheet using State_Stud_All.csv , comma n
do fipsdo 
reshape long y, i(FIPS) j(year)
destring y , replace ignore(",")
rename y St_Stud_All
sort FIPS year
save State_Stud_All, replace

** MERGE FILES
clear
use State_TL_All
merge FIPS year using State_TL_AA 
rename _merge mergeTLAA
sort FIPS year
merge FIPS year using State_TL_Wh
rename _merge mergeTLWh
sort FIPS year

merge FIPS year using State_Att_AA
rename _merge mergeAttAA
sort FIPS year
merge FIPS year using State_Att_Wh
rename _merge mergeAttWh
sort FIPS year
merge FIPS year using State_Att_All
rename _merge mergeAttAll
sort FIPS year

merge FIPS year using State_Teach_AA
rename _merge mergeTeachAA
sort FIPS year
merge FIPS year using State_Teach_Wh
rename _merge mergeTeachWh
sort FIPS year
merge FIPS year using State_Teach_All
rename _merge mergeTeachAll
sort FIPS year

merge FIPS year using State_Stud_AA 
rename _merge mergeStudAA
sort FIPS year
merge FIPS year using State_Stud_Wh
rename _merge mergeStudWh
sort FIPS year
merge FIPS year using State_Stud_All
rename _merge mergeStudAll
sort FIPS year

* Removing blank variables created by the excel sheet outputs
capture drop v6 v40
capture drop v7-v20
capture drop v21
capture drop v22-v31

cd  "/Users/audreymurchland/Box Sync/REGARDS/Admin_Quality/Admin_Measures_Data_Orig/State_Admin_Qual_Created/"

save State_Qvars, replace

