*** version 2.0.1 13November2019
*** contact information: plus1@sogang.ac.kr
*** a subcommand of importsav

program setr
	version 10
	args Rversion

quietly {

	if "`c(os)'"=="Windows" {
		if regex("`Rversion'", "[0-9]\.[0-9]\.[0-9]")!=1 | strlen("`Rversion'")!=5 {
			di as err "type the version of R as in x.y.z format"
			exit 198
		}
		else {
			local Renv : environ PATH
			if strmatch("`Renv'", "*\R\R-*")==1 | strmatch("`Renv'", "*R_HOME*")==1 {
				noisily di as txt "R is already defined in your PATH environment variable"
				exit
			}
			else {
				local rpath "C:\Program Files\R\R-`Rversion'"
				shell setx R_HOME "`rpath'" -m
				if "`c(osdtl)'"=="64-bit" | "`c(bit)'"=="64" {
					shell setx path "%R_HOME%\bin\x64;%PATH%" -m
				}
				else {
					shell setx path "%R_HOME%\bin;%PATH%" -m
				}
				shell set
				shell path
				local Renv : environ R_HOME
				if "`Renv'"=="" {
					noisily mata: printf("{cmd:setr.ado}{error} requires Stata to be run as Administrator\n")
					noisily di as err "if you get this message while running Stata as Administrator, restart Stata and try again"
					exit 791
				}
				else {
					noisily di as txt "R is now defined in your PATH environment variable"
				}
			}
		}
	}
	else {
		noisily mata: printf("{cmd:setr.ado}{error} only works in Windows\n")
		exit 198
	}

}

end
