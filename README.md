# `importsav`

**Program to convert SPSS file to Stata (requires R)**

`importsav` converts SPSS file to Stata with the help of R packages--[haven][1], [foreign][2] and [bit64][9]. Thus, in order to use `importsav`, you need to install [R][3] on your system first. But after that, there is no need of running R at all.

[1]: <https://www.rdocumentation.org/packages/haven/versions/2.2.0>
[2]: <https://www.rdocumentation.org/packages/foreign/versions/0.8-72>
[3]: <https://cran.r-project.org/>
[9]: <https://www.rdocumentation.org/packages/bit64>

The essential idea underlying `importsav` is *not to interrupt* your workflow within Stata. With this command, you don’t need to escape Stata for data conversion. `importsav` will automatically write and execute R code for you.

This is how `importsav` works: if you typed the command properly, `importsav` stores file name(s) and path in Stata’s macros, writes R code using information contained in those macros and then sends that R code to R console through Stata’s `shell` command.

`importsav` depends on `haven` and `foreign` to support non-English labels. Since `foreign` truncates variable labels exceeding a certain length, by default `importsav` tries `haven` first and then `foreign` only if `haven` didn’t work. But using a subcommand `importsav foreign`, it is also possible to try `foreign` first regardless of the malfunction of `haven`.

For this program to work, hence, `importsav` must ascertain location of R on your system. To identify where R is installed, the program depends on three different algorithms: (1) using SSC package [whereis][4]; (2) searching expected directories similar to github package [rcall][5]’s behavior; (3) chekcing the `PATH environment variable`. If all three fail to find location of R, `importsav` will cease to proceed. In this case, you can set the R path manually using the `whereis` command.

[4]: <https://ideas.repec.org/c/boc/bocode/s458303.html>
[5]: <https://github.com/haghish/rcall/>

An important limitation of `importsav` is that it is not able to convert a file with *non-English characters in path*. The source of this problem lies in R itself and currently there is no credible solution. You should check your `current working directory` and `filename(s)`.

### Known issue(s)

- (Windows) If `importsav` hangs after invoking R console within the shell, please re-run Stata `as Administrator`.


## Installation

You can install the latest version of `importsav` using either Stata’s `net install` command or user-written package [github][8].
```
net from https://raw.githubusercontent.com/jh-min/importsav/master
github install jh-min/importsav
```

<!-- Current version of `importsav` is *not* available on SSC archive yet, it will be soon updated. -->

Current version of `importsav` is also available on SSC archive.
```
ssc install importsav , replace
```
> version 3.0.5, Distribution-Date: 20200725

[8]: <https://github.com/haghish/github>


## Syntax

```
importsav filename1 [ filename2 ] [, options]
importsav [ foreign | haven ] filename1 [ filename2 ] [, options]
```
> where `filename2` will be automatically set identical to `filename1` if omitted.

otpions | Description
---|:---
***e****ncoding*(*string*) | set which encoding to be used when reading SPSS file via `haven`
***r****eencode*(*string*) | set which encoding to be used when reading SPSS file via `foreign`
***u****nicode*(*string*) | set which encoding to be used when translating from extended ASCII after `foreign`
***c****ompress*(#) | set the reference size for compression (unit: `megabyte`, default value: `256`)
***off****default* | force `importsav` not to compress the data

If `encoding(string)` is set, `importsav` will set option `encoding` of R function `haven::read_sav` using that `string`. If you specify `NULL` or `null`, it is identical not to use `encoding(string)`

If `reencode(string)` is set, `importsav` will set option `reencode` of R function `foreign::read.spss` using that `string`; here, `reencode(string)` will be automatically set identical to `encoding(string)` if omitted. If you don’t want this fallback behaviour, specify `NA` or `na` in `reencode(string)`.

If `unicode(string)` is set and your version of Stata is newer than `13`, `importsav` will execute `unicode translate` using that `string` after R package `foreign` converted your data; here, `unicode(string)` will be automatically set identical to `reencode(string)` if omitted. If you don’t want this fallback behaviour, specify `off` in `unicode(string)`.

By default, `importsav` compresses your data when current file size is larger than `256MB`. You can manually adjust that criterion via `compress(#)`. If `offdefault` is set, the data will not be compressed in any cases.


## Requirements

You should install [R][3] on your system. If you have installed R on the location other than the default, you should add the location of R to [whereis][4] or `system environment variable`. In the latter case, say path to `R.exe` is `D:\R-3.6.2\bin\R.exe`, you need to add either `D:\R-3.6.2` to `R_HOME environment variable` (Windows-only) or `D:\R-3.6.2\bin\R.exe` to `PATH environment variable`.


## Examples

```stata
importsav dataname.sav
```

> With this command, you will get `dataname.dta` from `dataname.sav`.

```stata
importsav spssfile statafile , e("EUC-KR")
```

> With this command, you will get `statafile.dta` from `spssfile.sav` using encoding `EUC-KR` to read SPSS file.

```stata
importsav "spss file" statafile.dta , c(100)
```

> With this command, you will get `statafile.dta` from `spss file.sav` and your data will be compressed if the file size is larger than `100MB`.

```stata
importsav spssfile "C:\Data\stata file" , off
```

> With this command, you will get `stata file.dta` in `C:\Data` from `spssfile.sav` in the `current working directory` and your data will not be compressed even if the file size is larger than `256MB`.

```stata
importsav "C:\Data\spss file" "stata file" , c(100) off
```

> With this command, you will get `stata file.dta` in the `current working directory` from `spss file.sav` in `C:\Data` and your data will not be compressed even if the file size is larger than `100MB`.

```stata
importsav foreign "spss data" stata_data
```

> With this command, you will get `stata_data.dta` from `spss data.sav` using R package `foreign`.


## Author

[JeongHoon Min][7], Sogang University, plus1@sogang.ac.kr

[7]: <https://jhmin.weebly.com>


## Acknowledgement

This program owes a lot to [importspss][6] by Gabriel Rossman, [whereis][4] by Germán Rodríguez and [rcall][5] by E. F. Haghish. The author is grateful for their informative programs.

[6]: <https://codeandculture.wordpress.com/2010/06/29/importspss-ado-requires-r/>
