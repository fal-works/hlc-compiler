# hlc-compiler

Helps you compile HashLink/C code into executable using GCC.

## Comparison with HLCC

hlc-compiler is inspired by [HLCC](https://github.com/Yanrishatum/HLCC). Differences (as of July 2020):

||hlc-compiler|HLCC|
|---|---|---|
|C compiler|GCC (GNU Compiler Collection)|MS Visual Studio 2012 \| 2013 \| 2015|
|Install|`haxelib install hlc-compiler`|Fork repository and build|
|Preparation|-|Set several environment variables|
|Config|Any additional GCC option can be passed|-|
|Other|Can also save a Windows batch file for re-compile|-|


## Prerequisites

### Required Tools

- [HashLink](https://hashlink.haxe.org/)
- [GCC](https://gcc.gnu.org/)

### Development Environment

- Windows 10 64bit
- Haxe 4.1.1
- HashLink 1.11.0
- GCC 8.1.0 (MinGW-W64, via [scoop](https://scoop.sh/))


## Usage

First you have to output HashLink/C code, e.g. `haxe --main Main --hl out\c\main.c`.

Then call `haxelib run hlc-compiler` with some options described below.

### hlc-compiler Options

- `--srcDir [path]` Directory where your HashLink/C code (including `main.c` and `hlc.json`) are located.  
Defaults to `./` (current working directory).
- `--outFile [path]` File path of the output executable.  
Defaults to `./hlc_bin/main`.
- `--hlDir [path]` HashLink installation directory, or any directory that contains required `.lib`/`.hdll`/`.dll` files and `include` directory (which has `hlc_main.c` etc).  
At default, hlc-compiler tries to find it from your environment variables (`HASHLINKPATH`, `HASHLINK` or `HASHLINK_BIN`).
If not found, defaults to `./`.
- `--copyDlls` Automatically copies required `.hdll`/`.dll` files to output directory.  
Not set at default.
- `--exFiles [paths]` Additional files (comma-separated without spaces) to be passed to `gcc`.  
For instance you might have to pass `dbghelp.dll`.  
Not copied even if `--copyDlls` is set.
- `--exDlls [paths]`  Additional files (comma-separated without spaces) to be passed to `gcc`.  
Copied if `--copyDlls` is set.
- `--saveCmd [path]` File path where the `gcc` command should be saved as a Windows batch file (`.bat`).  
Not set (= does not save `.bat`) at default.
- `--verbose` Prints verbose logs.
- `(other)` Additionally you can pass any `gcc` options.  
For example `-O3` for highest optimization, `-w` to suppress warnings, or `-mwindows` for making a Windows GUI app.

File/directory paths can be either absolute or relative from the current working directory  
(internally all of them are converted to absolute).


## Usage Example

Assuming that you:

- have compiled your Haxe code with `haxe --main Main --hl out\c\main.c`
- installed HashLink in `C:\hashlink\1.11.0\`

Then an example would be:

```
haxelib run hlc-compiler --srcDir out\c --outFile bin\main --hlDir c:\hashlink\1.11.0\ --copyDlls --exFiles c:\Windows\System32\dbghelp.dll --saveCmd out\c\run_gcc.bat -w
```

This will:

- run `gcc` command so that your code is compiled into `bin\main.exe`
- copy required DLL files into `bin\`.
- save commands as `out\c\run_gcc.bat`.

The batch file looks like:

```Batchfile
@echo off

if not exist c:\yourDir\bin\ ^
mkdir c:\yourDir\bin\

echo Running GCC command...

gcc ^
-o c:\yourDir\bin\main ^
-I c:\hashlink\1.11.0\include\ ^
-I c:\yourDir\out\c\ ^
-w ^
c:\yourDir\out\c\main.c ^
c:\Windows\System32\dbghelp.dll ^
c:\hashlink\1.11.0\libhl.lib

echo Copying DLL files...

copy c:\hashlink\1.11.0\libhl.dll c:\yourDir\bin\ > nul

echo Completed.
```

It depends on your `hlc.json` which library files are required.


## Library Dependencies

- [sinker](https://github.com/fal-works/sinker) v0.2.0 or compatible
- [locator](https://github.com/fal-works/banker) v0.3.0 or compatible

See also:
[FAL Haxe libraries](https://github.com/fal-works/fal-haxe-libraries)


## Something other

[hlc-compiler wiki](https://github.com/fal-works/hlc-compiler/wiki)
