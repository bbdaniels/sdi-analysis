///Creates set of standard IRT outputs per 

cap prog drop countryprofile_graphs
prog def countryprofile_graphs

syntax ///
	anything /// specify the name of the country to be analyzed
	, ///
	saving(string) /// specify the full folder path to save the completed materials (ie /users/bbdaniels/desktop/)
	
* Setup

	use "$final/SDI_Vignette_IRT_Analysis_AfterTo$recodeAfter.dta" , clear

	local country `anything'
	local country_nodash = subinstr("`anything'", "-", " ", .)

	local saving "`saving'"
	
qui {

*****************************************************************************
* Initializing 
*****************************************************************************

	//Remove observations from other countries datasets
		duplicates drop
		drop if country != "`country'"

	//Save the analysis file
		tempfile theData
		save `theData', replace

	//Create a directory for outputs and .gph graph files
		cap mkdir "`saving'"
		cap mkdir "`saving'/TheGraphs/"

*****************************************************************************
* Sort out which vignettes are present 
*****************************************************************************

	local diseases = ""
	local alldiseases = ""
	foreach v of varlist skip_* {
		local dis = substr("`v'", 6, .)
		local dislab : var label skip_`dis'
		local dopos = strpos("`dislab'", "do")
		local vigpos = strpos("`dislab'", "vignette")
		local `dis'prop = substr("`dislab'", `dopos'+3, `vigpos'-`dopos'-4)
		local alldiseases = `" "`dis'" `alldiseases' "'

		sum `v'
		if `r(N)' != 0 {
			local diseases = `" "`dis'" `diseases' "'
		}
	}

	local diagnoses = ""
	local diagnoses_var = ""
	local treatments = ""
	local treatments_var = ""
	local referrals = ""
	local referrals_var = ""
	local antibiotics = ""
	local antibiotics_var = ""
	local questions = ""
	local questions_var = ""
	local tests = ""
	local tests_var = ""
	local exams = ""
	local exams_var = ""
	foreach dis in `diseases' {
		capture confirm variable `dis'_correctd	
		if !_rc {
			sum `dis'_correctd
			if `r(N)' != 0 {
				local diagnoses = `" `diagnoses' "`dis'" "'
				local diagnoses_var = "``dis'prop', `diagnoses_var'"
			}
		}

		capture confirm variable `dis'_correctt
		if !_rc {
			sum `dis'_correctt
			if `r(N)' != 0 {
				local treatments = `" `treatments' "`dis'" "'
				local treatments_var = "``dis'prop', `treatments_var'"
			}
		}
		
		capture confirm variable `dis'_refer
		if !_rc {
			sum `dis'_refer
			if `r(N)' != 0 {
				local referrals = `" `referrals' "`dis'" "'
				local referrals_var = "``dis'prop', `referrals_var'"
			}
		}
		
		capture confirm variable `dis'_antibiotic
		if !_rc {
			sum `dis'_antibiotic
			if `r(N)' != 0 {
				local antibiotics = `" `antibiotics' "`dis'" "'
				local antibiotics_var = "``dis'prop', `antibiotics_var'"
			}
		}

		capture confirm variable `dis'_questions_frac
		if !_rc {
			sum `dis'_questions_frac
			if `r(N)' != 0 {
				local questions = `" `questions' "`dis'" "'
				local questions_var = "``dis'prop', `questions_var'"
			}
		}

		capture confirm variable `dis'_tests_num
		if !_rc {
			sum `dis'_tests_num
			if `r(N)' != 0 {
				local tests = `" `tests' "`dis'" "'
				local tests_var = "``dis'prop', `tests_var'"
			}
		}

		capture confirm variable `dis'_exams_frac
		if !_rc {
			sum `dis'_exams_frac
			if `r(N)' != 0 {
				local exams = `" `exams' "`dis'" "'
				local exams_var = "``dis'prop', `exams_var'"
			}
		}
	}
	local diagnoses_var = substr("`diagnoses_var'",1,length("`diagnoses_var'")-2)
	local treatments_var = substr("`treatments_var'",1,length("`treatments_var'")-2)
	local questions_var = substr("`questions_var'",1,length("`questions_var'")-2)
	local exams_var = substr("`exams_var'",1,length("`exams_var'")-2)
	local tests_var = substr("`tests_var'",1,length("`tests_var'")-2)
	local antibiotics_var = substr("`antibiotics_var'",1,length("`antibiotics_var'")-2)
	local referrals_var = substr("`referrals_var'",1,length("`referrals_var'")-2)

*****************************************************************************
* Set graphing and color options
*****************************************************************************

	//Standardized graphing characteristics
		local graph_opts_box      graphregion(color(white)) title(, size(medium) justification(left) color(black) span pos(11)) ytitle(, placement(left) justification(left)) ylabel(, angle(0) nogrid) yscale(range(-5 5) titlegap(2)) bgcolor(white) legend(off) asyvars showyvars horizontal 
		local graph_opts_density  graphregion(color(white)) title(, size(medium) justification(left) color(black) span pos(11))	xtitle(, placement(left) justification(left)) xscale(range(-6 5) titlegap(2)) ylab(,angle(0) nogrid) yscale(off) legend(region(lc(none) fc(none)) cols(1) ring(0) bplacement(nwest)) bgcolor(white)
		local graph_opts_hist     graphregion(color(white)) title(, size(medium) justification(left) color(black) span pos(11)) xsize(7) subtitle(, justification(left) color(black) span pos(11)) xtitle(, placement(left)) bgcolor(white) xscale(range(-5 3) noli titlegap(2)) ylab(,angle(0) nogrid axis(1)) yscale(noli axis(1)) yscale(axis(2) off) legend(region(lc(none) fc(none)))
		local graph_opts_hbar     graphregion(color(white)) title(, size(medium) color(black) placement(left) justification(left) span) bgcolor(white) xtitle(, placement(left)) xscale(noli titlegap(2)) ylabel(, angle(0) nogrid notick) yscale(noli) 
		local graph_opts_bar      graphregion(color(white)) title(, justification(left) color(black) span pos(11)) xsize(7) ylab(,angle(0) nogrid notick) xscale(noli) yscale(noli) bgcolor(white)
		local graph_opts_dot      graphregion(color(white)) title(, size(medium) justification(left) color(black) span pos(11)) ylab(,angle(0) nogrid notick) yscale(noli) bgcolor(white) legend(region(lc(none) fc(none)))
		local graph_opts_lowess   graphregion(color(white)) title(, size(medium) justification(left) color(black) span pos(11)) xtitle(, placement(left) justification(left)) xscale(titlegap(2)) ylab(,angle(0) nogrid) yscale(noli) legend(region(lc(none) fc(none))) bgcolor(white)	

	//Color palettes 
		local color_hist = "gs13"
		local color_box = "black"
		
		local colors = "navy cranberry gold*1.2 purple chocolate orange midgreen midblue emerald lavender"
		local intensities = ".3 .6 0.9 1.2 1.5 1.8 2.1"

		foreach z in "provider_cadre" "provider_mededuc" "facility_level" {
			levelsof `z'
			foreach y in `r(levels)' {
				local maincolor : word 1 of `colors'
				local intensity : word `y' of `intensities'
				local color`z'`y' = "`maincolor'*`intensity'"
				display "`color`z'`y''"
				display "color`z'`y'"
			}
		} 

		foreach z in "ruralurban" "publicprivate" {
			levelsof `z'
			foreach y in `r(levels)' {
				local color`z'`y' : word `y' of `colors'
			}
		}

		local counter = 1
		foreach z in `alldiseases' {
			local color`z' : word `counter' of `colors'
			local ++counter
		}

		local counter = 1
		foreach z in "overall_questions_frac" "overall_exams_frac" "percent_correctd" "percent_correctt" "total_tests" "percent_antibiotict" {
			local color`z' : word `counter' of `colors'
			local ++counter
		}

*****************************************************************************
* Create axes labels based on regression results 
*****************************************************************************
	
	regress percent_correctt comp_mle
	margins, at(comp_mle = (-3(1)3))
		cap mat drop theResults
		mat theResults = r(b)
		mat theResults = theResults'
	forvalues i = 1/7 {
		local treat`i' = round(theResults[`i',1], 1)
		if `treat`i'' > 100 local treat`i' = 100
		if `treat`i'' < 0 local treat`i' = 0
	}

	regress percent_correctd comp_mle
	margins, at(comp_mle = (-3(1)3))
		cap mat drop theResults
		mat theResults = r(b)
		mat theResults = theResults'
	forvalues i = 1/7 {
		local diag`i' = round(theResults[`i',1], 1)
		if `diag`i'' > 100 local diag`i' = 100
		if `diag`i'' < 0 local diag`i' = 0
	}

	regress total_tests comp_mle
	margins, at(comp_mle = (-3(1)3))
		cap mat drop theResults
		mat theResults = r(b)
		mat theResults = theResults'
	forvalues i = 1/7 {
		local test`i' = round(theResults[`i',1], 0.1)
		display "`test`i''"
		local decplace = strpos("`test`i''", ".")
		if `decplace'==2 & `test`i''>=0 local test`i' = substr("`test`i''", 1, 3)
		if `decplace'==3 & `test`i''>=0 local test`i' = substr("`test`i''", 1, 4)
		if `decplace'==0 & `test`i''>=0 local test`i' = "`test`i''.0"
		if `decplace'==1 & `test`i''>=0 local test`i' = substr("`test`i''", 2, 2)
		if `decplace'==1 & `test`i''>=0 local test`i' = "0.`test`i''"
		if `test`i'' < 0 local test`i' = "0.0"	
	}

	regress percent_antibiotict comp_mle
	margins, at(comp_mle = (-3(1)3))
		cap mat drop theResults
		mat theResults = r(b)
		mat theResults = theResults'
	forvalues i = 1/7 {
		local ab`i' = round(theResults[`i',1], 1)
		if `ab`i'' > 100 local ab`i' = 100
		if `ab`i'' < 0 local ab`i' = 0
	}
	
	regress overall_questions_frac comp_mle
	margins, at(comp_mle = (-3(1)3))
		cap mat drop theResults
		mat theResults = r(b)
		mat theResults = theResults'
	forvalues i = 1/7 {
		local qu`i' = round(theResults[`i',1], 1)
		if `qu`i'' > 100 local qu`i' = 100
		if `qu`i'' < 0 local qu`i' = 0
	}

	regress overall_exams_frac comp_mle
	margins, at(comp_mle = (-3(1)3))
		cap mat drop theResults
		mat theResults = r(b)
		mat theResults = theResults'
	forvalues i = 1/7 {
		local exam`i' = round(theResults[`i',1], 1)
		if `exam`i'' > 100 local exam`i' = 100
		if `exam`i'' < 0 local exam`i' = 0
	}

	local outcome_axis " -5 `" "Knowledge Score" " " "Correct Diagnoses" " " "Correct Treatment" " " "Number of Tests" " " "Inapprop. Antibiotics" "' -3 `" "-3" " " "`diag1'%" " " "`treat1'%" " " "`test1'" " " "`ab1'%" "' -2 `" "-2" " " "`diag2'%" " " "`treat2'%" " " "`test2'" " " "`ab2'%" "' -1 `" "-1" " " "`diag3'%" " " "`treat3'%" " " "`test3'" " " "`ab3'%" "' 0 `" "0" " " "`diag4'%" " " "`treat4'%" " " "`test4'" " " "`ab4'%" "' 1 `" "1" " " "`diag5'%" " " "`treat5'%" " " "`test5'" " " "`ab5'%" "' 2 `" "2" " " "`diag6'%" " " "`treat6'%" " " "`test6'" " " "`ab6'%" "' 3 `" "3" " " "`diag7'%" " " "`treat7'%" " " "`test7'" " " "`ab7'%" "' "
	local diag_axis " -5 `" "Knowledge Score" " " "Correct Diagnoses" "' -3 `" "-3" " " "`diag1'%"  "' -2 `" "-2" " " "`diag2'%"  "' -1 `" "-1" " " "`diag3'%"  "' 0 `" "0" " " "`diag4'%"  "' 1 `" "1" " " "`diag5'%" "' 2 `" "2" " " "`diag6'%" "' 3 `" "3" " " "`diag7'%"  "' "
	local treat_axis " -5 `" "Knowledge Score" " " "Correct Treatment" "' -3 `" "-3" " " "`treat1'%"  "' -2 `" "-2" " " "`treat2'%"  "' -1 `" "-1" " " "`treat3'%"  "' 0 `" "0" " " "`treat4'%"  "' 1 `" "1" " " "`treat5'%" "' 2 `" "2" " " "`treat6'%" "' 3 `" "3" " " "`treat7'%"  "' "
	local tests_axis " -5 `" "Knowledge Score" " " "Number of Tests" "' -3 `" "-3" " " "`test1'"  "' -2 `" "-2" " " "`test2'"  "' -1 `" "-1" " " "`test3'"  "' 0 `" "0" " " "`test4'"  "' 1 `" "1" " " "`test5'" "' 2 `" "2" " " "`test6'" "' 3 `" "3" " " "`test7'"  "' "
	local ab_axis " -5 `" "Knowledge Score" " " "Inapprop. Antibiotics" "' -3 `" "-3" " " "`ab1'%"  "' -2 `" "-2" " " "`ab2'%"  "' -1 `" "-1" " " "`ab3'%"  "' 0 `" "0" " " "`ab4'%"  "' 1 `" "1" " " "`ab5'%" "' 2 `" "2" " " "`ab6'%" "' 3 `" "3" " " "`ab7'%"  "' "

	local input_axis " -5 `" "Knowledge Score" " " "Questions Asked" " " "Exams Done" "' -3 `" "-3" " " "`qu1'%" " " "`exam1'%" "' -2 `" "-2" " " "`qu2'%" " " "`exam2'%" "' -1 `" "-1" " " "`qu3'%" " " "`exam3'%"  "' 0 `" "0" " " "`qu4'%" " " "`exam4'%" "' 1 `" "1" " " "`qu5'%" " " "`exam5'%" "' 2 `" "2" " " "`qu6'%" " " "`exam6'%"  "' 3 `" "3" " " "`qu7'%" " " "`exam7'%"  "' "
	local questions_axis " -5 `" "Knowledge Score" " " "Questions Asked" "' -3 `" "-3" " " "`qu1'%"  "' -2 `" "-2" " " "`qu2'%"  "' -1 `" "-1" " " "`qu3'%"  "' 0 `" "0" " " "`qu4'%"  "' 1 `" "1" " " "`qu5'%" "' 2 `" "2" " " "`qu6'%" "' 3 `" "3" " " "`qu7'%"  "' "
	local exams_axis " -5 `" "Knowledge Score" " " "Exams Done" "' -3 `" "-3" " " "`exam1'%"  "' -2 `" "-2" " " "`exam2'%"  "' -1 `" "-1" " " "`exam3'%"  "' 0 `" "0" " " "`exam4'%"  "' 1 `" "1" " " "`exam5'%" "' 2 `" "2" " " "`exam6'%" "' 3 `" "3" " " "`exam7'%"  "' "

*****************************************************************************
* Rural vs. urban 
*****************************************************************************

	use `theData', clear

	local theLabels1 = ""
	local theBoxes = ""
	local theKDensities = ""	
	local theXLines = ""
	local theLabels2 = ""
	local counter = 1
	gen number = .

	levelsof ruralurban

	foreach x in `r(levels)' {
		sum comp_mle if ruralurban == `x'
		replace number = `r(N)' if ruralurban == `x'

		if `r(N)' >= 10 {
			local category : label (ruralurban) `x'
			sum comp_mle if ruralurban == `x'
			local num_a`x' = `r(N)'
			local mean_a`x' = `r(mean)'

			local theNextLabel1 = `" `counter' `"" "`category'" "(n=`num_a`x'')" ""' "'
			local theLabels1 = `" `theLabels1' `theNextLabel1' "'
			
			local theNextBox = "box(`counter', lcolor(`colorruralurban`x'') fcolor(none) lwidth(0.5)) marker(`counter', mcolor(`colorruralurban`x''))"
			local theBoxes = " `theBoxes' `theNextBox' "		

			local theNextKDensity = "(kdensity comp_mle if ruralurban==`x', lcolor(`colorruralurban`x'') lwidth(0.75))"
			local theKDensities = " `theKDensities' `theNextKDensity' "

			local theNextXLine = "xline(`mean_a`x'', lcolor(`colorruralurban`x'') lpattern(dash) lwidth(0.4))"
			local theXLines = " `theXLines' `theNextXLine' "

			local theNextLabel2 = `"`counter' "`category'" "  (n=`num_a`x'')" "'
			local theLabels2 = `" `theNextLabel2' `theLabels2' "'

			local ++counter
		}
	}

	graph box comp_mle if number>=10, ///
		over(ruralurban, descending axis(noli) relabel(`theLabels1'))  ///
		`theBoxes' ///
		yline(0, lcolor(gs10) lpattern(dash) lwidth(0.2)) ///
		ylabel(`outcome_axis', labsize(small)) ///
		title("Providers in `country_nodash'") ytitle(" ") `graph_opts_box' 
		graph export "`saving'/`country'_rural_urban_box.png", width(2000) replace

	twoway `theKDensities' if number>=10, ///
		`theXLines' ///
		legend(order(`theLabels2')) ///
		title("Providers in `country_nodash'") xtitle(" ") ///
		xlabel(`outcome_axis', labsize(small)) ///
		`graph_opts_density'
		graph export "`saving'/`country'_rural_urban_density.png", width(2000) replace

*****************************************************************************
* Public vs. private
*****************************************************************************

	use `theData', clear

	local theLabels1 = ""
	local theBoxes = ""
	local theKDensities = ""	
	local theXLines = ""
	local theLabels2 = ""
	local counter = 1
	gen number = .

	levelsof publicprivate

	foreach x in `r(levels)' {
		sum comp_mle if publicprivate == `x'
		replace number = `r(N)' if publicprivate == `x'

		if `r(N)' >= 10 {
			local category : label (publicprivate) `x'
			sum comp_mle if publicprivate == `x'
			local num_b`x' = `r(N)'
			local mean_b`x' = `r(mean)'

			local theNextLabel1 = `" `counter' `"" "`category'" "(n=`num_b`x'')" ""' "'
			local theLabels1 = `" `theLabels1' `theNextLabel1' "'

			local theNextBox = "box(`counter', lcolor(`colorpublicprivate`x'') fcolor(none) lwidth(0.5)) marker(`counter', mcolor(`colorpublicprivate`x''))"
			local theBoxes = " `theBoxes' `theNextBox' "

			local theNextKDensity = "(kdensity comp_mle if publicprivate==`x', lcolor(`colorpublicprivate`x'') lwidth(0.75))"
			local theKDensities = " `theKDensities' `theNextKDensity' "

			local theNextXLine = "xline(`mean_b`x'', lcolor(`colorpublicprivate`x'') lpattern(dash) lwidth(0.4))"
			local theXLines = " `theXLines' `theNextXLine' "

			local theNextLabel2 = `" `counter' "`category'" "  (n=`num_b`x'')" "'
			local theLabels2 = `" `theNextLabel2' `theLabels2' "'

			local ++counter
		}
	}

	graph box comp_mle if number>=10, ///
		over(publicprivate, descending axis(noli) relabel(`theLabels1'))  ///
		`theBoxes' ///
		yline(0, lcolor(gs10) lpattern(dash) lwidth(0.2)) ///
		ylabel(`outcome_axis', labsize(small)) ///
		title("Providers in `country_nodash'") ytitle(" ") `graph_opts_box' 
		graph export "`saving'/`country'_public_private_box.png", width(2000) replace

	twoway `theKDensities' if number>=10, ///
		`theXLines' ///
		legend(order(`theLabels2')) ///
		title("Providers in `country_nodash'") xtitle(" ") ///
		xlabel(`outcome_axis', labsize(small)) ///
		`graph_opts_density' 
		graph export "`saving'/`country'_public_private_density.png", width(2000) replace

*****************************************************************************
* Different facility levels
*****************************************************************************

	use `theData', clear

	local theLabels1 = ""
	local theBoxes = ""
	local theKDensities = ""	
	local theXLines = ""
	local theLabels2 = ""
	local counter = 1
	gen number = .

	levelsof facility_level

	foreach x in `r(levels)' {
		sum comp_mle if facility_level == `x'
		replace number = `r(N)' if facility_level == `x'

		if `r(N)' >= 10 {
			local category : label (facility_level) `x'
			sum comp_mle if facility_level == `x'
			local num_c`x' = `r(N)'
			local mean_c`x' = `r(mean)'

			local theNextLabel1 = `" `counter' `"" "`category'" "(n=`num_c`x'')" ""' "'
			local theLabels1 = `" `theLabels1' `theNextLabel1' "'

			local theNextBox = "box(`counter', lcolor(`colorfacility_level`x'') fcolor(none) lwidth(0.5)) marker(`counter', mcolor(`colorfacility_level`x''))"
			local theBoxes = " `theBoxes' `theNextBox' "

			local theNextKDensity = "(kdensity comp_mle if facility_level==`x', lcolor(`colorfacility_level`x'') lwidth(0.75))"
			local theKDensities = " `theKDensities' `theNextKDensity' "

			local theNextXLine = "xline(`mean_c`x'', lcolor(`colorfacility_level`x'') lpattern(dash) lwidth(0.4))"
			local theXLines = " `theXLines' `theNextXLine' "

			local theNextLabel2 = `" `counter' "`category'" "  (n=`num_c`x'')" "'
			local theLabels2 = `" `theNextLabel2' `theLabels2' "'

			local ++counter
		}
	}

	graph box comp_mle if number>=10, ///
		over(facility_level, descending axis(noli) relabel(`theLabels1'))  ///
		`theBoxes' ///
		yline(0, lcolor(gs10) lpattern(dash) lwidth(0.2)) ///
		ylabel(`outcome_axis', labsize(small)) ///
		title("Providers in `country_nodash'") ytitle(" ") `graph_opts_box'
		graph export "`saving'/`country'_facility_level_box.png", width(2000) replace

	twoway `theKDensities' if number>=10, ///
		`theXLines' ///
		legend(order(`theLabels2')) ///
		xlabel(`outcome_axis', labsize(small)) ///
		title("Providers in `country_nodash'") xtitle(" ") ///
		`graph_opts_density'
		graph export "`saving'/`country'_facility_level_density.png", width(2000) replace

*****************************************************************************
* Different health facility functions (professions)
*****************************************************************************
	
	use `theData', clear

	local theLabels1 = ""
	local theBoxes = ""
	local theKDensities = ""	
	local theXLines = ""
	local theLabels2 = ""
	local counter = 1
	gen number = .

	levelsof  provider_cadre

	foreach x in `r(levels)' {
		sum comp_mle if provider_cadre == `x'
		replace number = `r(N)' if provider_cadre == `x'

		if `r(N)' >= 10 {
			local category : label (provider_cadre) `x'
			sum comp_mle if provider_cadre == `x'
			local num_d`x' = `r(N)'
			local mean_d`x' = `r(mean)'

			local theNextLabel1 = `" `counter' `"" "`category'" "(n=`num_d`x'')" ""' "'
			local theLabels1 = `" `theLabels1' `theNextLabel1' "'

			local theNextBox = "box(`counter', lcolor(`colorprovider_cadre`x'') fcolor(none) lwidth(0.5)) marker(`counter', mcolor(`colorprovider_cadre`x''))"
			local theBoxes = " `theBoxes' `theNextBox' "

			local theNextKDensity = "(kdensity comp_mle if provider_cadre==`x', lcolor(`colorprovider_cadre`x'') lwidth(0.75))"
			local theKDensities = " `theKDensities' `theNextKDensity' "

			local theNextXLine = "xline(`mean_d`x'', lcolor(`colorprovider_cadre`x'') lpattern(dash) lwidth(0.4))"
			local theXLines = " `theXLines' `theNextXLine' "

			local theNextLabel2 = `" `counter' "`category'" "  (n=`num_d`x'')" "'
			local theLabels2 = `" `theNextLabel2' `theLabels2' "'

			local ++counter
		}
	}

	graph box comp_mle if number>=10, ///
		over(provider_cadre, descending axis(noli) relabel(`theLabels1'))  ///
		`theBoxes' ///
		yline(0, lcolor(gs10) lpattern(dash) lwidth(0.2)) ///
		ylabel(`outcome_axis', labsize(small)) ///
		note("Categories with less than 10 observations were excluded.", placement(right) size(vsmall)) ///
		title("Providers in `country_nodash'") ytitle(" ") `graph_opts_box'
		graph export "`saving'/`country'_provider_cadre_box.png", width(2000) replace

	twoway `theKDensities' if number>=10, ///
		`theXLines' ///
		legend(order(`theLabels2')) /// 
		note("Categories with less than 10 observations were excluded.", placement(right) size(vsmall)) ///
		title("Providers in `country_nodash'") xtitle(" ") ///
		xlabel(`outcome_axis', labsize(small)) ///
		`graph_opts_density'
		graph export "`saving'/`country'_provider_cadre_density.png", width(2000) replace	

*****************************************************************************
* Levels of medical education
*****************************************************************************
	
	use `theData', clear

	sum provider_mededuc
	if `r(N)'>0 {

		local theLabels1 = ""
		local theBoxes = ""
		local theKDensities = ""	
		local theXLines = ""
		local theLabels2 = ""
		local counter = 1
		gen number = .

		levelsof provider_mededuc

		foreach x in `r(levels)' {
			display "`x'"
			sum comp_mle if provider_mededuc == `x'
			replace number = `r(N)' if provider_mededuc == `x'
			tab number

			if `r(N)' >= 10 {
				local category : label (provider_mededuc) `x'
				sum comp_mle if provider_mededuc == `x'
				local num_e`x' = `r(N)'
				local mean_e`x' = `r(mean)'

				local theNextLabel1 = `" `counter' `"" "`category'" "(n=`num_e`x'')" ""' "'
				local theLabels1 = `" `theLabels1' `theNextLabel1' "'

				local theNextBox = "box(`counter', lcolor(`colorprovider_mededuc`x'') fcolor(none) lwidth(0.5)) marker(`counter', mcolor(`colorprovider_mededuc`x''))"
				local theBoxes = " `theBoxes' `theNextBox' "

				local theNextKDensity = "(kdensity comp_mle if provider_mededuc==`x', lcolor(`colorprovider_mededuc`x'') lwidth(0.75))"
				local theKDensities = " `theKDensities' `theNextKDensity' "

				local theNextXLine = "xline(`mean_e`x'', lcolor(`colorprovider_mededuc`x'') lpattern(dash) lwidth(0.4))"
				local theXLines = " `theXLines' `theNextXLine' "

				local theNextLabel2 = `" `counter' "`category'" "  (n=`num_e`x'')" "'
				local theLabels2 = `" `theNextLabel2' `theLabels2' "'

				local ++counter
			}
		}

		graph box comp_mle if number>=10, ///
			over(provider_mededuc, descending axis(noli) relabel(`theLabels1'))  ///
			`theBoxes' ///
			yline(0, lcolor(gs10) lpattern(dash) lwidth(0.2)) ///
			ylabel(`outcome_axis', labsize(small)) ///
			note("Categories with less than 10 observations were excluded.", placement(right) size(vsmall)) ///
			title("Providers in `country_nodash'") ytitle(" ") `graph_opts_box' 
			graph export "`saving'/`country'_provider_educ_box.png", width(2000) replace

		twoway `theKDensities' if number>=10, ///
			`theXLines' ///
			legend(order(`theLabels2')) /// 
			note("Categories with less than 10 observations were excluded.", placement(right) size(vsmall)) ///
			title("Providers in `country_nodash'") xtitle(" ") ///
			xlabel(`outcome_axis', labsize(small)) ///
			`graph_opts_density'
			graph export "`saving'/`country'_provider_educ_density.png", width(2000) replace	

	}

*****************************************************************************
* Knowledge and effort/quality measures
*****************************************************************************
	
	use `theData', clear

	egen med = median(comp_mle)
	egen lqt = pctile(comp_mle), p(25)
	egen uqt = pctile(comp_mle), p(75)
	egen ls = pctile(comp_mle), p(5)
	egen us = pctile(comp_mle), p(95)
	gen height = 1
	
	graph twoway ///
		(histogram comp_mle, yaxis(2) start(-5) width(0.25) color(`color_hist') legend(label(1 "Knowledge Distribution"))) ///
		(lowess overall_questions_frac comp_mle if comp_mle<3, yaxis(1) lcolor(`coloroverall_questions_frac') lwidth(1) legend(label(2 "Possible History Questions Asked"))) ///
		(lowess overall_exams_frac comp_mle if comp_mle<3, yaxis(1) lcolor(`coloroverall_exams_frac') lwidth(1) legend(label(3 "Possible Physical Exams Done"))) ///
		(rbar lqt med height, horizontal barwidth(10) fcolor(none) lcolor(`color_box') lwidth(0.5)) ///
		(rbar uqt med height, horizontal barwidth(10) fcolor(none) lcolor(`color_box') lwidth(0.5)) ///
		(rspike lqt ls height, horizontal lcolor(`color_box') lwidth(0.5)) ///
		(rspike uqt us height, horizontal lcolor(`color_box') lwidth(0.5)) ///
		(rcap us us height, horizontal lcolor(`color_box') lwidth(0.5) msize(large)) ///
		(rcap ls ls height, horizontal lcolor(`color_box') lwidth(0.5) msize(large)) ///
		, ///
		xtitle("", size(small)) ///
		ytitle("", axis(1)) yscale(alt) ///
		ylabel(0 "0" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%", axis(1)) ///
		xlabel(`input_axis', labsize(small)) ///
		note(`" "Possible history questions asked" includes `questions_var' vignettes. "' ///
			`" "Possible physical exams done" includes `exams_var' vignettes. "', size(tiny)) ///
 		legend(order(2 3) size(small) symy(2) symx(4) pos(11) ring(0) cols(1)) ///
 		`graph_opts_hist'
		graph export "`saving'/`country'_knowledge_effort_quality_histogram_inputs.png", replace

	graph twoway ///
		(histogram comp_mle, yaxis(2) start(-5) width(0.25) color(`color_hist') legend(label(1 "Knowledge Distribution"))) ///
		(lowess percent_correctt comp_mle if comp_mle<3, yaxis(1) lcolor(`colorpercent_correctt') lwidth(1) legend(label(2 "Conditions Treated Correctly"))) ///
		(lowess percent_correctd comp_mle if comp_mle<3, yaxis(1) lcolor(`colorpercent_correctd') lwidth(1) legend(label(3 "Conditions Diagnosed Correctly"))) ///
		(lowess total_tests comp_mle if comp_mle<3, yaxis(3) lcolor(`colortotal_tests') lwidth(1) legend(label(5 "Number of Tests"))) ///
		(lowess percent_antibiotict comp_mle if comp_mle<3, yaxis(1) lcolor(`colorpercent_antibiotict') lwidth(1) legend(label(4 "Conditions Given Antibiotics"))) ///
		(rbar lqt med height, yaxis(3) horizontal barwidth(3) fcolor(none) lcolor(`color_box') lwidth(0.5)) ///
		(rbar uqt med height, yaxis(3) horizontal barwidth(3) fcolor(none) lcolor(`color_box') lwidth(0.5)) ///
		(rspike lqt ls height, yaxis(3) horizontal lcolor(`color_box') lwidth(0.5)) ///
		(rspike uqt us height, yaxis(3) horizontal lcolor(`color_box') lwidth(0.5)) ///
		(rcap us us height, yaxis(3) horizontal lcolor(`color_box') lwidth(0.5) msize(large)) ///
		(rcap ls ls height, yaxis(3) horizontal lcolor(`color_box') lwidth(0.5) msize(large)) ///
		, ///
		xtitle("", size(small)) ///
		ytitle("", axis(1)) yscale(range(0 110) axis(1)) yscale(range(0 33) axis(3)) ///
		ylabel(0 "0" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%", axis(1) labsize(small)) ///
		ylabel(0 "0" 5 "5" 10 "10" 15 "15" 20 "20" 25 "25" 30 "30 Tests", axis(3) labsize(small) angle(0)) yscale(alt noli axis(3)) ///
		ytitle("", axis(3)) ///
		xlabel(`outcome_axis', labsize(small)) ///
		note(`" "Correct treatment" includes `treatments_var' vignettes."' ///
			`" "Correct diagnoses" includes `diagnoses_var' vignettes. "' ///
			`" "Number of tests" includes `tests_var' vignettes."' ///
			`" "Prescribed inappropriate antibiotics" includes `antibiotics_var' vignettes."', size(tiny)) ///
 		legend(order(2 3 4 5) size(small) symy(2) symx(4) pos(11) ring(0) cols(1)) ///
 		`graph_opts_hist'
		graph export "`saving'/`country'_knowledge_effort_quality_histogram_outcomes.png", replace

*****************************************************************************
* Vignette indicators by facility/provider characteristics
*****************************************************************************

	use `theData', clear

	local counter1 = 0
	foreach z in "percent_correctd" "percent_correctt" "overall_questions_frac" "overall_exams_frac" "total_tests" "comp_mle" "percent_antibiotict" {
		foreach q in "ruralurban" "publicprivate" "facility_level" "provider_cadre" "provider_mededuc" {
			sum `q'
			if `r(N)' > 0 {
				preserve
					collapse (mean) mean = `z' (sd) sd = `z' ///
						(count) n = `z', by(`q')
					drop if `q'==.
					gen hi = mean + invttail(n-1,0.025) * (sd/sqrt(n)) if n>5
					gen lo = mean - invttail(n-1,0.025) * (sd/sqrt(n)) if n>5
					drop if n<5
					gen filter = "`q'"
					gen variable = "`z'"

					if `counter1' == 0 {
						tempfile theX
						save `theX', replace
					}

					if `counter1' > 0 {
						append using `theX', force
						save `theX', replace
					}
				restore

				local ++counter1
			}
		}
	}

	use `theX', clear

	gen id=.
	local counter = 1
	local theDividers = ""
	levelsof filter
	foreach x in `r(levels)' {
		if `counter' == 1 {
			replace id = `x' if filter == "`x'"
			local prevlevs = 0
		}
		if `counter' >1 {
			replace id = `x' + `prevlevs' if filter == "`x'"
		}
		local theDividers = "`theDividers' `prevlevs'"
		levelsof `x'
		local maxlev = substr("`r(levels)'", -1, 1)
		local prevlevs = `prevlevs' + `maxlev' + 1	
		local ++counter
	}

	sum id
	local max = `r(max)' + 1

	foreach v in "percent_correctd" "percent_correctt" "overall_questions_frac" "overall_exams_frac" "percent_antibiotict" "total_tests" "comp_mle" {
		if "`v'" == "percent_correctd" local tit "Fraction of Conditions Diagnosed Correctly"
		if "`v'" == "percent_correctt" local tit "Fraction of Conditions Treated Correctly"
		if "`v'" == "overall_questions_frac" local tit "Fraction of Possible History Questions Asked"
		if "`v'" == "overall_exams_frac" local tit "Fraction of Possible Physical Exams Done"
		if "`v'" == "percent_antibiotict" local tit "Fraction of Conditions Prescribed Antibiotics"
		if "`v'" == "total_tests" local tit "Number of Tests Done"
		if "`v'" == "comp_mle" local tit "Mean Provider Knowledge Score"

		if "`v'" == "percent_correctd" local nt "Correct diagnoses include `diagnoses_var' vignettes. "
		if "`v'" == "percent_correctt" local nt "Correct treatment include `treatments_var' vignettes."
		if "`v'" == "comp_mle" local nt " "
		if "`v'" == "overall_questions_frac" local nt "History questions include `questions_var' vignettes."
		if "`v'" == "overall_exams_frac" local nt "Physical exams include `exams_var' vignettes."
		if "`v'" == "total_tests" local nt "Tests include `tests_var' vignettes."
		if "`v'" == "percent_antibiotict" local nt "Inappropriate antibiotics includes `antibiotics_var' vignettes."

		if "`v'" != "comp_mle" & "`v'" != "total_tests" local xlab = `" 0 "0" 25 "25%" 50 "50%" 75 "75%"100 "100%" "'
		if "`v'" == "comp_mle" local xlab = `" `input_axis' "'
		if "`v'" == "total_tests" local xlab = "0(5)20"

		if "`v'" == "comp_mle" local xli = "xline(0, lcolor(gs13) lpattern(shortdash) lwidth(0.2))"
		if "`v'" != "comp_mle" local xli = " "

		local theScatters = ""
		local theLines = ""
		local theLabels = ""
		levelsof filter 
		foreach x in `r(levels)' {
			levelsof `x'
			foreach y in `r(levels)' {
				local theNextScatter = `" (scatter id mean if `x'==`y' & variable=="`v'", color(`color`x'`y'')) "'
				local theScatters = `" `theScatters' `theNextScatter' "'
				
				local theNextLine = `" (rspike hi lo id if `x'==`y' & variable=="`v'", horizontal lcolor(`color`x'`y'') lwidth(0.4)) "'
				local theLines = `" `theLines' `theNextLine' "'

				sum id if filter=="`x'" & `x'==`y'
				local theLocation = `r(mean)'
				local labname : label (`x') `y'
				local theNextLabel = `" `theLocation' "`labname'" "'
				local theLabels = `" `theLabels' `theNextLabel' "'
			}
		}

		twoway ///
			`theScatters' ///
			`theLines' ///
			, ///
			`xli' ///
			yline(`theDividers', lcolor(gs14) lpattern(dash) lwidth(0.25)) ///
			xlabel(`xlab', labsize(small)) yscale(range(0 `max')) ///
			ylabel(`theLabels', labsize(small) notick) /// 
			xtitle(" ") ///
			ytitle(" ") ///
			title("`tit'" " ") legend(off) ///
			note("`nt'" "Data is not shown for categories containing less than 5 observations.", placement(right) justification(right) size(vsmall)) ///
			`graph_opts_bar'
			graph export "`saving'/`country'_`v'.png", width(2000) replace
	}

*****************************************************************************
* Vignette indicators by vignette
*****************************************************************************

	use `theData', clear

	sum comp_mle, de
	replace comp_mle = . if comp_mle < `r(p1)'
	replace comp_mle = . if comp_mle > `r(p99)'

	foreach dis in `diseases' {
		local dislab : var label skip_`dis'
		local dopos = strpos("`dislab'", "do")
		local vigpos = strpos("`dislab'", "vignette")
		local `dis'prop = substr("`dislab'", `dopos'+3, `vigpos'-`dopos'-4)
		local `dis'prop = proper("``dis'prop'")
	}

	local theDiagnosesLowess = ""
	local orders = ""
	local counter = 2
	foreach dis in `diagnoses' {		
		local theNextDiagnosisLowess = `" (lowess `dis'_correctd comp_mle, yaxis(1) lcolor(`color`dis'') lwidth(0.75) legend(label(`counter' "``dis'prop'"))) "'
		local theDiagnosesLowess = `" `theDiagnosesLowess' `theNextDiagnosisLowess' "'
		local orders = "`orders' `counter'"
		local ++counter
	}

	tw (histogram comp_mle, yaxis(2) start(-5) width(0.25) color(`color_hist')) ///
		`theDiagnosesLowess' ///
		if comp_mle>-3 , ///
		xtitle("") ///
		title("Fraction of Providers Who Correctly Diagnosed Condition", size(small)) ///
		ylabel(0 "0" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%", axis(1)) ///
		yscale(axis(2) off) ///
		xlabel(`diag_axis', labsize(small)) xscale(range(-6 3) noli) ///
		legend(order(`orders') size(small) symy(2) symx(6) cols(1) pos(11) ring(0)) ///
		note("Top and bottom 1% of providers were excluded.", size(vsmall) placement(right) justification(right)) ///
		`graph_opts_lowess' 
		graph export "`saving'/`country'_diagnosis_byvignette.png", width(2000) replace

	local theAntibioticsLowess = ""
	local orders = ""
	local counter = 2
	foreach dis in `antibiotics' {
		local theNextAntibioticsLowess = `" (lowess `dis'_antibiotic comp_mle, yaxis(1) lcolor(`color`dis'') lwidth(0.75) legend(label(`counter' "``dis'prop'"))) "'
		local theAntibioticsLowess = `" `theAntibioticsLowess' `theNextAntibioticsLowess' "'
		local orders = "`orders' `counter'"
		local ++counter
	}

	tw (histogram comp_mle, yaxis(2) start(-5) width(0.25) color(`color_hist')) ///
		`theAntibioticsLowess' if comp_mle>-3 , ///
		xtitle("") ///
		title("Fraction of Providers Who Prescribed Inappropriate Antibiotics", size(small)) ///
		ylabel(0 "0" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%", axis(1)) ///
		yscale(axis(2) off) ///
		xlabel(`ab_axis', labsize(small)) xscale(range(-6 3) noli) ///
		legend(order(2 3 4) size(small) symy(2) symx(6) cols(1) pos(11) ring(0)) ///
		note("Top and bottom 1% of providers were excluded.", size(vsmall) placement(right) justification(right)) ///
		`graph_opts_lowess' 
		graph export "`saving'/`country'_antibiotics_byvignette.png", width(2000) replace

	local theTreatmentLowess = ""
	local orders = ""
	local counter = 2
	foreach dis in `treatments' {
		local theNextTreatmentLowess = `" (lowess `dis'_correctt comp_mle, yaxis(1) lcolor(`color`dis'') lwidth(0.75) legend(label(`counter' "``dis'prop'"))) "'
		local theTreatmentLowess = `" `theTreatmentLowess' `theNextTreatmentLowess' "'
		local orders = "`orders' `counter'"
		local ++counter
	}	

	tw (histogram comp_mle, yaxis(2) start(-5) width(0.25) color(`color_hist')) ///
		`theTreatmentLowess' if comp_mle>-3 , ///
		xtitle("") ///
		title("Fraction of Providers Who Correctly Treated Condition", size(small)) ///
		ylabel(0 "0" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%") ///
		yscale(axis(2) off) ///
		xlabel(`treat_axis', labsize(small)) xscale(range(-6 3) noli) ///
		legend(order(2 3 4 5 6) size(small) symy(2) symx(6) cols(1) pos(11) ring(0)) ///
		note("Top and bottom 1% of providers were excluded.", size(vsmall) placement(right) justification(right)) ///
		`graph_opts_lowess'
		graph export "`saving'/`country'_treatment_byvignette.png", width(2000) replace

	local theQuestionsLowess = ""
	local orders = ""
	local counter = 2
	foreach dis in `questions' {
		local theNextQuestionsLowess = `" (lowess `dis'_questions_frac comp_mle, yaxis(1) lcolor(`color`dis'') lwidth(0.75) legend(label(`counter' "``dis'prop'"))) "'
		local theQuestionsLowess = `" `theQuestionsLowess' `theNextQuestionsLowess' "'
		local orders = "`orders' `counter'"
		local ++counter
	}	

	tw (histogram comp_mle, yaxis(2) start(-5) width(0.25) color(`color_hist')) ///
		`theQuestionsLowess' if comp_mle>-3 , ///
		xtitle("") ///
		title("Fraction of Possible History Questions Asked", size(small)) ///
		ylabel(0 "0" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%") ///
		yscale(axis(2) off)  ///
		xlabel(`questions_axis', labsize(small)) xscale(range(-6 3) noli) ///
		legend(order(2 3 4 5 6 7) size(small) symy(2) symx(6) cols(1) pos(11) ring(0)) ///
		note("Top and bottom 1% of providers were excluded.", size(vsmall) placement(right) justification(right)) ///
		`graph_opts_lowess' 
		graph export "`saving'/`country'_questions_byvignette.png", width(2000) replace

	local theExamsLowess = ""
	local orders = ""
	local counter = 2
	foreach dis in `exams' {
		local theNextExamsLowess = `" (lowess `dis'_exams_frac comp_mle, yaxis(1) lcolor(`color`dis'') lwidth(0.75) legend(label(`counter' "``dis'prop'"))) "'
		local theExamsLowess = `" `theExamsLowess' `theNextExamsLowess' "'
		local orders = "`orders' `counter'"
		local ++counter
	}	

	tw (histogram comp_mle, yaxis(2) start(-5) width(0.25) color(`color_hist')) ///
		`theExamsLowess' if comp_mle>-3, ///
		xtitle("") ///
		title("Fraction of Possible Physical Exams Done", size(small)) ///
		ylabel(0 "0" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%") ///
		yscale(axis(2) off) ///
		xlabel(`exams_axis', labsize(small)) xscale(range(-6 3) noli) ///
		legend(order(2 3 4 5 6 7 8) size(small) symy(2) symx(6) cols(1) pos(11) ring(0)) ///
		note("Top and bottom 1% of providers were excluded.", size(vsmall) placement(right) justification(right)) ///
		`graph_opts_lowess' 
		graph export "`saving'/`country'_exams_byvignette.png", width(2000) replace

	local theTestsLowess = ""
	local orders = ""
	local counter = 2
	foreach dis in `tests' {
		local theNextTestsLowess = `" (lowess `dis'_tests_num comp_mle, yaxis(1) lcolor(`color`dis'') lwidth(0.75) legend(label(`counter' "``dis'prop'"))) "'
		local theTestsLowess = `" `theTestsLowess' `theNextTestsLowess' "'
		local orders = "`orders' `counter'"
		local ++counter
	}	

	tw (histogram comp_mle, yaxis(2) start(-5) width(0.25) color(`color_hist')) ///
		`theTestsLowess' if comp_mle>-3, ///
		xtitle("") ///
		title("Number of Tests Done", size(small)) ///
		yscale(axis(2) off)  ///
		xlabel(`tests_axis', labsize(small)) xscale(range(-6 3) noli) ///
		legend(order(2 3 4 5 6 7) size(small) symy(2) symx(6) cols(1) pos(11) ring(0)) ///
		note("Top and bottom 1% of providers were excluded.", size(vsmall) placement(right) justification(right)) ///
		`graph_opts_lowess' 
		graph export "`saving'/`country'_tests_byvignette.png", width(2000) replace

}
end
