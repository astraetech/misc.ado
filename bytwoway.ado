program bytwoway
syntax anything [if] [in], /// 
by(varname) ///
[AESthetics(string) ///
Palette(string) Colors(string) MColors(string) LColors(string) MSymbols(string) LPatterns(string)  * ]

marksample touse
count if `touse'
local samplesize=r(N)
local touse_first=_N-`samplesize'+1
local touse_last=_N
tempvar bylength
bys `touse' `by' : gen `bylength' = _N 
local start = `touse_first'




/* create by, byname, bylabel (bylabel if by == 1), bynum, byvalmatrix */

local byn: word count `by'
if `byn' > 1{
    local i = 0
    foreach v in `by'{
        local ++i
        local byname`i' `: var label `v''
        if `"byname`i'"' == ""{
            local byname`i' `v'
        }
    }
    tempvar by
    bysort `vlist' : gen `by' = _n == 1
    replace `by' = sum(`by')
    local bylegend ""
}
else{
    capture confirm numeric variable `by'
    if _rc {
        * by-variable is string => generate a numeric version
        tempvar by
        tempname bylabel
        egen `by'=group(`byvarname'), lname(`bylabel')
    }
    else{
        local bylabel `:value label `by''
    }
    local byname `: var label `by''
    if `"`byname'"' == ""{
        local byname `by'
    }
    local bylegend legend(subtitle(`"`byname'"'))
}
tempname byvalmatrix
qui tab `by' if `touse'==1, nofreq matrow(`byvalmatrix')
local bynum=r(r)




/* set list just after bynum */
* default aesthetics to color and replace color by mcolor and lcolor
if "`aesthetics'" == ""{
    local aesthetics mcolor lcolor
}
local aesthetics2
foreach a in `aesthetics'{
    if "`a'" == "color"{
        local aesthetics2 `aesthetics2' mcolor lcolor
    }
    else{
        local aesthetics2 `aesthetics2' `a'
    }
}
local aesthetics `aesthetics2'

if `"`colors'"' == ""{
    if "`palette'" ~= ""{
        cap assert "`mcolor'`lcolor'" ~= ""
        colorscheme `bynum', palette(`palette')
        local colors `"`=r(colors)'"'
    }
    else{
        local colors ///
        navy maroon forest_green dkorange teal cranberry lavender ///
        khaki sienna emidblue emerald brown erose gold bluishgray ///
        lime magenta cyan pink blue
    }
}

* Fill colors if missing
if `"`mcolors'"'=="" {
    if (`ynum'==1 & `bynum'==1 & "`linetype'"!="connect"){
        local mcolors `: word 1 of `colors''
    }
    else if regexm("`aesthetics'","mcolor"){
        local mcolors `colors'
    }
    else{
        local aesthetics `aesthetics' mcolor
        local mcolors black black black black black black black ///
        black black black black black black black black ///
        black black black black black black black black
    }
}

if `"`lcolors'"'=="" {
    if (`ynum'==1 & `bynum'==1 & "`linetype'"!="connect"){
        local lcolors `: word 2 of `colors''
    }
    else if regexm("`aesthetics'","lcolor"){
        local lcolors `colors'
    }
    else{
        local aesthetics `aesthetics' lcolor
        local lcolors black black black black black black black ///
        black black black black black black black black ///
        black black black black black black black black
    }
}

if `"`lpatterns'"'=="" {
    if regexm("`aesthetics'","lpattern"){
        local lpatterns solid dash vshortdash longdash longdash_dot dash_dot dot shortdash_dot tight_dot dash_dot_dot longdash_shortdash dash_3dot longdash_dot_dot shortdash_dot_dot longdash_3dot
    }
    else{
        local aesthetics `aesthetics' lpattern
        local lpatterns solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid solid 
    }
}

if `"`msymbols'"'=="" {
    if regexm("`aesthetics'","lpattern"){
        local msymbols circle diamond square triangle x plus circle_hollow diamond_hollow square_hollow triangle_hollow smcircle smdiamond smsquare smtriangle smx

    }
    else{
        local aesthetics `aesthetics' msymbol
        local msymbols circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle circle 
    }
}


tempvar bylength
bys `touse' `by' : gen `bylength' = _N 
local start = `touse_first'
local i = 0
while `start' <= `touse_last'{
    local ++i
    local end = `start' + `=`bylength'[`start']' - 1
    local byvalname 
    if `"`bylegend'"' ~= ""{
        local byval `=`by'[`start']'
        if ("`bylabel'"=="") {
            local byvalname `byval'
        }
        else {
            local byvalname `: label `bylabel' `byval''
        }
    }
    else{
        local i = 0
        foreach v in `by'{
            local ++i
            local byval`i' `=`v'[`start']'
            local bylabel`i' `: value label `v''
            if ("`bylabel`i''"=="") {
                local byvalname `byvalname', `byname`i'' = `byval`i''
            }
            else {
                local byvalname `byvalname', `byname`i'' = `: label `bylabel`i'' `byval`i'''
            }
        }
        local byvalname `=subinstr(`"`byvalname'"',",","",1)'
    }
    local scatter_options legend(label(`i'  `byvalname')) 
    foreach a in `aesthetics' {
        local scatter_option `a'(`"`:word `i' of ``a's''"')
        local scatter_options `scatter_options' `scatter_option'
    }
    local script `script' (`anything' in `start'/`end', `scatter_options')
    local start = `end' + 1

}



twoway `script',  `bylegend'  `options'
end

/***************************************************************************************************
sysuse nlsw88.dta, clear
collapse (mean) wage, by(grade race)
bytwoway line wage grade, by(race)
***************************************************************************************************/