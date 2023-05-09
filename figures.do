
* change file path name for your own computer below
cd "/Users/gageweston/Desktop/PWI/Population Projections/sangita paper/"
import delimited "output.csv", clear

* do some basic arranging
replace tfr_scenario="2.05" if  tfr_scenario=="replacement"
destring  tfr_scenario, replace

sort location treatment year_treat tfr_scenario year
* scale data to smaller values
replace population = population / 1e+9
local units = 1e+6
local varlist births births_dif lives_saved population_saved population_born
foreach var of local varlist {
	replace `var' = `var' / `units' if treatment != "add 1 person"
}

* get cumulative sums over time
local varlist births_dif lives_saved years_lived_saved years_lived_born
foreach var of local varlist {
	bysort treatment year_treat age_treat life_exp_max tfr_scenario location (year): gen `var'_cum = sum(`var')
}

* divide 5-year flows by 5 to turn into 1-year flows
foreach var in births births_dif years_lived years_lived_dif years_lived_saved years_lived_born deaths lives_saved {
replace `var' = `var' / 5
}

net install grc1leg,from( http://www.stata.com/users/vwiggins/) 

* filters
local c = "High-mortality countries"
local tfr = 1.75
local year_end = 2300
* graph and line sizes
local x_size = 10
local y_size = 4
local y_size_single = `y_size' * 2.25
local y_size_double = `y_size' * 1.3
local line_thick = "medthick"
local grid_thick = "thin"
local axis_size = "medium"
local legend_size = "small"
local symbol_size = 10
local columns = 1
local columns2 = 2
* text
local text_size = "small"
local text_x = 2160
local text_place = "c"
* line colors
local c_born = "red"
local c_saved = "midblue"
local c_base = "orange"
local c_2030 = "green"
local c_2050 = "156 39 176"
local c_2100 = "blue"
* dashes
local p_born = "dash"
local p_saved = "solid"
local p_base = "solid"
local p_2030 = "longdash"
local p_2050 = "dash"
local p_2100 = "shortdash"
* titles
local title_size = "large"
local title_gap = 5
local title_2030 = "(a) U5MR achieved by 2030"
local title_2050 = "(b) U5MR achieved by 2050"
local title_2100 = "(c) U5MR achieved by 2100"
* legend labels
local leg_born = "Descendants"
local leg_saved = "Lives Saved"
local leg_pos = 6
local leg_ring = 1
local LY_unit = "Life-Years"


* drop data that will only be used for the appendix, then restore later
preserve
keep if age_treat == 0 & life_exp_max == 100
sort tfr_scenario year_treat age_treat life_exp_max location year





********* generate figures





*** mortality figure


twoway (line mortality year if year_treat=="2025-2030", lw(`line_thick') lc(`c_base') lp(`p_base')) ///
(line mortality_t year if year_treat=="2025-2100", lw(`line_thick') lc("`c_2100'") lp(`p_2100')) ///
(line mortality_t year if year_treat=="2025-2050", lw(`line_thick') lc("`c_2050'") lp(`p_2050')) ///
(line mortality_t year if year_treat=="2025-2030", lw(`line_thick') lc("`c_2030'") lp(`p_2030')) ///
if tfr_scenario==`tfr' & location=="`c'"& year <= `year_end' ///
 , ///
 ylab(, nogrid angle(horizontal)) ///
 graphr(c(white) lc(white)) ///
 title("(a) Child Mortality", size(`title_size') margin(b=`title_gap')) ///
 xtitle("Year", size(`axis_size')) ///
 ytitle("Under-5 Mortality Rate (Deaths/1000 Live Births)", axis(1) size(`axis_size')) ///
 legend(title("{bf:U5MR achieved by:}", size(`legend_size')) size(`legend_size') col(1) symxsize(`symbol_size') pos(12) ring(0) region(c(none) lc(none)) order(1 "2175" "(Business-as-Usual)" ///
 2 "2100" ///
 3 "2050" ///
 4 "2030") ///
 ) ///
 plotr(m(zero)) ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 name(mortality, replace) ///
 xsize(`x_size') ysize(`y_size') /// 
 graphregion(color(white))
 
 
 
*** total fertility rate figure


twoway (line fertility year if tfr_scenario==`tfr', lw(`line_thick') lc(`c_base') lp(`p_base')) ///
if  location=="`c'" & year_treat=="2025-2030" & year <= `year_end' ///
 , ///
 ylab(, nogrid angle(horizontal)) ///
 graphr(c(white) lc(white)) ///
 title("(b) Fertility", size(`title_size') margin(b=`title_gap')) ///
 xtitle("Year", size(`axis_size')) ///
 ytitle("Total Fertility Rate (Births/Woman)", axis(1) size(`axis_size')) ///
 legend(off) ///
 plotr(m(zero)) ///
 ylab(0 1 2 3 4) ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 name(fertility, replace) ///
 xsize(`x_size') ysize(`y_size') /// 
 graphregion(color(white))
 

 
*** population figure


twoway (line population year if tfr_scenario==`tfr', lw(`line_thick') lc(`c_base') lp(`p_base')) ///
if location=="`c'" & year_treat=="2025-2030" & year <= `year_end' ///
 , ///
 ylab(, nogrid angle(horizontal)) ///
 graphr(c(white) lc(white)) ///
 title("(c) Population Size (Business-as-Usual)", size(`title_size') margin(b=`title_gap')) ///
 xtitle("Year", size(`axis_size')) ///
 ytitle("Population Size", axis(1) size(`axis_size')) ///
 ylab(0 "0" 1 "1b" 2 "2b" 3 "3b" 4 "4b" 5 "5b") ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 plotr(m(zero)) ///
 legend(off) ///
 name(population, replace) ///
 xsize(`x_size') ysize(`y_size') /// 
 graphregion(color(white))



*** combine mortality, fertility and population figures 

 
graph combine mortality fertility population, graphregion(color(white)) name(mort_fert_pop, replace) xcommon cols(3) xsize(`x_size') ysize(`y_size') plotr(m(zero))
graph display mort_fert_pop
graph export "mort_fert_pop.pdf", as(pdf) replace




*** add 1 person figure

local LY_descendants = "(656 `LY_unit')"
local LY_saved = "(70 `LY_unit')"
* births_dif_cum = 8.717
 
twoway (line population_born year if tfr_scenario==`tfr' & location=="`c'" & treatment == "add 1 person" & year <= `year_end', lw(`line_thick') lc(`c_born') lp(`p_born')) ///
(line population_saved year if tfr_scenario==`tfr' & location=="`c'" & treatment == "add 1 person" & year <= `year_end' & population_saved > 0, lw(`line_thick') lc(`c_saved') lp(`p_saved')) ///
, ///
 ylab(, nogrid angle(horizontal)) ///
graphr(c(white) lc(white)) ///
 xtitle("Year", size(`axis_size')) ///
 ytitle("Population Difference" "Relative to Business-as-Usual", axis(1) size(`axis_size')) ///
 legend(size(`legend_size') col(`columns2') symxsize(`symbol_size') pos(`leg_pos') ring(`leg_ring') region(c(none) lc(none)) order(2 "Life-Saving Effect" ///
 1 "Descendant Effect") ///
 ) ///
 plotr(m(zero)) ///
 ylab(0 1 2 3 4) ///
 xlab(2025 "  2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 text(2.2 `text_x' "{bf:Cumulative Effect by `year_end'}" 2 `text_x' "1 Life Saved" 1.8 `text_x' " 9 Descendants Born", size(`text_size') place(`text_place'))  ///
 name(add_1_person, replace) ///
 xsize(`x_size') ysize(`y_size_single') /// 
 graphregion(color(white))
 graph export "add_1_person.pdf", as(pdf) replace
 
 
 


*** difference in population of Lives Saved figure

local text_x = 2210
local step = 12
local text_y1 = 130
local text_y2 = `text_y1' - `step'
local text_y3 = `text_y2' - `step'


* 2030 scenario

local LY_descendants = "48b `LY_unit'"
local LY_saved = "13b `LY_unit'"
local new_births = "631m"
local lives_saved = "171m"
local year_treat = "2025-2030"
twoway (line population_born year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end', lw(`line_thick') lc(`c_born') lp(`p_born')) ///
 (line population_saved year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end' & population_saved > 0, lw(`line_thick') lc(`c_saved') lp(`p_saved')) ///
 , ///
 ylab(, nogrid angle(horizontal)) ///
 graphr(c(white) lc(white)) ///
 title("`title_2030'", size(`title_size') margin(b=`title_gap')) ///
 xtitle("Year", size(`axis_size')) ///
 ytitle("Population Difference" "Relative to Business-as-Usual", axis(1) size(`axis_size')) ///
 legend(off) ///
 plotr(m(zero)) ///
 ylab(0 "0" 100 "100m" 200 "200m" 300 "300m") ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 text(`text_y1' `text_x' "{bf:Cumulative Effect by `year_end'}" `text_y2' `text_x' "`lives_saved' Lives Saved" `text_y3' `text_x' "`new_births' Descendants Born", size(`text_size') place(`text_place'))  ///
 name(pop_dif_2030, replace) ///
 xsize(`x_size') ysize(`y_size') /// 
 graphregion(color(white))

 
* 2050 scenario

local LY_descendants = "30b `LY_unit'"
local LY_saved = "10b `LY_unit'"
local new_births = "360m"
local lives_saved = "123m"
local year_treat = "2025-2050"
twoway (line population_born year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end', lw(`line_thick') lc(`c_born') lp(`p_born')) ///
 (line population_saved year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end' & population_saved > 0, lw(`line_thick') lc(`c_saved') lp(`p_saved')) ///
 , ///
 graphr(c(white) lc(white)) ///
 title("`title_2050'", size(`title_size') margin(b=`title_gap')) ///
 xtitle("Year", size(`axis_size')) ///
 legend(size(`legend_size') col(`columns2') symxsize(`symbol_size') pos(`leg_pos') ring(`leg_ring') region(c(none) lc(none)) order(2 "Life-Saving Effect" ///
 1 "Descendant Effect") ///
 ) ///
 plotr(m(zero)) ///
 ytitle("", axis(1) size(`axis_size')) ///
 yscale(noline) ///
 ytick(,noticks) ///
 ylab(,nolabels nogrid angle(horizontal) noticks) ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 text(`text_y1' `text_x' "{bf:Cumulative Effect by `year_end'}" `text_y2' `text_x' "`lives_saved' Lives Saved" `text_y3' `text_x' "`new_births' Descendants Born", size(`text_size') place(`text_place'))  ///
 name(pop_dif_2050, replace) ///
 xsize(`x_size') ysize(`y_size') /// 
 graphregion(color(white))

* 2100 scenario

local LY_descendants = "10b `LY_unit'"
local LY_saved = "2b `LY_unit'"
local new_births = "35m"
local lives_saved = "26m"
local year_treat = "2025-2100"
twoway (line population_born year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end', lw(`line_thick') lc(`c_born') lp(`p_born')) ///
 (line population_saved year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end' & population_saved > 0, lw(`line_thick') lc(`c_saved') lp(`p_saved')) ///
 , ///
 graphr(c(white) lc(white)) ///
 title("`title_2100'", size(`title_size') margin(b=`title_gap')) ///
 xtitle("Year", size(`axis_size')) ///
 legend(off) ///
 plotr(m(zero)) ///
 ytitle("", axis(1) size(`axis_size')) ///
 yscale(noline) ///
 ytick(,noticks) ///
 ylab(,nolabels nogrid angle(horizontal) noticks) ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 text(`text_y1' `text_x' "{bf:Cumulative Effect by `year_end'}" `text_y2' `text_x' "`lives_saved' Lives Saved" `text_y3' `text_x' "`new_births' Descendants Born", size(`text_size') place(`text_place'))  ///
 name(pop_dif_2100, replace) ///
 xsize(`x_size') ysize(`y_size') /// 
 graphregion(color(white))

 
grc1leg pop_dif_2030 pop_dif_2050 pop_dif_2100, graphregion(color(white)) name(pop_dif, replace) ycommon xcommon cols(3) legendfrom(pop_dif_2050)
graph display pop_dif, ysize(`y_size') xsize(`x_size')
graph export "pop_dif.pdf", as(pdf) replace




*** Descendants born per life saved, by 2023 country-specific TFR



local x_title = "Country-Specific Total Fertility Rate in 2023"
local y_title = "Descendants Born by 2300 per Life Saved"
gen born_saved_ratio = births_dif_cum / lives_saved_cum
 
twoway (scatter born_saved_ratio tfr_2023, mcolor(`c_2030')) ///
 if year_treat == "2025-2030" & year == `year_end' &  tfr_scenario == `tfr' & location !="`c'",  ///
 legend(off) ///
 ylab(, nogrid angle(horizontal)) ///
 graphr(c(white) lc(white)) ///
 xtitle("`x_title'", size(`axis_size')) ///
 ytitle("`y_title'", axis(1) size(`axis_size')) ///
 name(tfr_country_mort, replace) ///
 xsize(`x_size') ysize(`y_size_single') /// 
 graphregion(color(white))
 graph display tfr_country_mort
 graph export "tfr_country_mort.pdf", as(pdf) replace




*** Cumulative descendants born based on TFR scenario

twoway (line births_dif_cum tfr_scenario if year_treat == "2025-2030", lw(`line_thick') lc("`c_2030'") lp(`p_2030')) ///
(line births_dif_cum tfr_scenario if year_treat == "2025-2050", lw(`line_thick') lc("`c_2050'") lp(`p_2050')) ///
(line births_dif_cum tfr_scenario  if year_treat == "2025-2100", lw(`line_thick') lc("`c_2100'") lp(`p_2100')) ///
if year == `year_end' & tfr_scenario <= 2.05 & tfr_scenario >= 1 & location == "`c'" ///
, ///
ylab(0 "0" 250 "250m" 500 "500m" 750 "750m" 1000 "1,000m", nogrid angle(horizontal) axis(1)) ///
xlab(1 1.25 1.5 1.75 2) ///
 graphr(c(white) lc(white)) ///
 xtitle("Long-Run Total Fertility Rate", size(`axis_size')) ///
 ytitle("Cumulative Descendants Born by `year_end'", size(`axis_size')) ///
 legend(title("{bf:U5MR achieved by:}", size(`legend_size')) size(`legend_size') col(1) symxsize(`symbol_size') pos(12) ring(0) region(c(none) lc(none)) order(1 "2030" ///
 2 "2050" ///
 3 "2100") ///
 ) ///
 name(mort_fert_scenarios, replace) ///
 xsize(`x_size') ysize(`y_size_single') /// 
 graphregion(color(white))
 graph export "fert_scenarios.pdf", as(pdf) replace





 
 
 



*** Appendix figures



*** difference in population of Lives Saved figure
sort year year_treat
local title = "Annual Lives Saved or Descendants Born"


* 2030 scenario

local LY_descendants = "48b `LY_unit'"
local LY_saved = "13b `LY_unit'"
local new_births = "631m"
local lives_saved = "171m"
local year_treat = "2025-2030"
twoway (line births_dif year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end', lw(`line_thick') lc(`c_born') lp(`p_born')) ///
 (line lives_saved year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end' & population_saved > 0, lw(`line_thick') lc(`c_saved') lp(`p_saved')) ///
 , ///
 ylab(, nogrid angle(horizontal)) ///
 graphr(c(white) lc(white)) ///
 title("`title_2030'", size(`title_size') margin(b=`title_gap')) ///
 xtitle("Year", size(`axis_size')) ///
 ytitle("`title'", axis(1) size(`axis_size')) ///
 legend(off) ///
 plotr(m(zero)) ///
 ylab(0 "0" 1 "1m" 2 "2m" 3 "3m" 4 "4m") ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 name(annual_dif_2030, replace) ///
 xsize(`x_size') ysize(`y_size') /// 
 graphregion(color(white))

 
 
* 2050 scenario

local LY_descendants = "30b `LY_unit'"
local LY_saved = "10b `LY_unit'"
local new_births = "360m"
local lives_saved = "123m"
local year_treat = "2025-2050"
twoway (line births_dif year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end', lw(`line_thick') lc(`c_born') lp(`p_born')) ///
 (line lives_saved year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end' & population_saved > 0, lw(`line_thick') lc(`c_saved') lp(`p_saved')) ///
 , ///
 graphr(c(white) lc(white)) ///
 title("`title_2050'", size(`title_size') margin(b=`title_gap')) ///
 xtitle("Year", size(`axis_size')) ///
 legend(size(`legend_size') col(`columns2') symxsize(`symbol_size') pos(`leg_pos') ring(`leg_ring') region(c(none) lc(none)) order(2 "Life-Saving Effect" ///
 1 "Descendant Effect") ///
 ) ///
 plotr(m(zero)) ///
 ytitle("", axis(1) size(`axis_size')) ///
 yscale(noline) ///
 ytick(,noticks) ///
 ylab(,nolabels nogrid angle(horizontal) noticks) ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 name(annual_dif_2050, replace) ///
 xsize(`x_size') ysize(`y_size') /// 
 graphregion(color(white))

 
 
* 2100 scenario

local LY_descendants = "10b `LY_unit'"
local LY_saved = "2b `LY_unit'"
local new_births = "35m"
local lives_saved = "26m"
local year_treat = "2025-2100"
twoway (line births_dif year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end', lw(`line_thick') lc(`c_born') lp(`p_born')) ///
 (line lives_saved year if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end' & population_saved > 0, lw(`line_thick') lc(`c_saved') lp(`p_saved')) ///
 , ///
 graphr(c(white) lc(white)) ///
 title("`title_2100'", size(`title_size') margin(b=`title_gap')) ///
 xtitle("Year", size(`axis_size')) ///
 legend(off) ///
 plotr(m(zero)) ///
 ytitle("", axis(1) size(`axis_size')) ///
 yscale(noline) ///
 ytick(,noticks) ///
 ylab(,nolabels nogrid angle(horizontal) noticks) ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 name(annual_dif_2100, replace) ///
 xsize(`x_size') ysize(`y_size') /// 
 graphregion(color(white))


grc1leg annual_dif_2030 annual_dif_2050 annual_dif_2100, graphregion(color(white)) name(annual_dif, replace) ycommon xcommon cols(3) legendfrom(annual_dif_2050)
graph display annual_dif, ysize(`y_size') xsize(`x_size')
graph export "annual_dif.pdf", as(pdf) replace



 
 
 *** TFR scenarios and their effect on population and population dif over time
 
local tfr_scenarios 1 1.2 1.4 1.6 1.8 2 2.2 2.4
local symbol_size = 5
local leg_title = "{bf:Long-Run Total Fertility Rate}"
local legend_size2 = "vsmall"
sort year_treat treatment location tfr_scenario year


* Fertility

foreach tfr_ of local tfr_scenarios {
	local gr `gr' line fertility year if location == "`c'" & tfr_scenario == `tfr_' & treatment == "add 1 person" ||
	}
graph twoway `gr', ///
graphr(c(white) lc(white)) ///
title("(a) Fertility", size(`title_size') margin(b=`title_gap')) ///
xtitle("Year", size(`axis_size')) ///
ytitle("Total Fertility Rate (Births/Woman)", axis(1) size(`axis_size')) ///
plotr(m(zero)) ///
ylab(0 1 2 3 4, nogrid angle(horizontal)) ///
xlab(2025 "2025" 2100 "2100" 2200 "2200" 2300 "2300 ") ///
legend(title("`leg_title'", size(`legend_size2')) size(`legend_size2') col(4) symxsize(`symbol_size') pos(12) ring(0) region(c(none) lc(none)) order(1 "1" 2 "1.2" 3 "1.4" 4 "1.6" 5 "1.8" 6 "2" 7 "2.2" 8 "2.4")) ///
name(fertility_appendix, replace) ///
xsize(`x_size') ysize(`y_size') /// 
graphregion(color(white))


* Population size

foreach tfr_ of local tfr_scenarios {
	local graph `graph' line population year if location == "`c'" & tfr_scenario == `tfr_' & treatment == "add 1 person" ||
	}
graph twoway `graph', ///
graphr(c(white) lc(white)) ///
title("(b) Population Size (Business-as-Usual)", size(`title_size') margin(b=`title_gap')) ///
xtitle("Year", size(`axis_size')) ///
ytitle("Population Size", axis(1) size(`axis_size')) ///
plotr(m(zero)) ///
ylab(0 "0" 3 "3b" 6 "6b" 9 "9b" 12 "12b", nogrid angle(horizontal)) ///
xlab(2025 "2025" 2100 "2100" 2200 "2200" 2300 "2300 ") ///
name(population_appendix, replace) ///
xsize(`x_size') ysize(`y_size') /// 
graphregion(color(white))



grc1leg fertility_appendix population_appendix, graphregion(color(white)) name( fert_scenarios_appendix, replace) xcommon cols(2) legendfrom(fertility_appendix)
graph display fert_scenarios_appendix, ysize(`y_size_double') xsize(`x_size')
graph export "tfr_appendix.pdf", as(pdf) replace





*** Cumulative descendants born by TFR scenario, saving 1 child's life
sort tfr_scenario

twoway (line births_dif_cum tfr_scenario, lw(`line_thick') lc("`c_born'") lp(solid)) ///
if location == "`c'" & treatment == "add 1 person" & year == `year_end' ///
, ///
 ylab(0 5 10 15 20 25,nogrid angle(horizontal) axis(1)) ///
 xlab(1 1.5 2 2.5) ///
 graphr(c(white) lc(white)) ///
 xtitle("Long-Run Total Fertility Rate", size(`axis_size')) ///
 ytitle("Cumulative Descendants Born by `year_end'", size(`axis_size')) ///
 name(fert_scenarios_add_person, replace) ///
 xsize(`x_size') ysize(`y_size_single') /// 
 graphregion(color(white))
 graph display fert_scenarios_add_person
 graph export "fert_scenarios_add_person.pdf", as(pdf) replace
 




 *** Descendants born per life saved, by 2023 country-specific TFR

 
 * add 1 person treatment

local x_title = "Country-Specific Total Fertility Rate in 2023"
local y_title = "Descendants Born by 2300 per Life Saved"

twoway (scatter births_dif_cum tfr_2023, mcolor(green)) ///
 if treatment == "add 1 person" & year == `year_end' &  tfr_scenario == `tfr' & location != "`c'",  ///
 legend(off) ///
 ylab(0 "0" 5 "5" 10 "10" 15 "15", nogrid angle(horizontal)) ///
 graphr(c(white) lc(white)) ///
 xtitle("`x_title'", size(`axis_size')) ///
 ytitle("`y_title'", axis(1) size(`axis_size')) ///
 name(tfr_country_add_person, replace) ///
 xsize(`x_size') ysize(`y_size_single') /// 
 graphregion(color(white))
 graph display tfr_country_add_person
 graph export "tfr_country_add_person.pdf", as(pdf) replace


restore

*** test robustness to alternative mortality and life-expectancy scenarios

sort life_exp_max treatment year
local year_treat = "2025-2030"
local symbol_size = 10

twoway (line population_dif year if life_exp_max == 90, lw(`line_thick') lc(`c_2030'*0.5) lp(shortdash)) ///
(line population_dif year if life_exp_max == 100, lw(`line_thick') lc(`c_2030') lp(solid)) ///
 if tfr_scenario==`tfr' & location=="`c'" & year_treat== "`year_treat'" & year <= `year_end', ///
 ylab(, nogrid angle(horizontal)) ///
 graphr(c(white) lc(white)) ///
 xtitle("Year", size(`axis_size')) ///
 ytitle("Population Difference" "(Lives Saved + Descendants)", axis(1) size(`axis_size')) ///
 legend(title("{bf:Long-Run}" "{bf:Life-Expectancy}", size(`legend_size')) size(`legend_size') col(1) symxsize(`symbol_size') pos(0) ring(0) region(c(none) lc(none)) order(1 "90" ///
 2 "100" ///
 )) ///
 plotr(m(zero)) ///
 xlab(2025 "2025" 2100 "2100" 2200 "2200" `year_end' "`year_end' ") ///
 ylab(0 "0" 1e+8 "100m" 2e+8 "200m" 3e+8 "300m") ///
 name(mortality_test, replace) ///
 xsize(`x_size') ysize(`y_size_single') /// 
 graphregion(color(white))
 graph display mortality_test
 graph export "mortality_test.pdf", as(pdf) replace



 

 *** save a child's life at different ages_may2
 
keep if treatment == "add 1 person" & location == "`c'" & tfr_scenario == `tfr' & year == `year_end'
preserve
keep if age_treat == 0
keep location year births_dif_cum
rename births_dif_cum births_dif_cum_0_5
save age_0_5.dta,replace
restore
merge m:m location year using age_0_5.dta
drop _merge
erase age_0_5.dta
gen age_factor = births_dif_cum / births_dif_cum_0_5
sort age_treat

twoway (line age_factor age_treat, lw(`line_thick') lc(`c_born') lp(solid)), ///
 graphr(c(white) lc(white)) ///
 xtitle("Age when Life is Saved", size(`axis_size')) ///
 ytitle("Descendants Born by 2300" "Relative to Saving a Child under 5", axis(1) size(`axis_size')) ///
 legend(title(, size(`legend_size')) size(`legend_size') col(1) symxsize(`symbol_size') pos(1) ring(0) region(c(none) lc(none)) order(1 "using projections" ///
 2 "using 2023 TFR" ///
 )) ///
 plotr(m(zero)) ///
 xlab(0 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50") ///
 ylab(0 "0%" 0.5 "50%" 1 "100%" 1.5 "150%", nogrid angle(horizontal)) ///
 name(age_factor, replace) ///
 xsize(`x_size') ysize(`y_size_single') /// 
 graphregion(color(white))
 graph display age_factor
 graph export "age_factor.pdf", as(pdf) replace
