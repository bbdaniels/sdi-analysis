/*
Run IRT

Author: Anna Konstantinova
Last edited: August 11th, 2017
*/

*****************************************************************************
/* Open data */
*****************************************************************************

	use "$clean/SDI_AllCountries_Vignettes.dta", clear

*****************************************************************************
/* Adjust variables for "Would do if in ideal world" response to 0 or 1 */
*****************************************************************************

	if "$recodeAfter" == "0" {
		qui foreach v of varlist *history* *exam* {
			replace `v' = 0 if `v'==.a
		}
	}

	if "$recodeAfter" == "1" {
		qui foreach v of varlist *history* *exam* {
			replace `v' = 1 if `v'==.a
		}
	}

*****************************************************************************
/* Remove variables where all responses are 0 */
*****************************************************************************

	qui foreach v of varlist *history* *exam* {
		sum `v'
		local mn = `r(mean)'
		local min = `r(min)'
		local max = `r(max)'
		if `mn'==0 & `min'==0 & `max'==0 {
			drop `v'
		}
	}

*****************************************************************************
/* IRT Algorithm */
*****************************************************************************

	easyirt *history* *exam* using "$intermediate/irt_output_afterto$recodeAfter.dta", id(survey_id) theta(comp) 
	
	clear
