*** version 1.3 7November2019
*** contact information: plus1@sogang.ac.kr
*** subcommand of importsav

program setr
	version 10
	args rversion

quietly {

	if regex("`rversion'", "[0-9]\.[0-9]\.[0-9]")!=1 | strlen("`rversion'")!=5 {
		di as err "Type the version of R as in x.y.z format."
		exit 198
	}
	else {
		if "`c(os)'"=="Windows" {
			local rpath "C:\Program Files\R\R-`rversion'"
			shell setx R_HOME "`rpath'" -m
			if "`c(osdtl)'"=="64-bit" {
				shell setx path "%PATH%;%R_HOME%\bin\x64" -m
			}
			else {
				shell setx path "%PATH%;%R_HOME%\bin" -m
			}
			shell set
		}
	}

}

end
