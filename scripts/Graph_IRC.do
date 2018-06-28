/*
SDI Data Analysis - Graphing Item Response Curves

Author: Anna Konstantinova
Last edited: August 11th, 2017
*/
	
*****************************************************************************
* Initializing 
*****************************************************************************

	//Load and filter the data file
		use "$final/SDI_Vignette_IRT_Analysis_AfterTo$recodeAfter.dta", clear

		append using "$intermediate/irt_output_afterto${recodeAfter}_items.dta", force
		gen n = _n

	//Create a directory for .gph graph files
		cap mkdir "$outputs/figs/IRC/"

*****************************************************************************
* Set graphing and color options
*****************************************************************************

	//graph option
		global graph_opts_irc title(, justification(left) color(black) span pos(11)) subtitle(, justification(left) color(black) span pos(11)) graphregion(color(white)) ylab(,angle(0) nogrid labgap(1)) legend(region(lc(none) fc(none)) cols(3)) bgcolor(white)


	//color palette
		local colors = "navy maroon forest_green dkorange sand emerald olive edkblue erose emidblue olive_teal ltkhaki ebg"  
		
		levelsof country
		local counter = 1
		foreach z in `r(levels)' {
			local place = subinstr("`x'", "-", "",.)
			local color`place' : word `counter' of `colors'
			local ++counter
		}

*****************************************************************************
/* Make item response curves */
*****************************************************************************

	//create decile scores
		bysort country decile_bycountry: egen decile_comp_bycountry = mean(comp_mle)
		bysort decile_overall: egen decile_comp_overall = mean(comp_mle)

	//create variable that specifies the name of the disease
		gen diseasename_at = strpos(varname, "_")
		gen disease = substr(varname, 1, diseasename_at - 1)

	//create local that specifies how the proper disease name for graph titles
		foreach v of varlist skip_* {
			local dis = substr("`v'", 6, .)
			local dislab : var label skip_`dis'
			local dopos = strpos("`dislab'", "do")
			local vigpos = strpos("`dislab'", "vignette")
			local `dis'prop = substr("`dislab'", `dopos'+3, `vigpos'-`dopos'-4)
			local `dis'prop = proper("``dis'prop'")
		}

	local N = _N
	local counter = 1 

	forvalues i = 1/`N' {
		sort n
		local foricc = varname[`i']
		
		if "`foricc'"!="" {
			display "`counter'"
			
			local a = a_pv5[`i']
			local b = b_pv5[`i']
			local c = c_pv5[`i']
			local v = varname[`i']
			local v_dis = disease[`i']
			local v_lab = label[`i']

			gen var1 = 100*(`c'+(1-`c')/2) in 1
			gen var2 = `b' in 1

			bysort country decile_bycountry: egen did_`v' = mean(`v')
			replace did_`v' = did_`v' * 100
				
			local theGraphs = ""
			local theLegend = ""
			levelsof country
			local x = 4
			foreach country in `r(levels)' {
				local placenodash = subinstr("`country'", "-", "", .)
				local placespace = subinstr("`country'", "-", " ", 1)
				local theLegend "`theLegend' `x'"
				local theGraphs `" `theGraphs' (scatter did_`v' decile_comp_bycountry if country=="`country'",  msymbol(smx) msize(large) mcolor(`color`placenodash'') legend(label(`x' "`placespace'"))) "'
				local ++x
				}

			graph twoway ///
				(function y=(`c' + (1-`c')*(exp(`a'*(x-`b'))/(1+exp(`a'*(x-`b')))))*100, range(-5 5) lwidth(0.75) lcolor(black) legend(holes(1))) ///
				(spike var1 var2, base(0) lcolor(gs8) lpattern(shortdash) lwidth(0.25)) ///
				(spike var2 var1, horizontal base(-5) lcolor(gs8) lpattern(shortdash) lwidth(0.25)) ///
				`theGraphs' ///		
				, ///
				xlab(-5 `" "Provider Knowledge Score" " " "Percentile" "' -3 `" "-3" " " " " "' -2 `" "-2" " " "2nd" "' -1 `" "-1" " " "16th" "' 0 `" "0" " " "50th" "' 1 `" "1" " " "84th" "' 2 `" "2" " " "98th" "' 3 `" "3" " " " " "' , labsize(small)) ///
				ylab(0 "0" 25 "25%" 50 "50%" 75 "75%" 100 "100%") ///
				xscale(noli) yscale(noli) ///
				legend(order(`theLegend') size(small)) ///
				title("``v_dis'prop'") subtitle("`v_lab'", size(small)) $graph_opts_irc
				
				graph export "$outputs/figs/IRC/IRC_`v'.png", width(1000) replace
			
			local ++counter

			drop var1 var2
		}
	}
