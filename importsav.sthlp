{smcl}
{* *! version 2.0  11November2019}{...}

{title:Title}

{phang}{bf:importsav} {hline 2} Program to convert SPSS file to Stata (requires R)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
	{cmd:importsav} {it:filename1} [ {it:filename2} ]

{p 8 17 2}
	{cmd:importsav} [ foreign | haven ] {it:filename1} [ {it:filename2} ]

{p 8 17 2}
	{cmd:setr} {it:x.y.z}

{pmore2}
	where {it:x.y.z} is the version of {cmd:R} installed on your system.


{marker description}{...}
{title:Description}

{pstd}
	{cmd:importsav} converts {cmd:SPSS} file to {cmd:Stata} with the help of {cmd:R} packages--{browse "https://www.rdocumentation.org/packages/haven/":haven} and {browse "https://www.rdocumentation.org/packages/foreign":foreign}.
	Thus, in order to use {cmd:importsav}, you need to install {browse "https://cran.r-project.org/":R} on your system first.
	But after that, you really have no need of running {cmd:R} at all.

{pstd}
	The essential idea underlying {cmd:importsav} is {it:not to interrupt} your workflow within {cmd:Stata}.
	With this command, you don’t need to escape {cmd:Stata} for data conversion.

{pstd}
	This is how {cmd:importsav} works: if you typed the command properly,
	{cmd:importsav} stores file names and path in {cmd:Stata}’s macros,
	writes {cmd:R} code using information contained in those macros
	and then sends that {cmd:R} code to {cmd:R} console through {cmd:Stata}’s {cmd:shell} command.

{pstd}
	{cmd:importsav} depends on {cmd:haven} and {cmd:foreign} to support non-English labels.
	Since {cmd:foreign} truncates variable labels exceeding a certain length, by default {cmd:importsav} tries {cmd:haven} first and then {cmd:foreign} only if {cmd:haven} didn’t work.
	But using a subcommand {cmd:importsav foreign}, it is also possible to try {cmd:foreign} first regardless of the malfunction of {cmd:haven}.

{pstd}
	For this program to work, hence, {cmd:importsav} must ascertain location of {cmd:R} on your system.
	To identify where {cmd:R} is installed, the program depends on three different algorithms:
	(1) using SSC package {search whereis};
	(2) searching expected directories similar to github package {browse "https://github.com/haghish/rcall/":rcall}’s behavior;
	(3) chekcing the {cmd:PATH environment variable}.
	If all three fail to find location of {cmd:R}, {cmd:importsav} will cease to proceed.
	In this case, you can set the {cmd:R} path manually using the {cmd:whereis} command or the {cmd:setr} command (the latter is {cmd:Windows}-only).

{pstd}
	{cmd:setr} is a subcommand of {cmd:importsav} which also utilizes {cmd:Stata}’s {cmd:shell} command to add {cmd:R} to your {cmd:PATH environment variable} without escaping {cmd:Stata}.
	It only works in {cmd:Windows} and you must {it:run {cmd:Stata} as Administrator} when using {cmd:setr}.

{pstd}
	An important limitation of {cmd:importsav} is that it is not able to convert a file with {it:non-English characters} in path.
	The source of this problem lies in {cmd:R} itself and currently there is no credible solution.
	You should check your {it:current working directory} and {it:filename(s)}.

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

{phang}{cmd:. importsav foreign "spss data" stata_data}{p_end}
{pmore}
	With this command, you will get {it:stata_data.dta} from {it:spss data.sav} using {cmd:R} package {cmd:foreign}.

{phang}{cmd:. setr 3.6.1}{p_end}
{pmore}
	With this command, you will add R version 3.6.1 to your {cmd:PATH environment variable}.


{marker author}{...}
{title:Author}

{pstd}
	{browse "https://jhmin.weebly.com":JeongHoon Min}, Sogang University, plus1@sogang.ac.kr


{marker acknowledgement}{...}
{title:Acknowledgement}

{pstd}
	This program owes a lot to {browse "https://codeandculture.wordpress.com/2010/06/29/importspss-ado-requires-r/":importspss} by Gabriel Rossman, {browse "https://ideas.repec.org/c/boc/bocode/s458303.html":whereis} by Germán Rodríguez and {browse "https://github.com/haghish/rcall/":rcall} by E. F. Haghish.
	The author is grateful for their informative programs.

