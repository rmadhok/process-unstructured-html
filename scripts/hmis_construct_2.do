********************************************************************************
*																			*
* PROJECT: 	India Power Plant Paper											* 
*																			*
* PURPOSE: CONSTRUCT HMIS PANEL											    *
*																			*
* DATE: Feb 24th, 2016													    *
*																			*
* AUTHOR:  Raahil Madhok 													*
*																				
********************************************************************************
*===============================================================================
********************************************************************************
*0. SET ENVIRONMENT
********************************************************************************
*===============================================================================

// Settings
clear all
pause on
cap log close
set more off
set maxvar 6000
set matsize 3300

//Set Directory
/*------------------------------------------
Sets path directory for each users computer
so program can run on any device.
Toggle local value when switching user
-------------------------------------------*/
local RAAHIL 1
local OTHERUSER  0

if `RAAHIL' {
	local ROOT /Users/rmadhok/Dropbox (CID)/HMIS
	local DATA `ROOT'/data
	}

if `OTHERUSER' {
	local ROOT
	local DATA
	//[INSERT LOCALS FOR FILE PATHS]
	}
	
*===============================================================================
********************************************************************************
*1. DATA CLEANING/PREPARATION
********************************************************************************
*===============================================================================
//1.1 Import Data
*import delimited using "`DATA'/raw/hmis_long_2.csv", ///
*	colrange(2:) varnames(1) encoding("utf-8") clear
*saveold "`DATA'/raw/hmis_long_2.dta", v(13) replace
use "`DATA'/raw/hmis_long_2.dta", clear
order state district year q_no ///
	  q_subname m1 m2 m3 m4 m5 ///
	  m6 m7 m8 m9 m10 m11 m12

//1.2 Basic Data Cleaning
// In preparation for reshape
//1.2a Trim whitespace
foreach x of varlist district q*{
	replace `x' = trim(`x')
	}

//1.2b Narrow down columns for easy browsing
format %18s district q_no
format %24s q_subname

//1.2c Concatenate question no and subname
//	Clean question no values
replace q_no = lower(q_no)
replace q_no = subinstr(q_no, ".", "_", .)
replace q_no = subinstr(q_no, "(", "", .)
replace q_no = subinstr(q_no, ")", "", .)
//	Clean sub question
replace q_subname = lower(q_subname)
foreach x in "1." "2." "3." "4." "5."{
	replace q_subname = subinstr(q_subname, "`x'", "", .)
	}
replace q_subname = subinstr(q_subname, ".", "", .)
replace q_subname = subinstr(q_subname, "-", "_", .)
replace q_subname = subinstr(q_subname, "&", "_", .)
replace q_subname = subinstr(q_subname, " ", "", .)
replace q_subname = subinstr(q_subname, "balancefrompreviousmonth", "balance",.)
replace q_subname = subinstr(q_subname, "between", "bw",.)
//	Concatenate q_no and q_subname
egen q_full = concat(q_no q_subname), p(_)
order q_full, after(year)
replace q_full = "q" + q_full

//1.3 export variable list
// question names are too long 
// so we keep question no's 
// and export codebook 
preserve
	bys q_full: keep if _n == 1
	keep q*
	export delimited "`DATA'/clean/hmis_varlist.csv", replace
restore
drop q_no q_subname q_name

*===============================================================================
********************************************************************************
*2. CONSTRUCT PANEL - RESHAPE
********************************************************************************
*===============================================================================
/*-------------------------------------------------
Data is structured unusually, with months as cols
and questions as rows, repeated for each dist-year.
This requires 2 reshapes: wide, to create 
month*question as cols; long to get year*month rows
for each dist.
--------------------------------------------------*/
//2.1 Reshape wide
//	Put q_full as prefix 
reshape wide @m1 @m2 @m3 @m4 @m5 ///
	@m6 @m7 @m8 @m9 @m10 @m11 @m12, ///
	i(state district year) j(q_full) s

*save "`DATA'/raw/wide.dta", replace
use "`DATA'/raw/wide.dta", replace

//2.2 Reshape Long
//2.2a Collect stubnames in macro
unab vars: *m1
local stubs: subinstr local vars "m1" "", all
//2.2b Reshape
reshape long `stubs', i(state district year) j(month) s
// Save, so we can start from here 
// when re-running script
save "`DATA'/raw/long.dta", replace

*===============================================================================
********************************************************************************
*3. CLEAN PANEL
********************************************************************************
*===============================================================================
use "`DATA'/raw/long.dta", replace

//3.1 Clean Dates
//3.1a Clean month
replace month = subinstr(month, "m", "", .)
destring month, replace

//3.1b Convert Year to Fiscal
split year, parse(-)
order year1 year2, after(year)
destring year1 year2, replace
replace year1 = year1 + 1 if month < 4
drop year year2
ren year1 year

//3.1c Format date
//	Create year-month string
//	Add leading zero
gen str2 month1 = string(month,"%02.0f")
egen yearmonth = concat(year month1), punct(-)
order yearmonth, after(district)
drop month1
//	Create state-formatted yearmonth
gen year_month = ym(year, month)
order year_month, after(yearmonth)
format year_month %tmCCYY-NN

//3.2 Destring all questions
destring q*, replace

//3.3 Finalize and save
sort state district year_month
saveold "`DATA'/clean/hmis_master.dta", v(13) replace
export delimited "`DATA'/clean/hmis_master.csv", replace


/*==========
FIN
==========*/
