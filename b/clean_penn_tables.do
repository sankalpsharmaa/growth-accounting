/***************************/
/* CLEAN PENN WORLD TABLES */
/***************************/

* set globals 
global mdata "/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/data"

/* open penn world tables data */
use "$mdata/raw/pwt1001.dta", clear

/* keep only US and UK */
keep if inlist(countrycode, "USA", "GBR") 
keep if inrange(year, 1970, 2019)

/* keep capital stock variable */
keep country year cn

/* replace country names for merge */
replace country = "UK" if country == "United Kingdom"
replace country = "USA" if country == "United States"

preserve
keep if country == "USA"
save "$mdata/penn_us", replace
restore

preserve
keep if country == "UK"
save "$mdata/penn_uk", replace
restore
