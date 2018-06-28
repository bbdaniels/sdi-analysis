/*
Master file for conducting IRT-based analysis on SDI data

Author: Anna Konstantinova
Last edited: June 4, 2018

Input:
Output: 
*/

****************************************************************************
* Options
****************************************************************************

* Enter the path to the root directory: 

	global root ///
		"C:\Users\annak\Documents\GitHub\sdi-analysis"
		
* Enter the list of countries to analyze: 
	
	global theCountries ///
		`" "Kenya-2012" "Madagascar-2016" "Nigeria-2013" "Tanzania-2014" "Tanzania-2016" "Uganda-2013" "Mozambique-2014" "Niger-2015" "Senegal-2010" "Togo-2013" "'
		
* Recalculate IRT scores? (Set "yes" or "no"):

	global doIRT = "no"

* Recode "Would do if in ideal world" to 0 or 1? (Set "0" or "1"):

	global recodeAfter = "0"

****************************************************************************
*  Step 1. Setup –– DO NOT EDIT BELOW THIS LINE
****************************************************************************
	
	qui {

		clear all
		set more off
		
		cap cd "$root"
			if _rc!=0 noi di as err "Please enter machine-specific root folder in SDI Master Do-file!"

		global do "$root/scripts"	
			qui do "$do/ado/EasyIRT/easyirt.ado"
			qui do "$do/ado/OpenIRT/openirt.ado"
			qui do "$do/ado/LabelCollapse/labelcollapse.ado"
			qui do "$do/ado/countryprofile_graphs.ado"
			qui do "$do/ado/crosscountry_graphs.ado"
			qui do "$do/ado/countryprofile_compare_graphs.ado"
			
		global clean "$root/SDI-Health/harmonizedData"
		global final "$root/finalData"
		global intermediate "$root/intermediateData"
		global outputs "$root/outputs"
		
	}

****************************************************************************
*  Step 2.  Calculate IRT scores
****************************************************************************

	if "$doIRT" == "yes" {

		do "$do/Do_IRT.do"

	}
		
****************************************************************************
*  Step 3.  Construct effort and quality of care variables
****************************************************************************

	qui do "$do/Make_Variables.do"

****************************************************************************
*  Step 4.  Create item response curve graphs
****************************************************************************

	qui do "$do/Graph_IRC.do"

****************************************************************************
*  Step 5.  Create country profiles
****************************************************************************

	foreach country in "Niger-2015" {
		countryprofile_graphs `country' , saving("$outputs/figs/`country'")
		countryprofile_compare_graphs `country' , saving("$outputs/figs/`country'")
	}

****************************************************************************
*  Step 6.  Create cross-country comparison outputs
****************************************************************************

	crosscountry_graphs "$final/SDI_Vignette_IRT_Analysis_AfterTo$recodeAfter.dta", ///
		countries("Senegal-2010 Kenya-2012 Uganda-2013 Nigeria-2013 Togo-2013 Mozambique-2014 Tanzania-2014 Tanzania-2016 Niger-2015 Madagascar-2016") ///
		saving ("$outputs/figs/CrossCountry/All10")
