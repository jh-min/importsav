*** version 2.0 11November2019
*** contact information: plus1@sogang.ac.kr

program findr
	version 10

quietly {

	capture whereis R
	if _rc==0 {
		local Rpath "`r(R)'"
	}
	else {
		capture which whereis
		if _rc==0 {
			noisily mata: printf("{txt}location of R has not been stored with {cmd:whereis.ado}\n")
		}
		else {
			noisily mata: printf("{cmd:whereis.ado}{text} is not installed\n")
		}
		noisily mata: printf("{cmd:importsav.ado}{text} searches expected directories...\n")
		local wd `c(pwd)'
		if "`c(os)'"=="Windows" {
			capture cd "C:\Program Files\R"
			if _rc!=0 {
				capture cd "C:\Program Files (x86)\R"
				if _rc!=0 {
					noisily mata: printf("{cmd:importsav.ado}{text} could not find R in expected directories\n...will depend on the PATH environment variable\n")
					local Rpath R
					local Renv on
				}
			}
			local Rversion : dir "`c(pwd)'" dirs "R*", respectcase
			local i : word count `Rversion'
			local newest_R : word `i' of `Rversion'
			cd "`newest_R'\bin"
			local Rpath "`c(pwd)'\R"
			cd "`wd'"
		}
		else {
			local Rpath "/usr/bin/R"
			capture confirm file "`Rpath'"
			if _rc!=0 {
				local Rpath "/usr/local/bin/R"
				capture confirm file "`Rpath'"
				if _rc!=0 {
					capture cd "/Library/Frameworks/R.framework/Resources/bin/"
					if _rc==0 {
							local Rpath "`c(pwd)'/R"
					}
					else {
						noisily mata: printf("{cmd:importsav.ado}{text} could not find R in expected directories\n...will depend on the PATH environment variable\n")
						local Rpath R
						local Renv on
					}
					cd "`wd'"
				}
			}
		}
	}

	if "`Renv'"=="on" {
		local Renv : environ PATH
		if "`c(os)'"=="Windows" {
			tokenize `Renv' , p(";")
			local i=1
			while "``i''"!="" {
				if strmatch("``i''","*\R*")==1 {
					local Rpath "``i''"
					local Renv off
				}
				local i=`i'+1
			}
			local Rpath "`Rpath'\R"
		}
		else {
			tokenize `Renv' , p(":")
			local i=1
			while "``i''"!="" {
				if strmatch("``i''","*/R")==1 {
					local Rpath "``i''"
					local Renv off
				}
				local i=`i'+1
			}
		}
		if "`Renv'"=="on" {
			noisily mata: printf("{cmd:importsav.ado}{error} could not find R on your system\n")
			exit 601
		}
	}

	global Rpath "`Rpath'"

}

end

program importsav
	version 10
	syntax anything [ , locale(string)]

quietly {

	noisily findr

	if "`1'"=="haven" {
		capture importsav_`0'
		if _rc==0 {
			noisily mata: printf("{text}your data was successfully converted using {cmd:haven}\n")
			exit
		}
		else {
			noisily mata: printf("{error}your data could not be converted using {cmd:haven}\n")
			exit 601
		}
	}
	else if "`1'"=="foreign" {
		capture importsav_`0'
		if _rc==0 {
			noisily mata: printf("{text}your data was successfully converted using {cmd:foreign}\n")
			exit
		}
		else {
			noisily mata: printf("{error}your data could not be converted using {cmd:foreign}\n")
			exit 601
		}
	}
	else {
		capture importsav_haven `0'
		if _rc==0 {
			noisily mata: printf("{text}your data was successfully converted using {cmd:haven}\n")
		}
		else {
			noisily mata: printf("{cmd:haven}{text} has failed to convert your data\n{cmd:importsav.ado}{text} is trying to use {cmd:foreign}...\n")
			capture importsav_foreign `0'
			if _rc==0 {
				noisily mata: printf("{text}your data was successfully converted using {cmd:foreign}\n")
			}
			else {
				noisily mata: printf("{cmd:foreign}{text} has failed to convert your data\n{error}your data could not be converted using R packages\n")
				exit 601
			}
		}
	exit
	}

}

end

program importsav_haven
	version 10
	syntax anything [ , locale(string)]
	args spssfile statafile

quietly {

	if "`statafile'"=="" {
		local statafile "`spssfile'"
	}
	local spssfile=subinstr("`spssfile'", "\", "/", .)
	local statafile=subinstr("`statafile'", "\", "/", .)

	local dir `c(pwd)'
	local fws_dir=subinstr("`dir'", "\", "/", .)

	local sourcefile=round(runiform()*1000)
	capture file clse rsource
	file open rsource using `sourcefile'.R, write text replace

	file write rsource `"if (!require(haven)) install.packages("haven", repos="https://cran.seoul.go.kr/"); library(haven)"' _n
	file write rsource `""' _n
	file write rsource `"setwd("`fws_dir'")"' _n
	if "`locale'"=="NA" | "`locale'"=="na" | "`locale'"=="NULL" | "`locale'"=="null" {
		local locale ""
	}
	if "`locale'"!="" {
		file write rsource `"data <- read_sav("`spssfile'.sav", encoding='`locale'')"' _n
	}
	else {
		file write rsource `"data <- read_sav("`spssfile'.sav")"' _n
	}
	file write rsource `"write_dta(data, "temporary_`sourcefile'.dta")"' _n
	file write rsource `"data2 <- read_dta("temporary_`sourcefile'.dta")"' _n
	file write rsource `"attr(data2, "var.labels") <- attr(data, "variable.labels")"' _n
	file write rsource `"write_dta(data2, "`statafile'.dta")"' _n

	file close rsource
	shell "$Rpath" --vanilla <`sourcefile'.R
	erase `sourcefile'.R
	erase "temporary_`sourcefile'.dta"
	use "`statafile'", clear

}

end

program importsav_foreign
	version 10
	syntax anything [ , locale(string)]
	args spssfile statafile

quietly {

	if "`statafile'"=="" {
		local statafile "`spssfile'"
	}
	local spssfile=subinstr("`spssfile'", "\", "/", .)
	local statafile=subinstr("`statafile'", "\", "/", .)

	local dir `c(pwd)'
	local fws_dir=subinstr("`dir'", "\", "/", .)

	local sourcefile=round(runiform()*1000)
	capture file clse rsource
	file open rsource using `sourcefile'.R, write text replace

	file write rsource `"library(foreign)"' _n
	file write rsource `""' _n
	file write rsource `"setwd("`fws_dir'")"' _n
	if "`locale'"=="NA" | "`locale'"=="na" | "`locale'"=="NULL" | "`locale'"=="null" {
		local locale ""
	}
	if "`locale'"!="" {
		file write rsource `"data <- read.spss("`spssfile'.sav", reencode='`locale'', to.data.frame=TRUE)"' _n
	}
	else {
		file write rsource `"data <- read.spss("`spssfile'.sav", to.data.frame=TRUE)"' _n
	}
	file write rsource `"write.dta(data, "temporary_`sourcefile'.dta")"' _n
	file write rsource `"data2 <- read.dta("temporary_`sourcefile'.dta")"' _n
	file write rsource `"attr(data2, "var.labels") <- attr(data, "variable.labels")"' _n
	file write rsource `"write.dta(data2, "`statafile'.dta")"' _n

	file close rsource
	shell "$Rpath" --vanilla <`sourcefile'.R
	erase `sourcefile'.R
	erase "temporary_`sourcefile'.dta"
	use "`statafile'", clear

}

end
