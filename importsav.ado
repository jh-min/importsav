*** version 1.3 7November2019
*** contact information: plus1@sogang.ac.kr
*** modified from https://codeandculture.wordpress.com/2010/06/29/importspss-ado-requires-r/

program importsav
	version 10
	args spssfile statafile

quietly {

	if "`statafile'"=="" {
		local statafile "`spssfile'"
	}
	local spssfile=subinstr("`spssfile'", "\", "/", .)
	local statafile=subinstr("`statafile'", "\", "/", .)

	local dir `c(pwd)'
	local rdir=subinstr("`dir'", "\", "/", .)

	local sourcefile=round(runiform()*1000)
	capture file clse rsource
	file open rsource using `sourcefile'.R, write text replace

	file write rsource `"if (!require(haven)) install.packages("haven", repos="https://cran.seoul.go.kr/"); library(haven)"' _n
	file write rsource `""' _n
	file write rsource `"setwd("`rdir'")"' _n
	file write rsource `"data <- read_sav("`spssfile'.sav")"' _n
	file write rsource `"write_dta(data, "temporary_`sourcefile'.dta")"' _n
	file write rsource `"data2 <- read_dta("temporary_`sourcefile'.dta")"' _n
	file write rsource `"attr(data2, "var.labels") <- attr(data, "variable.labels")"' _n
	file write rsource `"write_dta(data2, "`statafile'.dta")"' _n

	file close rsource
	if "`c(os)'"=="MacOSX" {
		shell "/Library/Frameworks/R.framework/Resources/bin/R" --vanilla <`sourcefile'.R
	}
	else {
		shell R --vanilla <`sourcefile'.R
	}
	erase `sourcefile'.R
	capture erase "temporary_`sourcefile'.dta"
	if _rc !=0 {
		capture file close rsource
		file open rsource using `sourcefile'.R , write text replace

		file write rsource `"library(foreign)"' _n
		file write rsource `""' _n
		file write rsource `"setwd("`rdir'")"' _n
		file write rsource `"data <- read.spss("`spssfile'.sav", to.data.frame=TRUE)"' _n
		file write rsource `"write.dta(data, "temporary_`sourcefile'.dta")"' _n
		file write rsource `"data2 <- read.dta("temporary_`sourcefile'.dta")"' _n
		file write rsource `"attr(data2, "var.labels") <- attr(data, "variable.labels")"' _n
		file write rsource `"write.dta(data2, "`statafile'.dta")"' _n

		file close rsource
		if "`c(os)'"=="MacOSX" {
			shell "/Library/Frameworks/R.framework/Resources/bin/R" --vanilla <`sourcefile'.R
		}
		else {
			shell R --vanilla <`sourcefile'.R
		}
		erase `sourcefile'.R
		erase "temporary_`sourcefile'.dta"
	}
	use "`statafile'", clear

}

end
