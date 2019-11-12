# `importsav`

**Program to convert SPSS file to Stata (requires R)**

`importsav` converts SPSS file to Stata with the help of R packages--[haven][1] and [foreign][2]. Thus, in order to use `importsav`, you need to install [R][3] on your system first. But after that, you really have no need of running R at all.

[1]: <https://www.rdocumentation.org/packages/haven/versions/2.2.0>
[2]: <https://www.rdocumentation.org/packages/foreign/versions/0.8-72>
[3]: <https://cran.r-project.org/>

The essential idea underlying `importsav` is *not to interrupt* your workflow within Stata. With this command, you don’t need to escape Stata for data conversion.

This is how `importsav` works: if you typed the command properly, `importsav` stores file names and path in Stata’s macros, writes R code using information contained in those macros and then sends that R code to R console through Stata’s `shell` command.

`importsav` depends on `haven` and `foreign` to support non-English labels. Since `foreign` truncates variable labels exceeding a certain length, by default `importsav` tries `haven` first and then `foreign` only if `haven` didn’t work. But using a subcommand `importsav foreign`, it is also possible to try `foreign` first regardless of the malfunction of `haven`.

For this program to work, hence, `importsav` must ascertain location of R on your system. To identify where R is installed, the program depends on three different algorithms: (1) using SSC package [whereis][4]; (2) searching expected directories similar to github package [rcall][5]’s behavior; (3) chekcing the `PATH environment variable`. If all three fail to find location of R, `importsav` will cease to proceed. In this case, you can set the R path manually using the `whereis` command or the `setr` command (the latter is Windows-only).

[4]: <https://ideas.repec.org/c/boc/bocode/s458303.html>
[5]: <https://github.com/haghish/rcall/>

`setr` is a subcommand of `importsav` which also utilizes Stata’s `shell` command to add R to your `PATH environment variable` without escaping Stata. It only works in Windows and you must `run Stata as Administrator` when using `setr`.


## Installation

You can install `importsav` using either Stata’s `net install` command or user-written package [github][8].
```
    net from https://raw.githubusercontent.com/jh-min/importsav/master
    github install jh-min/importsav
```

[8]: <https://github.com/haghish/github>


## Syntax

```
    importsav filename1 [ filename2 ]
    importsav [ foreign | haven ] filename1 [ filename2 ]
    setr x.y.z
```
> where `x.y.z` is the version of R installed on your system.

An important limitation of `importsav` is that it is not able to convert a file with *non-English characters in path*. The source of this problem lies in R itself and currently there is no credible solution. You should check your `current working directory` and `filename(s)`.

Note that `filename1` and `filename2` should not include any file extension, i.e., those should not end in .dta or .sav. If you omit `filename2` then it will be automatically set identical to `filename1`.


## Examples

```
    importsav dataname
```
> With this command, you will get `dataname.dta` from `dataname.sav`.

```
    importsav spssfile statafile
```
> With this command, you will get `statafile.dta` from `spssfile.sav`.

```
    importsav "spss file" statafile
```
> With this command, you will get `statafile.dta` from `spss file.sav`.

```
    importsav spssfile "C:\Data\stata file"
```
> With this command, you will get `stata file.dta` in `C:\Data` from `spssfile.sav` in the `current working directory`.

```
    importsav "C:\Data\spss file" "stata file"
```
> With this command, you will get `stata file.dta` in the `current working directory` from `spss file.sav` in `C:\Data`.

```
    importsav foreign "spss data" stata_data
```
> With this command, you will get `stata_data.dta` from `spss data.sav` using R package `foreign`.

```
    setr 3.6.1
```
> With this command, you will add R version 3.6.1 to your `PATH environment variable`.


## Author

[JeongHoon Min][7], Sogang University, plus1@sogang.ac.kr

[7]: <https://jhmin.weebly.com>


## Acknowledgement

This program owes a lot to [importspss][6] by Gabriel Rossman, [whereis][4] by Germán Rodríguez and [rcall][5] by E. F. Haghish. The author is grateful for their informative programs.

[6]: <https://codeandculture.wordpress.com/2010/06/29/importspss-ado-requires-r/>
