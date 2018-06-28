cap prog drop countryprofile_compare_graphs
prog def countryprofile_compare_graphs

syntax ///
	anything /// specify the country that is to be profiled
	, ///
	saving(string) /// specify the full folder path to save the completed materials (ie /users/bbdaniels/desktop/)
	
* Setup

	use "$final/SDI_Vignette_IRT_Analysis_AfterTo$recodeAfter.dta" , clear

	local toprofile "`anything'"

	//Assign profiled country to graph last
		sum countrycode
		local last_code = `r(max)'
		local last_country : label (countrycode) `last_code'
		sum countrycode if country == "`toprofile'"
		local was_code = `r(mean)'
		recode countrycode (`was_code'=`last_code') (`last_code'=`was_code')
		lab def countrycode `last_code' "`toprofile'" `was_code' "`last_country'" , modify

	tempfile theData
	save `theData' , replace

	local saving "`saving'"
		
qui {

*****************************************************************************
* Initializing 
*****************************************************************************

	//Create a directory for .gph graph files
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

		sum `v' if country=="`toprofile'"
		if `r(N)' != 0 {
			local diseases = `" "`dis'" `diseases' "'
		}
	}

	local correctds = ""
	local correctd_var = ""
	local correctts = ""
	local correctt_var = ""
	local referrals = ""
	local referrals_var = ""
	local antibiotics = ""
	local antibiotict_var = ""
	local questions_fracs = ""
	local questions_frac_var = ""
	local tests_nums = ""
	local tests_var = ""
	local exams_fracs = ""
	local exams_frac_var = ""
	foreach dis in `diseases' {
		capture confirm variable `dis'_correctd	
		if !_rc {
			sum `dis'_correctd
			if `r(N)' != 0 {
				local correctd_var = "``dis'prop', `correctd_var'"
			}
			sum `dis'_correctd if country=="`toprofile'"
			if `r(N)' != 0 {
				local correctds = `" `correctds' "`dis'" "'
			}
		}

		capture confirm variable `dis'_correctt
		if !_rc {
			sum `dis'_correctt
			if `r(N)' != 0 {
				local correctt_var = "``dis'prop', `correctt_var'"
			}
			sum `dis'_correctt if country=="`toprofile'"
			if `r(N)' != 0 {
				local correctts = `" `correctts' "`dis'" "'
			}
		}
		
		capture confirm variable `dis'_refer
		if !_rc {
			sum `dis'_refer
			if `r(N)' != 0 {
				local referrals_var = "``dis'prop', `referrals_var'"
			}
			sum `dis'_refer if country=="`toprofile'"
			if `r(N)' != 0 {
				local referrals = `" `referrals' "`dis'" "'
			}
		}
		
		capture confirm variable `dis'_antibiotic
		if !_rc {
			sum `dis'_antibiotic
			if `r(N)' != 0 {
				local antibiotict_var = "``dis'prop', `antibiotict_var'"
			}
			sum `dis'_antibiotic if country=="`toprofile'"
			if `r(N)' != 0 {
				local antibiotics = `" `antibiotics' "`dis'" "'
			}
		}

		capture confirm variable `dis'_questions_frac
		if !_rc {
			sum `dis'_questions_frac
			if `r(N)' != 0 {
				local questions_frac_var = "``dis'prop', `questions_frac_var'"
			}
			sum `dis'_questions_frac if country=="`toprofile'"
			if `r(N)' != 0 {
				local questions_fracs = `" `questions_fracs' "`dis'" "'
			}
		}

		capture confirm variable `dis'_tests_num
		if !_rc {
			sum `dis'_tests_num
			if `r(N)' != 0 {
				local tests_var = "``dis'prop', `tests_var'"
			}
			sum `dis'_tests_num if country=="`toprofile'"
			if `r(N)' != 0 {
				local tests_nums = `" `tests_nums' "`dis'" "'
			}
		}

		capture confirm variable `dis'_exams_frac
		if !_rc {
			sum `dis'_exams_frac
			if `r(N)' != 0 {
				local exams_frac_var = "``dis'prop', `exams_frac_var'"
			}
			sum `dis'_exams_frac if country=="`toprofile'"
			if `r(N)' != 0 {
				local exams_fracs = `" `exams_fracs' "`dis'" "'
			}
		}
	}
	local correctd_var = substr("`correctd_var'",1,length("`correctd_var'")-2)
	local correctt_var = substr("`correctt_var'",1,length("`correctt_var'")-2)
	local questions_frac_var = substr("`questions_frac_var'",1,length("`questions_frac_var'")-2)
	local exams_frac_var = substr("`exams_frac_var'",1,length("`exams_frac_var'")-2)
	local tests_var = substr("`tests_var'",1,length("`tests_var'")-2)
	local antibiotict_var = substr("`antibiotict_var'",1,length("`antibiotict_var'")-2)
	local referrals_var = substr("`referrals_var'",1,length("`referrals_var'")-2)

*****************************************************************************
* Set graphing and color options
*****************************************************************************

	//Standardized graphing characteristics
		global graph_opts_box    title(, size(medium) justification(left) color(black) span pos(11)) graphregion(color(white)) ytitle(, placement(left) justification(left)) ylabel(, angle(0) nogrid) legend(off) yscale(range(-5 5) titlegap(2)) bgcolor(white) asyvars showyvars horizontal
		global graph_opts_bar    title(, size(medium) justification(left) color(black) span pos(11)) graphregion(color(white)) xscale(noli) ylab(,angle(0) nogrid) yscale(noli) legend(region(lc(none) fc(none))) bgcolor(white)
		global graph_opts_lowess title(, size(medium) justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black) span pos(11)) graphregion(color(white)) xtitle(, placement(left)) xlabel(-5 (1) 5)	xscale(range(-5 5) noli titlegap(2)) ylab(,angle(0) nogrid) yscale(noli) legend(region(lc(none) fc(none))) bgcolor(white)
		global graph_opts_by     subtitle(, fcolor(none) lcolor(white) ring(0) pos(12) nobexpand) xtitle(, placement(left)) xlab(-5 (1) 5) xscale(noli titlegap(5)) ylab(0 (20) 100, angle(0) nogrid) yscale(range(-5 110) noli) 
		global graph_opts_pcts   title(, size(medium) justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black) span pos(11)) graphregion(color(white)) xtitle(, placement(left)) xscale(noli titlegap(2)) ylab(, angle(0) nogrid) yscale(noli) legend(region(lc(none) fc(none))) bgcolor(white)
		global graph_opts_barby  subtitle(, fcolor(none) lcolor(white) ring(0) pos(12) nobexpand) ylab(0 (20) 100, angle(0) nogrid) yscale(range(-5 110) noli) legend(region(lc(none) fc(none)) cols(3))
		global graph_opts_dot    title(, size(medium) justification(left) color(black) span pos(11)) graphregion(color(white)) xtitle(, placement(left)) xscale(titlegap(2) noli) ylab(,angle(0) nogrid) yscale(noli) legend(region(lc(none) fc(none))) bgcolor(white) 

	//Color palettes
		display "KEY SUMMARY MEAN"
		sum countrycode if country=="`toprofile'"
		local profilecode = `r(mean)'
		local color`profilecode' = "maroon"

		levelsof countrycode
		foreach x in `r(levels)' {
			if "`x'" != "`profilecode'" {
				local color`x' = "gs11"
			}
		}

	//Line width
		local width`profilecode' = 1
		levelsof countrycode
		foreach x in `r(levels)' {
			if "`x'" != "`profilecode'" {
				local width`x' = 0.5
			}
		}
			
*****************************************************************************
* Save sample size per country
*****************************************************************************

	foreach x in `countries' {
		count if country=="`x'"
		local country = subinstr("`x'", "-", "",.)
		local num_`country' = `r(N)'
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
* Knowledge, effort & quality by percentile - lowess
*****************************************************************************
	
	use `theData' , clear

	levelsof country
	foreach x in `r(levels)' {
		sum comp_mle if country=="`x'", de
		replace comp_mle = . if comp_mle < `r(p1)' & country=="`x'"
		replace comp_mle = . if comp_mle > `r(p99)' & country=="`x'"
	}

	foreach indic in "percent_correctd" "percent_correctt" "comp_mle" "overall_questions_frac" "overall_exams_frac" "total_tests" "percent_antibiotict" {

		if "`indic'" == "percent_correctd" local tit "Fraction of Conditions Diagnosed Correctly"
		if "`indic'" == "percent_correctt" local tit "Fraction of Conditions Treated Correctly"
		if "`indic'" == "comp_mle" local tit "Provider's Knowledge Score"
		if "`indic'" == "overall_questions_frac" local tit "Fraction of Possible History Questions Asked"
		if "`indic'" == "overall_exams_frac" local tit "Fraction of Possible Physical Exams Done"
		if "`indic'" == "total_tests" local tit "Number of Tests Done"
		if "`indic'" == "percent_antibiotict" local tit "Fraction of Conditions Given Inappropriate Antibiotics"

		if "`indic'" == "percent_correctd" local nt "Correct diagnoses include `correctd_var' vignettes. "
		if "`indic'" == "percent_correctt" local nt "Correct treatments include `correctt_var' vignettes."
		if "`indic'" == "comp_mle" local nt "Top and bottom 1% of providers from each country were excluded."
		if "`indic'" == "overall_questions_frac" local nt "History questions include `questions_frac_var' vignettes."
		if "`indic'" == "overall_exams_frac" local nt "Physical exams include `exams_frac_var' vignettes."
		if "`indic'" == "total_tests" local nt "Tests include `tests_var' vignettes."
		if "`indic'" == "percent_antibiotict" local nt "Inappropriate antibiotics include `antibiotict_var' vignettes."

		if "`indic'" == "total_tests" local ylab `" 0 "0" 5 "5" 10 "10" 15 "15" 20 "20" 25 "25" 30 "30 Tests"  "'
		if "`indic'" == "comp_mle" local ylab `" -3 "-3" -2 "-2" -1 "-1" 0 "0" 1 "1" 2 "2" 3 "3" "'
		if "`indic'" != "total_tests" & "`indic'" != "comp_mle" local ylab `" 0 "0%" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%" "'

		local counter = 1
		local theLegend = ""
		local theGraphs = ""
		
		levelsof countrycode
		foreach x in `r(levels)' {
			local place : lab (countrycode) `x'
			local placename = subinstr("`place'", "-", " ", .)
			
			local theNextGraph = `" (lowess `indic' pctile_bycountry if countrycode==`x', bwidth(1.2) lcolor(`color`x'') lwidth(`width`x'')) "'
			local theGraphs = `" `theGraphs' `theNextGraph' "'

			if `counter'==1 {
				local theNextLegend = `" `counter' "All Other Countries" "'
				local theLegend = `" `theNextLegend' `theLegend' "'
			}
			if `x' == `profilecode' {
				local theNextLegend = `" `counter' "`placename'" "'
				local theLegend = `" `theNextLegend' `theLegend' "'
			}

			local ++counter
		}
		
		tw `theGraphs', ///
			legend(order(`theLegend') col(2)) ///
			title("`tit'") ///
			ytitle("") ylabel(`ylab') ///
			xlabel(1 "1st" 25 "25th" 50 "50th" 75 "75th" 99 "99th") ///
			xtitle("Rank of Provider in Country") ///
			note("`nt'", size(tiny)) ///
			$graph_opts_pcts ///
			saving("`saving'/TheGraphs/`indic'_percentile_lowess.gph", replace) 
			graph export "`saving'/`indic'_percentile_lowess.png", width(2000) replace
	}

	local counter = 1
	local theLegend = ""
	local theGraphs = ""
	
	levelsof countrycode
	foreach x in `r(levels)' {
		local place : lab (countrycode) `x'
		local placename = subinstr("`place'", "-", " ", .)
		
		local theNextGraph = `" (lowess pctile_overall pctile_bycountry if countrycode==`x', lcolor(`color`x'') lwidth(`width`x'')) "'	
		local theGraphs = `" `theGraphs' `theNextGraph' "'

		if `counter'==1 {
			local theNextLegend = `" `counter' "All Other Countries" "'
			local theLegend = `" `theNextLegend' `theLegend' "'
		}
		if `x' == `profilecode' {
			local theNextLegend = `" `counter' "`placename'" "'
			local theLegend = `" `theNextLegend' `theLegend' "'
		}		

		local ++counter
	}

	display `" `theGraphs' "'
	display `" `theLegend' "'

	tw `theGraphs', ///
		legend(order(`theLegend') col(2)) ///
		title("Rank of Provider Overall") ///
		ylabel(1 "1st" 25 "25th" 50 "50th" 75 "75th" 99 "99th" ) ///
		xlabel(1 "1st" 25 "25th" 50 "50th" 75 "75th" 99 "99th" ) ///
		ytitle("") ///
		xtitle("Rank of Provider in Country") ///
		$graph_opts_pcts ///
		saving("`saving'/TheGraphs/percentile_percentile_lowess.gph", replace) 
		graph export "`saving'/percentile_percentile_lowess.png", width(2000) replace

*****************************************************************************
* Knowledge - box plot
*****************************************************************************

	use `theData', clear
	
	local counter = 1
	levelsof countrycode
	foreach x in `r(levels)' {
		local place : lab (countrycode) `x'
		local place_nodash = subinstr("`place'", "-", "", .)
		local placename = subinstr("`place'", "-", " ", .)

		local theNextBox = `" box(`counter', fcolor(none) lcolor(`color`x'') lwidth(0.3)) marker(`counter', msize(vsmall) mcolor(`color`x'')) "'
		
		local theBoxes = `" `theBoxes' `theNextBox' "'

		local theNextLabel =  `" `counter' "`placename'" "'
		local theLabels = `"  `theLabels' `theNextLabel' "'

		local ++counter
	}

	graph box comp_mle, ///
		over(countrycode, sort(1) descending axis(noli) relabel(`theLabels') label(labsize(vsmall))) ///
		`theBoxes' ///
		yline(0, lwidth(0.3) lcolor(gs13) lpattern(dash)) ///
		ylabel(`input_axis', labsize(small)) ///
		ytitle(" ") ///
		$graph_opts_box 
		graph export "`saving'/comp_box_bycountry_inputs.png", replace 

	graph box comp_mle, ///
		over(countrycode, sort(1) descending axis(noli) relabel(`theLabels') label(labsize(vsmall))) ///
		`theBoxes' ///
		yline(0, lwidth(0.3) lcolor(gs13) lpattern(dash)) ///
		ylabel(`outcome_axis', labsize(small)) ///
		ytitle(" ") ///
		$graph_opts_box 
		graph export "`saving'/comp_box_bycountry_outcomes.png", replace 

*****************************************************************************
* Vignette indicators - bar graph 
*****************************************************************************

	use `theData', clear

	local counter = 0
	foreach variable in "correctd" "correctt" "questions_frac" "exams_frac" "tests_num" "antibiotic" {

		foreach y in ``variable's' {
			preserve
				collapse (mean) mean = `y'_`variable' (sd) sd=`y'_`variable' (count) n=`y'_`variable', by(countrycode)
				drop if countrycode==.
				gen hi = mean + invttail(n-1,0.025) * (sd/sqrt(n))
				gen lo = mean - invttail(n-1,0.025) * (sd/sqrt(n))
				drop if n==0
				gen variable = "`variable'"
				gen disease = "`y'"

				if `counter' == 0 {
					tempfile theX
					save `theX', replace
				}

				if `counter' >0 {
					append using `theX', force
					save `theX', replace
				}
			restore

			local ++counter
		}
	}

	use `theX', clear
	drop if mean==.
	
	gen id = .
	local counter = 0
	local theLabels = ""
	levelsof countrycode
	local places = "`r(levels)'"
	foreach p in `places' {
		replace id = countrycode + `counter' if countrycode ==`p'

		local place : lab (countrycode) `p'
		local placename = subinstr("`place'", "-", " ", .)
		local labelpos = `p' + `counter'
		local theNextLabel = `" `labelpos' "`placename'" "'
		local theLabels `" `theLabels' `theNextLabel' "'

		local ++counter
	}

	levelsof variable
	local vars = `" `r(levels)' "'
	foreach v in `vars' {

		if "`v'" == "correctd" local tit "Fraction Who Correctly Diagnosed Condition"
		if "`v'" == "correctt" local tit "Fraction Who Correctly Treated Condition"
		if "`v'" == "questions_frac" local tit "Fraction of Possible History Questions Asked"
		if "`v'" == "exams_frac" local tit "Fraction of Possible Physical Exams Done"
		if "`v'" == "tests_num" local tit "Number of Tests Done"
		if "`v'" == "antibiotic" local tit "Fraction Who Prescribed Inappropriate Antibiotics"

		if "`v'" == "tests_num" local xlab " "
		if "`v'" != "tests_num" local xlab `" 0 "0%" 25 "25%" 50 "50%" 75 "75%" 100 "100%" "'

		preserve
			drop if variable!="`v'"
			local theCombine = ""
			levelsof disease
			foreach x in `r(levels)' {
				local disprop = proper("``x'prop'")
				local theGraphs = ""

				foreach y in `places' {
					local place: label countrycode `y'
					local place = subinstr("`place'", "-", "",.)
					local theNextGraph = `" (bar mean id if countrycode==`y' & disease=="`x'", horizontal fcolor("`color`y''") fintensity(inten100) lcolor("`color`y''"%100)) "'
					local theGraphs = `" `theGraphs' `theNextGraph' "' 
				}

				twoway	`theGraphs' ///
						(rspike hi lo id if disease=="`x'", horizontal lcolor(black) lwidth(0.25)), ///
						legend(off) ///
						ylabel(`theLabels',	angle(0) tstyle(major_notick) labsize(vsmall)) ///
						xlabel(`xlab', labsize(vsmall)) ///
						ytitle("") xtitle("") title("`disprop'") ///
						$graph_opts_bar saving("`saving'/TheGraphs/`x'_`v'_bar_crosscompare.gph", replace)

				local theNextCombine = `" "`saving'/TheGraphs/`x'_`v'_bar_crosscompare.gph" "'
				local theCombine = `" `theCombine' `theNextCombine' "'

			}

			graph combine `theCombine', ///
				xcommon ///
				title("`tit'", placement(left) justification(left) color(black) size(medium)) ///
				graphregion(color(white) lcolor(white) lwidth(10))
				graph export "`saving'/`v'_byvignette_crosscompare.png", width(2000) replace

		restore
	}

}

end
