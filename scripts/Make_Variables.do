/*
Make effort, quality, and knowledge variables

Author: Anna Konstantinova
Last edited: August 11th, 2017
*/

*****************************************************************************
/* Open data and combine with IRT */
*****************************************************************************

	use "$clean/SDI_AllCountries_Vignettes.dta", clear
	merge 1:1 survey_id using "$intermediate/irt_output_afterto$recodeAfter.dta"
	assert _merge==3
	drop _merge
	tempfile theData
	save `theData', replace

*****************************************************************************
/* Add facility data */
*****************************************************************************

	foreach country in $theCountries {
		use "$clean/SDI_`country'_Facility.dta", clear
		merge 1:m country facility_id using `theData'
		drop if _merge==1
		drop _merge
		save `theData', replace
	}

*****************************************************************************
/* Add other provider data */
*****************************************************************************

	foreach country in $theCountries {
		use "$clean/SDI_`country'_Absenteeism.dta", clear
		merge 1:1 survey_id using `theData'
		drop if _merge==1
		drop _merge
		save `theData', replace
	}

	//Combine certain provider variables from across modules
		foreach x in "provider_male" "provider_cadre" "provider_age" "provider_educ" "provider_mededuc" {
			replace `x' = `x'1 if `x'==.
			replace `x' = `x'2 if `x'==.
		}
	
*****************************************************************************
/* Adjust variables for "Would do if in ideal world" response to 0 or 1 */
*****************************************************************************

	local vignvars *history* *exam* *test* *diag* *treat* *educate* *action* *stop* *failed* *refer* 

	if "$recodeAfter" == "0" {
		qui foreach v of varlist `vignvars' {
			replace `v' = 0 if `v'==.a
		}
	}

	if "$recodeAfter" == "1" {
		qui foreach v of varlist `vignvars' {
			replace `v' = 1 if `v'==.a
		}
	}

*****************************************************************************
* Adjust coding for certain variables 
*****************************************************************************

	lab def cadrelab2 4 "Doctor" 3 "Clinical Officer" 2 "Nurse" 1 "Other"
	recode provider_cadre (1=4) (2=3) (3=2) (4=1)
	lab val provider_cadre cadrelab2

	lab def faclab2 1 "Health Post" 2 "Health Center" 3 "Hospital"
	recode facility_level (1=3) (3=1)
	lab val facility_level faclab2

	lab def vigyesnolab 100 "Yes", add

*****************************************************************************
* Sort out which vignettes are present 
*****************************************************************************

	local diseases = ""
	foreach v of varlist skip_* {
		local dis = substr("`v'", 6, .)
		sum `v'
		if `r(N)' != 0 {
			local diseases = `" "`dis'" `diseases' "'
		}
	}

*****************************************************************************
/* Correct diagnosis */
*****************************************************************************

	//Code correct diagnoses
		gen diarrhea_correctd = 0
		replace diarrhea_correctd = 1 if diarrhea_diag_acdiar_sevdehydrtn==1
		replace diarrhea_correctd = 1 if diarrhea_diag_diar_sevdehydrtn==1
		replace diarrhea_correctd = 1 if diarrhea_diag_acdiarrhea==1 & diarrhea_diag_sevdehydrtn==1
		replace diarrhea_correctd = 1 if diarrhea_diag_diarrhea==1 & diarrhea_diag_sevdehydrtn==1

		gen pneumonia_correctd = pneumonia_diag_pneumonia
		
		gen diabetes_correctd = diabetes_diag_diabetesii
		
		gen tb_correctd = tb_diag_tuberculosis

		gen malaria_correctd = 0
		replace malaria_correctd = 1 if malaria_diag_malaria_anemia==1
		replace malaria_correctd = 1 if malaria_diag_malaria==1 & malaria_diag_anemia==1

		gen pph_correctd = pph_diag_pph
		
		gen asphyxia_correctd = asphyxia_diag_neo_asphyxia

		gen pregnant_correctd = 0
		replace pregnant_correctd = 1 if pregnant_diag_anemia==1 & pregnant_diag_pregnant==1

		gen eclampsia_correctd = eclampsia_diag_eclampsia1
		
		gen pid_correctd = pid_diag_pid

	//Adjust variable to account for skipped vignettes
		foreach x in `diseases' {
			capture confirm variable `x'_correctd
			if !_rc {
				replace `x'_correctd = . if skip_`x'==1 | skip_`x'==.
				lab var `x'_correctd "Correctly diagnosed `x'"
			}	
		}

	//Adjust variable to go from 0 to 100
		foreach z of varlist *_correctd {
			replace `z' = `z' * 100
			lab val `z' vigyesnolab
		}

	egen num_answered = rownonmiss(*_correctd)
	lab var num_answered "Number of vignettes that were done"

	egen num_correctd = rowtotal(*_correctd)
	replace num_correctd = num_correctd/100
	gen percent_correctd = num_correctd/num_answered * 100
	lab var num_correctd "Number of conditions diagnosed correctly"
	lab var percent_correctd "Fraction of conditions diagnosed correctly"

*****************************************************************************
/* Correct treatment */
*****************************************************************************

	//Code correct treatments
		egen diarrhea_correctt = anymatch(diarrhea_treat_ivfluids diarrhea_treat_ngtube), val(1)
		replace diarrhea_correctt = 1 if diarrhea_refer_facility==1 & facility_level==1 //allow referral in health post
 
		egen pneumonia_correctt = anymatch(pneumonia_treat_amoxy_dose pneumonia_treat_amoxycillin pneumonia_treat_xpen pneumonia_treat_cotrimox), val(1)
		
		egen diabetes_correctt = anymatch(diabetes_treat_hypoglycmcs diabetes_refer_specialist), val(1)
		
		egen tb_correctt = anymatch(tb_treat_ctdurdose tb_treat_ctdose tb_treat_ctdrugs tb_treat_ctdur tb_refer_tbclinic), val(1)
		replace tb_correctt = 1 if country=="Senegal-2010" & (tb_test_chest_xray==1 | tb_test_sputum==1)

		egen malaria_correctt = anymatch(malaria_treat_al_wdose malaria_treat_al_dose malaria_treat_artemisinin malaria_treat_al malaria_treat_artesunateam), val(1)
		replace malaria_correctt = 0 if malaria_treat_iron_folicacid==0

		egen pid_correctt = anymatch(pid_treat_amoxycillin pid_treat_ciprofloxacin pid_treat_cotrimoxazole pid_treat_metronidazole), val(1)

		gen pph_correctt = 1 if pph_treat_iv==1 & pph_treat_massage==1 & ///
			(pph_treat_oxytocin_wdose==1 | pph_treat_oxytocin_dose20==1 | pph_treat_oxytocin_iv==1 | pph_treat_oxytocin==1 | pph_treat_oxytocin_dose10==1 | pph_treat_oxytocin_rateliter==1 | ///
			pph_treat_ergometrine==1 | pph_treat_ergometrine_dose5==1 |  pph_treat_ergometrine_dose2==1 | pph_treat_oxytocine_doseim==1 | pph_treat_prostaglandins==1 | pph_treat_misoprostol==1)
			//must have IV line and uterine massage, plus some type of drug (either uterotonic or prostaglandin)
		replace pph_correctt = 1 if pph_refer_facility==1 & facility_level==1 //allow for referral in health post
		replace pph_correctt = 0 if pph_correctt==.

		egen asphyxia_action_warmdry = anymatch(asphyxia_action_babywarm asphyxia_action_drybaby), val(1)
		replace asphyxia_action_warmdry = . if skip_asphyxia==1 | skip_asphyxia==.
		egen asphyxia_action_clearair = anymatch(asphyxia_action_airway asphyxia_action_sucker), val(1)
		replace asphyxia_action_clearair = . if skip_asphyxia==1 | skip_asphyxia==.
		egen asphyxia_action_ventilate = anymatch(asphyxia_action_resus asphyxia_action_resusmask asphyxia_action_maskuse), val(1)
		replace asphyxia_action_ventilate = . if skip_asphyxia==1 | skip_asphyxia==.

		gen asphyxia_correctt = 1 if asphyxia_action_warmdry==1 & asphyxia_action_clearair==1 & asphyxia_action_ventilate==1
		replace asphyxia_correctt = 0 if asphyxia_correctt==.

	//Adjust variable to account for skipped vignettes
		foreach x in `diseases' {
			capture confirm variable `x'_correctt
			if !_rc {
				replace `x'_correctt = . if skip_`x'==1 | skip_`x'==.
				lab var `x'_correctt "Correctly treated `x'"
			}
		}

	//Adjust variable to go from 0 to 100
		foreach z of varlist *_correctt {
			replace `z' = `z' * 100
			lab val `z' vigyesnolab
		}

	egen num_treated = rownonmiss(*_correctt)
	lab var num_treated "Number of vignettes that had treatment coded"

	egen num_correctt = rowtotal(*_correctt)
	replace num_correctt = num_correctt/100
	gen percent_correctt = num_correctt/num_treated * 100
	lab var num_correctt "Number of conditions treated correctly"
	lab var percent_correctt "Fraction of conditions treated correctly"

*****************************************************************************
/* Incorrect antibiotics */
*****************************************************************************

	//Code incorrect antibiotics
		gen diarrhea_antibiotic = diarrhea_treat_antibiotics
		egen tb_antibiotic = anymatch(tb_treat_amoxicillin tb_treat_xpen tb_treat_macrolide), val(1)
		gen pneumonia_antibiotic = pneumonia_treat_other_antibiotic
		gen pid_antibiotic = pid_treat_erythromycin

	//Adjust variable to account for skipped vignettes
		foreach z of varlist diarrhea_antibiotic tb_antibiotic pneumonia_antibiotic pid_antibiotic {
			local condition = subinstr("`z'", "_antibiotic", "", 1)
			replace `z' = . if skip_`condition'==1 | skip_`condition'==.
		}
	
	//Adjust variable to go from 0 to 100	
		foreach z of varlist diarrhea_antibiotic tb_antibiotic pneumonia_antibiotic pid_antibiotic {
			replace `z' = `z' * 100
			lab val `z' vigyesnolab
		}	

	egen num_antibiotics = rownonmiss(diarrhea_antibiotic tb_antibiotic pneumonia_antibiotic pid_antibiotic)
	lab var num_antibiotics "Number of vignettes where incorrect antibiotics could be prescribed"

	egen num_antibiotict = rowtotal(diarrhea_antibiotic tb_antibiotic pneumonia_antibiotic pid_antibiotic)
	replace num_antibiotict = num_antibiotict/100
	gen percent_antibiotict = num_antibiotict/num_antibiotics * 100
	lab var num_antibiotict "Number of conditions where incorrect antiobiotics were prescribed"
	lab var percent_antibiotict "Fraction of conditions where incorrect antiobiotics were prescribed"

*****************************************************************************
/* Create competence percentiles and deciles */
*****************************************************************************

	xtile pctile_overall = comp_mle, n(100)
	xtile decile_overall = comp_mle, n(10)

	lab var pctile_overall "Competence percentile calculated for all countries combined"
	lab var decile_overall "Competence decile calculated for all countries combined"

	levelsof countrycode
	foreach x in `r(levels)' {
		xtile pctile_comp_`x' = comp_mle if countrycode == `x', n(100) 
		xtile decile_comp_`x' = comp_mle if countrycode == `x', n(10)  
	}
	egen pctile_bycountry = rowmin(pctile_comp_*)
	egen decile_bycountry = rowmin(decile_comp_*)

	drop pctile_comp_* decile_comp_*

	lab var pctile_bycountry "Competence percentile calculated per country"
	lab var decile_bycountry "Competence decile calculated per country"

*****************************************************************************
/* Create measures of effort (questions, exams, tests) */
*****************************************************************************
	
	local diseases = ""
	foreach v of varlist skip_* {
		local dis = substr("`v'", 6, .)
		sum `v'
		if `r(N)' != 0 {
			local diseases = `" "`dis'" `diseases' "'
		}
	}

	foreach disease in `diseases' {
		cap unab vhist : `disease'_history_*
		if "`vhist'" != "" {
			display "`counter'"
			egen `disease'_questions = rownonmiss(`disease'_history_*)
			egen `disease'_questions_num = anycount(`disease'_history_*), val(1)
			gen `disease'_questions_frac = `disease'_questions_num/`disease'_questions * 100
			replace `disease'_questions = . if skip_`disease'==1 | skip_`disease'==. | `disease'_questions==0
			replace `disease'_questions_num = . if skip_`disease'==1 | skip_`disease'==. | `disease'_questions==0 | `disease'_questions==.
			replace `disease'_questions_frac = . if skip_`disease'==1 | skip_`disease'==. | `disease'_questions==0 | `disease'_questions==.

			lab var `disease'_questions "Number of possible `disease' history questions in survey" 
			lab var `disease'_questions_num "Number of `disease' history questions asked"
			lab var `disease'_questions_frac "Fraction of possible `disease' history questions that were asked"
		}
		local vhist = ""
		
		cap unab vtest : `disease'_test_*
		if "`vtest'" != "" {
			egen `disease'_tests = rownonmiss(`disease'_test_*) 
			egen `disease'_tests_num = anycount(`disease'_test_*), val(1)
			gen `disease'_tests_frac = `disease'_tests_num/`disease'_tests * 100
			replace `disease'_tests = . if skip_`disease'==1 | skip_`disease'==. | `disease'_tests==0
			replace `disease'_tests_num = . if skip_`disease'==1 | skip_`disease'==. | `disease'_tests==0 | `disease'_tests==.
			replace `disease'_tests_frac = . if skip_`disease'==1 | skip_`disease'==. | `disease'_tests==0 | `disease'_tests==.

			lab var `disease'_tests "Number of possible `disease' tests in survey"
			lab var `disease'_tests_num  "Number of `disease' tests run"
			lab var `disease'_tests_frac "Fraction of possible `disease' tests that were run"
		}
		local vtest = ""

		cap unab vexam : `disease'_exam_*
		if "`vexam'" != "" {
			egen `disease'_exams = rownonmiss(`disease'_exam_*)
			egen `disease'_exams_num = anycount(`disease'_exam_*), val(1)
			gen `disease'_exams_frac = `disease'_exams_num/`disease'_exams * 100
			replace `disease'_exams = . if skip_`disease'==1 | skip_`disease'==. | `disease'_exams==0
			replace `disease'_exams_num = . if skip_`disease'==1 | skip_`disease'==. | `disease'_exams==0 | `disease'_exams==.
			replace `disease'_exams_frac = . if skip_`disease'==1 | skip_`disease'==. | `disease'_exams==0	| `disease'_exams==.

			lab var `disease'_exams "Number of possible `disease' physical exams in survey"
			lab var `disease'_exams_num "Number of `disease' physical exams done"
			lab var `disease'_exams_frac "Fraction of possible `disease' physical exams that were done"
		}
		local vexam = ""
	}

	egen total_questions = rowtotal(*_questions_num)
	egen total_tests = rowtotal(*_tests_num)
	egen total_exams = rowtotal(*_exams_num)

	lab var total_questions "Total number of history questions asked across all vignettes"
	lab var total_tests "Total number of tests run all vignettes"
	lab var total_exams "Total number of physical exams done across all vignettes"

	egen overall_questions_frac = rowmean(*_questions_frac)
	egen overall_exams_frac = rowmean(*_exams_frac)

	lab var overall_questions_frac "Average proportion of possible questions asked per vignette"
	lab var overall_exams_frac "Average proportion of possible physical exams done per vignette"

*****************************************************************************
/* Save data */
*****************************************************************************

	compress
	saveold "$final/SDI_Vignette_IRT_Analysis_AfterTo$recodeAfter.dta", replace v(12)
	
