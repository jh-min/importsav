*** version 2.1.1 25November2019
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

program rrepos
	version 10

quietly {

	if strmatch("`c(locale_icudflt)'", "zh*")==1 {
		local Rrepos "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"
	}
	else if strmatch("`c(locale_icudflt)'", "ja*")==1 {
		local Rrepos "https://cran.ism.ac.jp/"
	}
	else if strmatch("`c(locale_icudflt)'", "ko*")==1 & strmatch("`c(locale_icudflt)'", "kok*")!=1 {
		local Rrepos "https://cran.seoul.go.kr/"
	}
	else if strmatch("`c(locale_icudflt)'", "es*")==1 {
		local Rrepos "http://mirror.fcaglp.unlp.edu.ar/CRAN/"
	}
	else if strmatch("`c(locale_icudflt)'", "sv*")==1 {
		local Rrepos "https://ftp.acc.umu.se/mirror/CRAN/"
	}
	else {
		local Rrepos "https://cloud.r-project.org/"
	}

	global Rrepos "`Rrepos'"

}

end

program getdataname
	version 10

quietly {

	local dataname "`c(filename)'"
	tokenize "`dataname'" , p("/")
	local i=1
	while "``i''"!="" {
		if strmatch("``i''", "*.dta")==1 {
			local dataname "``i''"
		}
		local i=`i'+1
	}
	global dataname "`dataname'"

}

end

program importsav
	version 10
	syntax anything [, locale(string) Compress(numlist max=1) OFFdefault]

quietly {

	noisily findr

	if "`1'"=="haven" & "`2'"!="" {
		capture importsav_`0'
		if _rc==0 {
			getdataname
			noisily mata: printf("{result}$dataname{text} was successfully converted using {cmd:haven}\n")
			if "`offdefault'"!="" {
				exit
			}
			memory
			return list , all
			local toobigfile r(data_data_u)
			if "`compress'"!="" {
				local compress=`compress'*1024*1024
				if `toobigfile' > `compress' {
					noisily di "please wait until compression is done..."
					compress , nocoalesce
					save , replace
					noisily mata: printf("{text}file {result}$dataname{text} saved\n")
				}
			}
			else {
				if `toobigfile' > 268435456 {
					noisily di "please wait until compression is done..."
					compress , nocoalesce
					save , replace
					noisily mata: printf("{text}file {result}$dataname{text} saved\n")
				}
			}
			exit
		}
		else {
			noisily mata: printf("{error}your data could not be converted using {cmd:haven}\n")
			exit 601
		}
	}
	else if "`1'"=="foreign" & "`2'"!="" {
		capture importsav_`0'
		if _rc==0 {
			getdataname
			noisily mata: printf("{result}$dataname{text} was successfully converted using {cmd:foreign}\n")
			if "`offdefault'"!="" {
				exit
			}
			memory
			return list , all
			local toobigfile r(data_data_u)
			if "`compress'"!="" {
				local compress=`compress'*1024*1024
				if `toobigfile' > `compress' {
					noisily di "please wait until compression is done..."
					compress , nocoalesce
					save , replace
					noisily mata: printf("{text}file {result}$dataname{text} saved\n")
				}				
			}
			else {
				if `toobigfile' > 268435456 {
					noisily di "please wait until compression is done..."
					compress , nocoalesce
					save , replace
					noisily mata: printf("{text}file {result}$dataname{text} saved\n")
				}
			}
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
			getdataname
			noisily mata: printf("{result}$dataname{text} was successfully converted using {cmd:haven}\n")
			if "`offdefault'"!="" {
				exit
			}
			memory
			return list , all
			local toobigfile r(data_data_u)
			if "`compress'"!="" {
				local compress=`compress'*1024*1024
				if `toobigfile' > `compress' {
					noisily di "please wait until compression is done..."
					compress , nocoalesce
					save , replace
					noisily mata: printf("{text}file {result}$dataname{text} saved\n")
				}
			}
			else {
				if `toobigfile' > 268435456 {
					noisily di "please wait until compression is done..."
					compress , nocoalesce
					save , replace
					noisily mata: printf("{text}file {result}$dataname{text} saved\n")
				}
			}
			exit
		}
		else {
			noisily mata: printf("{cmd:haven}{text} has failed to convert your data\n{cmd:importsav.ado}{text} is trying to use {cmd:foreign}...\n")
			capture importsav_foreign `0'
			if _rc==0 {
				getdataname
				noisily mata: printf("{result}$dataname{text} was successfully converted using {cmd:foreign}\n")
				if "`offdefault'"!="" {
					exit
				}
				memory
				return list , all
				local toobigfile r(data_data_u)
				if "`compress'"!="" {
					local compress=`compress'*1024*1024
					if `toobigfile' > `compress' {
						noisily di "please wait until compression is done..."
						compress , nocoalesce
						save , replace
						noisily mata: printf("{text}file {result}$dataname{text} saved\n")
					}
				}
				else {
					if `toobigfile' > 268435456 {
						noisily di "please wait until compression is done..."
						compress , nocoalesce
						save , replace
						noisily mata: printf("{text}file {result}$dataname{text} saved\n")
					}
				}
				exit
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
	syntax anything [, locale(string) Compress(numlist max=1) OFFdefault]

quietly {

	if "`locale'"=="" & "`compress'"=="" & "`offdefault'"=="" {
		local spssfile "`1'"
		local statafile "`2'"
	}
	else {
		tokenize `"`0'"' , p(",")
		if "`2'"=="," {
			if strpos(`"`0'"', `"""')==0 {
				tokenize "`1'"
			}
			else if strmatch(`"`1'"', `""*"*"')!=0 | strmatch(`"`1'"', `"*"*"')!=0 {
				tokenize `"`1'"'
			}
		}
		if strmatch("`2'", "* ")==1 {
			local 2=substr("`2'", 1, strlen("`2'")-1)
		}
		else if strmatch("`1'", "* ")==1 {
			local 1=substr("`1'", 1, strlen("`1'")-1)
		}
		local spssfile "`1'"
		local statafile "`2'"
	}

	if "`statafile'"=="" | strmatch("`statafile'", ",*")==1 {
		local statafile "`spssfile'"
		if strmatch("`statafile'", "*.sav")==1 {
			local statafile=substr("`statafile'", 1, strlen("`statafile'")-4)
		}
	}
	local spssfile=subinstr("`spssfile'", "\", "/", .)
	local statafile=subinstr("`statafile'", "\", "/", .)
	if strmatch("`spssfile'", "*.sav")!=1 {
		local spssfile "`spssfile'.sav"
	}
	if strmatch("`statafile'", "*.dta")!=1 {
		local statafile "`statafile'.dta"
	}

	local dir `c(pwd)'
	local fws_dir=subinstr("`dir'", "\", "/", .)

	local sourcefile=round(runiform()*1000)
	capture file clse rsource
	file open rsource using `sourcefile'.R, write text replace

	rrepos
	file write rsource `"if (!require(haven)) install.packages("haven", repos="$Rrepos"); library(haven)"' _n
	file write rsource `""' _n
	file write rsource `"setwd("`fws_dir'")"' _n
	if "`locale'"=="NA" | "`locale'"=="na" | "`locale'"=="NULL" | "`locale'"=="null" {
		local locale ""
	}
	if "`locale'"!="" {
		file write rsource `"data<-read_sav("`spssfile'", encoding='`locale'')"' _n
	}
	else {
		file write rsource `"data<-read_sav("`spssfile'")"' _n
	}
	file write rsource `"data2<-data"' _n
	file write rsource `"n<-1"' _n
	file write rsource `"while (n<length(data)+1) {"' _n
	file write rsource `"	if (is.numeric(data[[n]])==TRUE) {"' _n
	file write rsource `"		if (max(data2[[n]], na.rm=TRUE)>=2147483647) {"' _n
	file write rsource `"			if (!require(bit64)) install.packages("bit64", repos="$Rrepos"); library(bit64)"' _n
	file write rsource `"			class(data2[[n]])<-NULL"' _n
	file write rsource `"			data2[[n]]<-as.integer64(data2[[n]])"' _n
	file write rsource `"			attr(data2[[n]], "label")<-attr(data[[n]], "label", exact=TRUE)"' _n
	file write rsource `"		}"' _n
	file write rsource `"		else {"' _n
	file write rsource `"			if (all(data[[n]]==as.integer(data[[n]]), na.rm=TRUE)==FALSE) {"' _n
	file write rsource `"				data2[[n]]<-as.numeric(data[[n]])"' _n
	file write rsource `"				attr(data2[[n]], "label")<-attr(data[[n]], "label", exact=TRUE)"' _n
	file write rsource `"			}"' _n
	file write rsource `"		}"' _n
	file write rsource `"	}"' _n
	file write rsource `"	n<-n+1"' _n
	file write rsource `"}"' _n
	file write rsource `"write_dta(data2, "`statafile'")"' _n

	file close rsource
	shell "$Rpath" --vanilla <`sourcefile'.R
	erase `sourcefile'.R
	use "`statafile'", clear

}

end

program importsav_foreign
	version 10
	syntax anything [, locale(string) Compress(numlist max=1) OFFdefault]

quietly {

	if "`locale'"=="" & "`compress'"=="" & "`offdefault'"=="" {
		local spssfile "`1'"
		local statafile "`2'"
	}
	else {
		tokenize `"`0'"' , p(",")
		if "`2'"=="," {
			if strpos(`"`0'"', `"""')==0 {
				tokenize "`1'"
			}
			else if strmatch(`"`1'"', `""*"*"')!=0 | strmatch(`"`1'"', `"*"*"')!=0 {
				tokenize `"`1'"'
			}
		}
		if strmatch("`2'", "* ")==1 {
			local 2=substr("`2'", 1, strlen("`2'")-1)
		}
		else if strmatch("`1'", "* ")==1 {
			local 1=substr("`1'", 1, strlen("`1'")-1)
		}
		local spssfile "`1'"
		local statafile "`2'"
	}

	if "`statafile'"=="" | strmatch("`statafile'", ",*")==1 {
		local statafile "`spssfile'"
		if strmatch("`statafile'", "*.sav")==1 {
			local statafile=substr("`statafile'", 1, strlen("`statafile'")-4)
		}
	}
	local spssfile=subinstr("`spssfile'", "\", "/", .)
	local statafile=subinstr("`statafile'", "\", "/", .)
	if strmatch("`spssfile'", "*.sav")!=1 {
		local spssfile "`spssfile'.sav"
	}
	if strmatch("`statafile'", "*.dta")!=1 {
		local statafile "`statafile'.dta"
	}

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
		file write rsource `"data<-read.spss("`spssfile'", reencode='`locale'', to.data.frame=TRUE)"' _n
	}
	else {
		file write rsource `"data<-read.spss("`spssfile'", to.data.frame=TRUE)"' _n
	}
	file write rsource `"write.dta(data, "temporary_`sourcefile'.dta")"' _n
	file write rsource `"data2<-read.dta("temporary_`sourcefile'.dta")"' _n
	file write rsource `"attr(data2, "var.labels")<-attr(data, "variable.labels")"' _n
	file write rsource `"write.dta(data2, "`statafile'")"' _n

	file close rsource
	shell "$Rpath" --vanilla <`sourcefile'.R
	erase `sourcefile'.R
	erase "temporary_`sourcefile'.dta"
	use "`statafile'", clear

}

end
