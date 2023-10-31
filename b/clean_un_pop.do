/***********************************/
/* process UN population estimates */
/***********************************/

* set globals 
global mdata "/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/data"

import delimited "$mdata/raw/unpopulation_dataportal_20231028145602.csv", clear
keep if age == "20-64"
keep location time value

ren location country
ren time year
ren value pop_t

replace country = "UK" if country == "United Kingdom"
replace country = "USA" if country == "United States of America"

destring year, replace 

keep if inrange(year, 1970, 2019)

preserve
keep if country == "USA"
save "$mdata/un_pop_us", replace
restore

preserve
keep if country == "UK"
save "$mdata/un_pop_uk", replace
restore
