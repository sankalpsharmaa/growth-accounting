/******************************/
/* Clean and process raw data */
/******************************/

* set globals 
global mdata "/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/data"

**********
* 1. USA *
**********

* Real GDP 

/* import real GDP data */
import excel "$mdata/raw/us/GDPCA.xls", sheet("FRED Graph") cellrange(A11:B105) firstrow clear

/* gen country variable */
gen country = "USA"

/* gen year variable */
gen year = year(observation_date)

/* rename and label Real GDP variable */
rename GDPCA y_t
label var y_t "Real GDP, Billions of Chained 2017 Dollars"

drop observation_date
 
tempfile usa_rgdp
save `usa_rgdp'

* Nominal GDP data 

/* import nominal GDP data */
import excel "$mdata/raw/us/GDPA.xls", sheet("FRED Graph") cellrange(A11:B105) firstrow clear

/* gen country variable */
gen country = "USA"

/* gen year variable */
gen year = year(observation_date)

/* rename and label variable */
rename GDPA nomy_t
label var nomy_t "Nominal GDP, Billions of Dollars"

drop observation_date

tempfile usa_ngdp
save `usa_ngdp'

* Price Deflator

/* import raw price deflator data */
import excel "$mdata/raw/us/A191RD3A086NBEA.xls", sheet("FRED Graph") cellrange(A11:B105) firstrow clear

/* gen country variable */
gen country = "USA"

/* gen year variable */
gen year = year(observation_date)

/* rename and label variable */
rename A191RD3A086NBEA p_t
label var p_t "GDP implicit price deflator, Index 2017=100"

drop observation_date

tempfile usa_pt
save `usa_pt'	

* Hours worked

/* import raw data for hours worked */
import excel "$mdata/raw/us/B4701C0A222NBEA.xls", sheet("FRED Graph") cellrange(A11:B85) firstrow clear

/* gen country variable */
gen country = "USA"

/* gen year variable */
gen year = year(observation_date)

/* rename and label variable */
rename B4701C0A222NBEA h_t
label var h_t "Hours worked by full/part-time employees, Millions of hours"

drop observation_date

tempfile usa_ht
save `usa_ht'	
	
* Investment

/* import investment data */
import excel "$mdata/raw/us/GPDIA.xls", sheet("FRED Graph") cellrange(A11:B105) firstrow clear

/* gen country variable */
gen country = "USA"

/* gen year variable */
gen year = year(observation_date)

/* rename and label investment variable */
rename GPDIA nomi_t
label var nomi_t "Gross Private Domestic Investment, Billions of Dollars"

drop observation_date

/* save temporary file for merging later */
tempfile usa_nomit
save `usa_nomit'

* Nominal capital consumption

/* import raw data on nominal capital consumption */
import excel "$mdata/raw/us/A024RC1A027NBEA.xls", sheet("FRED Graph") cellrange(A11:B105) firstrow clear

/* gen country variable */
gen country = "USA"

/* gen year variable */
gen year = year(observation_date)

/* rename and label variable */
rename A024RC1A027NBEA dk_t
label var dk_t "Consumption of fixed capital: Private, Billions of Dollars"

drop observation_date

tempfile usa_dkt
save `usa_dkt'	

/*******************/
/* Merge variables */
/*******************/

/* open initial temporary data */
use `usa_rgdp', clear

/* now loop over all temporary datasets */
foreach tempf in ngdp pt nomit dkt ht {
	merge 1:1 country year using `usa_`tempf'', nogen
	}
	
/* restrict sample to 1970-2019 */
keep if inrange(year, 1970, 2019)
sort year 

/* gen observation identifier and order variables */
gen id = _n
order id country year y_t nomy_t y_t nomi_t dk_t h_t	
	
/* check how price deflator is constructed */
gen p_t_manual = 100 * (nomy_t / y_t)

/* construct difference between the ratio of nominal/real GDP and price deflator */
gen p_t_diff = round(p_t_manual - p_t, .001)

/* assert that differences should be 0 at 10^-3 */
assert p_t_diff == 0
drop p_t_diff p_t_manual

/* save clean US data */
save "$mdata/us_clean", replace

*********
* 2. UK *
*********

* Nominal and Real GDP

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("A2 AGGREGATES") cellrange(A9:I84) firstrow clear

/* keep nominal and real GDP */
keep Datasetidentifier YBHA ABMI

/* rename and label variables */
ren Datasetidentifier year
ren YBHA nomy_t
ren ABMI y_t
label var y_t "Gross domestic product at current prices"
label var nomy_t "Gross domestic product at market prices: Chained volume measure"

gen country = "UK"

tempfile uk_gdp
save `uk_gdp'	

* Price deflator 

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("A1 AGGREGATES") cellrange(A8:J83) firstrow clear
keep Datasetidentifier YBGB
ren Datasetidentifier year
ren YBGB p_t

tempfile uk_p_t
save `uk_p_t'

* Gross investment at current prices

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("C1 EXPENDITURE") cellrange(A9:J84) firstrow clear

keep Datasetidentifier NPQS

rename Datasetidentifier year
rename NPQS nomi_t
label var nomi_t "Gross capital formation, Millions of Pounds"

tempfile uk_nomit
save `uk_nomit'

* Gross investment (chained volume measures)

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("C2 EXPENDITURE") cellrange(A9:J84) firstrow clear

keep Datasetidentifier NPQT

rename Datasetidentifier year
rename NPQT i_t
label var i_t "Gross capital formation, Millions of Chained 2019 Pounds"

tempfile uk_it
save `uk_it'

/* open initial temporary data */
use `uk_gdp', clear

/* now loop over all temporary datasets */
foreach tempf in p_t nomit it {
	merge 1:1 year using `uk_`tempf'', nogen
	}

gen p_t_manual = 100 * (nomy_t / y_t)

/* construct difference between the ratio of nominal/real GDP and price deflator */
gen p_t_diff = round(p_t_manual - p_t, .1)

/* assert that differences should be 0 at 10^-1 */
assert p_t_diff == 0

/* construct ratio of nominal and real gross capital formation */
gen i_t_manual = nomi_t * 100 / i_t
gen i_t_diff = i_t_manual - p_t_manual

sum i_t_diff

* Note that the differences between the GDP and investment deflator are significant - this is because UK has a separate series for GFCF deflator (https://www.ons.gov.uk/economy/grossdomesticproductgdp/timeseries/ybfu/ukea) which is different from the price deflator. The values in this series correspond to i_t_manual to the first decimal place. So I will use the real value of GFCF as i_t rather than nomi_t / i_t

drop *_t_diff *_t_manual
