cap prog drop countryprofile_tables
prog def countryprofile_tables


syntax ///
	anything /// specify the name of the country to be analyzed
	using/ // specify the full folder path to save the completed materials (ie /users/bbdaniels/desktop/)

* Setup

	use "$constructed/SDI_analysis.dta" , clear

	local country `anything'
	
	local saving "`using'"

qui {

	//Load and filter the data file
		duplicates drop
		drop if country != "`country'"
		local place = "`country'"

		tempfile theData
		save `theData' , replace

	//Standardized table characteristics
		global tables "csv unstack nonumbers nomtitles"

*****************************************************************************
*************************Facility Characteristics****************************
*****************************************************************************

	use `theData', clear

	recode facility_rural (1=0) (0=1)
	lab def rurlab 0 "Rural" 1 "Urban"
	lab val facility_rural rurlab

	recode facility_level (3=1) (1=3)
	lab def faclab 1 "Hospital" 2 "Health Center" 3 "Dispensary"
	lab val facility_level faclab

	preserve
		duplicates drop facility_id, force

		local counter = 0
		foreach filter in "facility_rural" "facility_private" "facility_level" {
			if `counter' == 0 local tostart = "replace"
			if `counter' > 0 local tostart = "append"

			count if `filter' == .
			if `r(N)' != 0 local missing_obs = `r(N)'
			if `r(N)' != 0 local note_obs = "`r(N)' survey(s) contained missing values for the given characteristic."
			if `r(N)' == 0 local note_obs = ""

			estpost tab `filter', nototal
			esttab . using "`saving'/`place'CountryProfile", ///
				cell((b pct(fmt(%5.0f) par))) ///
				`tostart' ///
				modelwidth(10 10) ///
				collabels(none) title("Number of Facilities Surveyed") ///
				addnotes("`note_obs'" " ") ///
				$tables

			local ++counter
		}
	restore

*****************************************************************************
*************************Provider Characteristics****************************
*****************************************************************************

	use `theData', clear

	recode facility_rural (1=0) (0=1)
	lab def rurlab 0 "Rural" 1 "Urban"
	lab val facility_rural rurlab

	recode facility_level (3=1) (1=3)
	lab def faclab 1 "Hospital" 2 "Health Center" 3 "Dispensary"
	lab val facility_level faclab

	recode provider_male (1=0) (0=1)
	lab def genlab 0 "Male" 1 "Female"
	lab val provider_male genlab

	sum provider_med_educ
	if `r(N)'==0 drop provider_med_educ 
	capture confirm variable provider_med_educ
	if !_rc {
		local filters = "facility_rural facility_private facility_level provider_male provider_med_educ provider_cadre"
	}
	else {
		local filters = "facility_rural facility_private facility_level provider_male provider_cadre"
	}

	foreach filter in `filters' {
		count if `filter' == .
		if `r(N)' != 0 local missing_obs = `r(N)'
		if `r(N)' != 0 local note_obs = "`r(N)' survey(s) contained missing values for the given characteristic."
		if `r(N)' == 0 local note_obs = ""

		estpost tab `filter', nototal
		esttab . using "`saving'/`place'CountryProfile", ///
			cell((b pct(fmt(%5.0f) par))) ///
			append ///
			modelwidth(10 10) ///
			collabels(none) title("Number of Providers Surveyed") ///
			addnotes("`note_obs'" " ") ///
			$tables

		local ++counter
	}

*****************************************************************************
***************************Response Rates************************************
*****************************************************************************	

	use `theData', clear

	lab def didviglab 0 "Number of Observations" 1 "Did Not Do Vignette"
	forvalues i = 1/7 {
		lab val skipped_v`i' didviglab
	}

	forvalues i = 1/7 {
		count if skipped_v`i' == 1
		if `r(N)' == 0 local note_obs = "All providers completed this vignette"
		if `r(N)' != 0 local note_obs = ""

		if `i' == 1 local dis = "Child Diarrhea"
		if `i' == 2 local dis = "Child Pneumonia"
		if `i' == 3 local dis = "Diabetes (Type II)"
		if `i' == 4 local dis = "Tuberculosis"
		if `i' == 5 local dis = "Malaria"
		if `i' == 6 local dis = "Post-Partum Hemorrhage"
		if `i' == 7 local dis = "Neonatal Asphyxia"

		estpost tab skipped_v`i', nototal
		esttab . using "`saving'/`place'CountryProfile", ///
			cell(b) ///
			append ///
			modelwidth(10 10) varwidth(25) ///
			collabels(none) title("`dis' Vignette") ///
			addnotes("`note_obs'" " ") ///
			$tables
	}
	
*****************************************************************************
***************************Vignettes Statistics******************************
*****************************************************************************	

	use `theData', clear

	drop overall_questions_frac overall_exams_frac

	estpost sum *_questions
	esttab . using "`saving'/`place'CountryProfile", ///
		cell("mean(label(Mean) fmt(%5.2f))") ///
		append ///
		label ///
		modelwidth(10 10) varwidth(25) ///
		collabels(none) title("Mean Questions") ///
		addnotes(" ") ///
		$tables

	estpost sum *_questions_frac
	esttab . using "`saving'/`place'CountryProfile", ///
		cell("mean(label(Mean) fmt(%5.2f))") ///
		append ///
		label ///
		modelwidth(10 10) varwidth(25) ///
		collabels(none) title("Mean Questions") ///
		addnotes(" ") ///
		$tables

	estpost sum *_exams
	esttab . using "`saving'/`place'CountryProfile", ///
		cell("mean(label(Mean) fmt(%5.2f))") ///
		append ///
		label ///
		modelwidth(10 10) varwidth(25) ///
		collabels(none) title("Mean Exams") ///
		addnotes(" ") ///
		$tables

	estpost sum *_exams_frac
	esttab . using "`saving'/`place'CountryProfile", ///
		cell("mean(label(Mean) fmt(%5.2f))") ///
		append ///
		label ///
		modelwidth(10 10) varwidth(25) ///
		collabels(none) title("Mean Exams") ///
		addnotes(" ") ///
		$tables

	lab def diaglab 0 "Correct Diagnosis" 100 "Incorrect Diagnosis"
	lab def treatlab 0 "Correct Treatment" 100 "Incorrect Treatment"
	lab def ablab 0 "Incorrect Antibiotics" 100 "No Incorrect Antibiotics"
	
	foreach disease in "diarrhea" "pneumonia" "diabetes" "tb" "malaria" "pph" "asphyxia" {
		
		local tit = proper("`disease'")

		capture confirm variable `disease'_lcorrect_diag
		if !_rc {
			recode `disease'_lcorrect_diag (100=0) (0=100)
			lab val `disease'_lcorrect_diag diaglab

			estpost tab `disease'_lcorrect_diag, nototal
			esttab . using "`saving'/`place'CountryProfile", ///
				cell(b) ///
				append ///
				modelwidth(10 10) ///
				collabels(none) title("`tit' Diagnosis") ///
				addnotes(" ") ///
				$tables
		}

		capture confirm variable `disease'_rcorrect_treat
		if !_rc {
			recode `disease'_rcorrect_treat (100=0) (0=100)
			lab val `disease'_rcorrect_treat treatlab

			estpost tab `disease'_rcorrect_treat, nototal
			esttab . using "`saving'/`place'CountryProfile", ///
				cell(b) ///
				append ///
				modelwidth(10 10) ///
				collabels(none) title("`tit' Treatment") ///
				addnotes(" ") ///
				$tables
		}

		capture confirm variable `disease'_antibiotic_treat
		if !_rc {
			recode `disease'_antibiotic_treat (100=0) (0=100)
			lab val `disease'_antibiotic_treat ablab

			estpost tab `disease'_antibiotic_treat, nototal
			esttab . using "`saving'/`place'CountryProfile", ///
				cell(b) ///
				append ///
				modelwidth(10 10) ///
				collabels(none) title("`tit' Antibiotics") ///
				addnotes(" ") ///
				$tables
		}
		
	}

	estpost sum *_tests
	esttab . using "`saving'/`place'CountryProfile", ///
		cell("mean(label(Mean) fmt(%5.2f))") ///
		append ///
		label ///
		modelwidth(10 10) varwidth(25) ///
		collabels(none) title("Mean Tests") ///
		addnotes(" ") ///
		$tables

}

end
