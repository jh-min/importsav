*** version 2.0.1 13November2019
*** contact information: plus1@sogang.ac.kr
*** a subcommand of importsav

program setr
	version 10
	args rversion

quietly {

	if regex("`rversion'", "[0-9]\.[0-9]\.[0-9]")!=1 | strlen("`rversion'")!=5 {
		di as err "type the version of R as in x.y.z format."
		exit 198
	}
	else {
		if "`c(os)'"=="Windows" {
			local rpath "C:\Program Files\R\R-`rversion'"
			shell setx R_HOME "`rpath'" -m
			if "`c(osdtl)'"=="64-bit" | "`c(bit)'"=="64" {
				shell setx path "%PATH%;%R_HOME%\bin\x64" -m
			}
			else {
				shell setx path "%PATH%;%R_HOME%\bin" -m
			}
			shell set
			local Renv : environ PATH
			if strmatch("`Renv'", "*%R_HOME%*")!=1 {
				noisily mata: printf("{cmd:setr.ado}{error} requires Stata to be run as Administrator\n")
				exit 791
			}
		}
		else {
			noisily mata: printf("{cmd:setr.ado}{error} only works in Windows\n")
			exit 198
		}
	}

}

end
