/*********************************/
/* Clean and process raw UK data */
/*********************************/

* set globals 
global mdata "/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/data"

************************
* Nominal and Real GDP *
************************

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("A2 AGGREGATES") cellrange(A9:I84) firstrow clear

/* keep nominal and real GDP */
keep Datasetidentifier YBHA ABMI

/* rename and label variables */
ren Datasetidentifier year
ren YBHA nomy_t
ren ABMI y_t
label var y_t "Gross domestic product at market prices: Chained volume measure"
label var nomy_t "Gross domestic product at current prices"

gen country = "UK"

tempfile uk_gdp
save `uk_gdp'	

******************
* Price deflator *
******************

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("A1 AGGREGATES") cellrange(A8:J83) firstrow clear
keep Datasetidentifier YBGB
ren Datasetidentifier year
ren YBGB p_t

tempfile uk_p_t
save `uk_p_t'

**************************************
* Gross investment at current prices *
**************************************

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("C1 EXPENDITURE") cellrange(A9:J84) firstrow clear

keep Datasetidentifier NPQS

rename Datasetidentifier year
rename NPQS nomi_t
label var nomi_t "Gross capital formation, Millions of Pounds"

tempfile uk_nomit
save `uk_nomit'

**********************************************
* Gross investment (chained volume measures) *
**********************************************

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("C2 EXPENDITURE") cellrange(A9:J84) firstrow clear

keep Datasetidentifier NPQT

rename Datasetidentifier year
rename NPQT i_t
label var i_t "Gross capital formation, Millions of Chained 2019 Pounds"

tempfile uk_it
save `uk_it'

**************
* MERGE DATA *
**************

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

save "$mdata/uk_clean", replace/*********************************/
/* Clean and process raw UK data */
/*********************************/

* set globals 
global mdata "/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/data"

************************
* Nominal and Real GDP *
************************

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("A2 AGGREGATES") cellrange(A9:I84) firstrow clear

/* keep nominal and real GDP */
keep Datasetidentifier YBHA ABMI

/* rename and label variables */
ren Datasetidentifier year
ren YBHA nomy_t
ren ABMI y_t
label var y_t "Gross domestic product at market prices: Chained volume measure"
label var nomy_t "Gross domestic product at current prices"

gen country = "UK"

tempfile uk_gdp
save `uk_gdp'	

******************
* Price deflator *
******************

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("A1 AGGREGATES") cellrange(A8:J83) firstrow clear
keep Datasetidentifier YBGB
ren Datasetidentifier year
ren YBGB p_t

tempfile uk_p_t
save `uk_p_t'

**************************************
* Gross investment at current prices *
**************************************

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("C1 EXPENDITURE") cellrange(A9:J84) firstrow clear

keep Datasetidentifier NPQS

rename Datasetidentifier year
rename NPQS nomi_t
label var nomi_t "Gross capital formation, Millions of Pounds"

tempfile uk_nomit
save `uk_nomit'

**********************************************
* Gross investment (chained volume measures) *
**********************************************

/* import raw data */
import excel "$mdata/raw/uk/quarterlynationalaccountsdatatables.xlsx", sheet("C2 EXPENDITURE") cellrange(A9:J84) firstrow clear

keep Datasetidentifier NPQT

rename Datasetidentifier year
rename NPQT i_t
label var i_t "Gross capital formation, Millions of Chained 2019 Pounds"

tempfile uk_it
save `uk_it'

**************
* MERGE DATA *
**************

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

save "$mdata/uk_clean", replace
