{smcl}
{* *! version 1.3  7November2019}{...}

{title:Title}

{phang}{bf:importsav} {hline 2} Program to convert SPSS file to Stata (requires R)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
	{cmd:importsav} {it:filename1} [{it:filename2}]

{p 8 17 2}
	{cmd:setr} {it:x.y.z}


{marker description}{...}
{title:Description}

{pstd}
	{cmd:importsav} converts {cmd:SPSS} file to {cmd:Stata} with the help of {cmd:R} package {cmd:haven} and {cmd:foreign}.
	In order to use {cmd:importsav}, you need to install {cmd:R} first.
	In {cmd:Windows}, you also need to manually add {cmd:R} to the {cmd:PATH environment}.
	You can set your {cmd:PATH environment} by the {cmd:setr} command where {it:x.y.z} is the version of {cmd:R} installed on your system.
	Note that you must run Stata {cmd:as Administrator} when using {cmd:setr}.

{pstd}
	Unfortunately, {cmd:importsav} is not able to convert a file with non-English characters in path; you should check your {it:current working directory} and {it:filename(s)}.

{pstd}
	Note that {it:filename1} and {it:filename2} should not include any file extension, i.e., those should not end in {it:.dta} or {it:.sav}.
	If you omit {it:filename2} then it will be automatically set identical to {it:filename1}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. importsav dataname}{p_end}
{pmore}
	With this command, you will get {it:dataname.dta} from {it:dataname.sav}.

{phang}{cmd:. importsav spssfile statafile}{p_end}
{pmore}
	With this command, you will get {it:statafile.dta} from {it:spssfile.sav}.

{phang}{cmd:. importsav "spss file" statafile}{p_end}
{pmore}
	With this command, you will get {it:statafile.dta} from {it:spss file.sav}.

{phang}{cmd:. importsav spssfile "C:\Data\stata file"}{p_end}
{pmore}
	With this command, you will get {it:stata file.dta} in {it:C:\Data} from {it:spssfile.sav} in the {it:current working directory}.

{phang}{cmd:. importsav "C:\Data\spss file" "stata file"}{p_end}
{pmore}
	With this command, you will get {it:stata file.dta} in the {it:current working directory} from {it:spss file.sav} in {it:C:\Data}.

{phang}{cmd:. setr 3.6.1}{p_end}
{pmore}
	With this command, you will add R version 3.6.1 to your {cmd:PATH environment}.


{marker author}{...}
{title:Author}

{pstd}
	{browse "https://jhmin.weebly.com":JeongHoon Min}, Sogang University, plus1@sogang.ac.kr

{pstd}
	This program is modified from {browse "https://codeandculture.wordpress.com/2010/06/29/importspss-ado-requires-r/"}.

