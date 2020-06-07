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

First you have to output HashLink/C code, e.g. `haxe --main Main --hl out/c/main.c`.

Then call `haxelib run hlc-compiler` with some options described below.

File/directory paths can be either absolute or relative from the current working directory  
(internally all of them are converted to absolute).

### hlc-compiler Options

#### `--srcDir [path]`

Directory where your HashLink/C code (including `main.c` and `hlc.json`) are located.  
Defaults to `./` (current working directory).

#### `--outFile [path]`

File path of the output executable.  
Defaults to `./hlc_bin/main`.

#### `--libDir [path]`

Directory that contains required library files (`*.hdll` etc).

- On windows, hlc-compiler tries to find the HashLink installation directory from your environment variables (`HASHLINKPATH`, `HASHLINK` or `HASHLINK_BIN`) as it should contain the files in question.  
- On Mac, defaults to `/usr/local/lib/` if it exists, as the library files are typically located here.
- If nothing found, defaults to `./` (current working directory).

#### `--includeDir [path]`

Directory that contains HashLink built-in files to be included (`.h`/`.c` files, such as `hlc.h`).  
This will be passed to `gcc` as an `-I` option.

- On Windows, defaults to directory named `include` in the `--libDir` directory (because it should exist in the HashLink directory, to which `--libDir` is typically set).  
- On Mac, defaults to `/usr/local/include/`, which is the path where the files in question are typically located and also automaticaly searched by `gcc` at default.
- Alternatively you can set an environment variable `C_INCLUDE_PATH` to the path of this `include` directory so that it is automatically searched by `gcc` as well.
- If something goes wrong, try passing `-v` option and see which directories are searched by `gcc`.

#### `--copyDlls`

Automatically copies required library files (`*.hdll` etc) to output directory.  
Not set at default.

#### `--exFiles [paths]`

Additional files (comma-separated without spaces) to be passed to `gcc`.  
For instance you might have to pass `dbghelp.dll`.  
Not copied even if `--copyDlls` is set.

#### `--exDlls [paths]`

Additional files (comma-separated without spaces) to be passed to `gcc`.  
Copied if `--copyDlls` is set.

#### `--saveCmd [path]`

(For Windows)  
File path where the `gcc` command should be saved as a Windows batch file (`.bat`).  
Not set (= does not save `.bat`) at default.

#### `--verbose`

Prints verbose logs of hlc-compiler.

#### `(other)`

You can pass any [gcc option](https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html).

If no `-std` option is provided, `-std=c11` is automatically added.

Other examples:

- `-O3` for highest optimization
- `-w` to suppress warnings
- `-v` to see more detailed logs of `gcc`
- `-mwindows` for making a Windows GUI app


## Usage Example

### Windows

Assuming that you:

- have compiled your Haxe code with `haxe --main Main --hl out\c\main.c`
- installed HashLink in `C:\hashlink\1.11.0\`

Then an example would be:

```
haxelib run hlc-compiler --srcDir out\c --outFile bin\main --libDir c:\hashlink\1.11.0\ --copyDlls --exFiles c:\Windows\System32\dbghelp.dll --saveCmd out\c\run_gcc.bat -w
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
-std=c11 ^
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
