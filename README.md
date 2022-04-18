# hlc-compiler

Helps you compile HashLink/C code into executable.

Inspired by [HLCC](https://github.com/Yanrishatum/HLCC), but hlc-compiler uses GCC/Clang while HLCC uses MS Visual Studio.

See also <https://github.com/fal-works/hlc-compiler-sample> for an example using Heaps.io.


## Install

```console
haxelib install hlc-compiler
```


## Prerequisites

### Supported OS

- Windows
- Mac

### Required Tools

- [Haxe](https://haxe.org/) + [Haxelib](https://lib.haxe.org/)
- [HashLink](https://hashlink.haxe.org/)
- [GCC](https://gcc.gnu.org/) / [Clang](https://clang.llvm.org/) (on Windows, GCC is recommended)

### Development Environment

#### Windows

- Windows 10 64bit
- Haxe 4.2.5 + Haxelib 4.0.2
- HashLink 1.11.0
- GCC 11.2.0-9.0.0-r3 (via [scoop](https://scoop.sh/))

#### Mac

- macOS Catalina
- Haxe 4.1.1 + Haxelib 4.0.2
- HashLink 1.11.0 (via [homebrew](https://brew.sh/))
- Clang 10.0.1 / GCC 10.0.1


## Usage

First you have to output HashLink/C code, e.g. `haxe --main Main --hl out/c/main.c`.

For compiling the C code into executable, call `haxelib run hlc-compiler` with some options described below.

### hlc-compiler Options

Basically there is no "mandatory" options, however sometimes you might have to specify some options explicitly depending
 on your environment.

#### `--srcDir [path]`

Directory where your HashLink/C code (including `main.c` and `hlc.json`) are located.

Defaults to `./` (current working directory).

#### `--srcFile [path]`

File path to the `*.c` file to be compiled.

The path should be either absolute or relative from `--srcDir` directory.

Defaults to `main.c`.

#### `--hlcJsonFile [path]`

File path to the JSON file in your HashLink/C output.

This can be any JSON file that unifies `{ libs: Array<String> }` where `libs` is an array of required library names.

The path should be either absolute or relative from `--srcDir` directory.

Defaults to `hlc.json`.

#### `--outDir [path]`

Directory path of the output executable.

This will also the destination directory when copying files if `--copyRuntimeFiles` is specified.

- If not specified and `--outFile` is specified, `--outDir` defaults to the parent directory of `--outFile`.
- If both not specified, defaults to the current working directory.

*Note: hlc-compiler does not clean up old files/directories unless they are to be overwritten.*

#### `--outFile [path]` / `-o [path]`

File path of the output executable.

If `--outDir` is sepcified as well, `--outFile` should be either absolute or relative from `--outDir` directory.

Defaults to `./main`.

#### `--hlLibDir [path]`

Directory that contains required library files (`*.hdll` etc).

If not specified:

- On windows, hlc-compiler tries to find the HashLink installation directory from your environment variables (`HASHLINKPATH`, `HASHLINK` or `HASHLINK_BIN`) as it should contain the files in question.
- On Mac, defaults to `/usr/local/lib/` if it exists, as the library files are typically located here.
- If nothing found, defaults to `./` (current working directory).

#### `--hlIncludeDir [path]`

Directory that contains HashLink built-in files to be included (`.h`/`.c` files, such as `hlc.h`).

This will be passed to `gcc` as an `-I` option.

- On Windows: Defaults to directory named `include` in the `--hlLibDir` directory (because it should exist in the HashLink directory, to which `--hlLibDir` is typically set). `null` (will not be passed) if not found.
- On Mac: Defaults to `null`, as the files in question are typically located in `/usr/local/include/`, which is automaticaly searched by `gcc` at default.
- Alternatively you can set an environment variable `C_INCLUDE_PATH` to the path of this `include` directory so that it is automatically searched by `gcc` as well.
- If something goes wrong, try passing `-v` option and see which directories are searched by `gcc`.

#### `--copyRuntimeFiles`

Copies files that are required at runtime (such as dynamic linked libraries) to output directory.

Not set at default.

#### `--exFile [path]`

Additional file to be passed to `gcc` (for instance you might have to pass `dbghelp.dll`).

Can be specified multiple times. Not copied even if `--copyRuntimeFiles` is set.

#### `--runtime [path]`

Additional file or directory that should be copied if `--copyRuntimeFiles` is specified.

The path should be either absolute or relative from the current working directory.

Can be specified multiple times. No effect on compilation.

#### `--saveCmd [path]`

File path where `gcc` command line should be saved (as batch file on Windows, shell command file on Mac).

Not set (= does not save) at default.

If `--saveCmd` is given without any argument value, the file path defaults to `./compile-hlc.bat` or `./compile-hlc.command` in the current directory.

#### `--relative`

Tries to convert all file/directory paths to relative paths from the current working directory when building command lines.

#### `--compiler`

Allowed values: `gcc`, `clang`

The C compiler to use.

Defaults to `gcc` if Windows, `clang` if Mac.

#### `--verbose`

Prints verbose logs of hlc-compiler.

#### `(other)`

If using GCC, you can pass any [gcc option](https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html).  
(If Clang, most options should be the same but I'm not sure)

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

```console
haxelib run hlc-compiler --srcDir out\c --outFile bin\main --hlLibDir c:\hashlink\1.11.0\ --copyRuntimeFiles --exFile c:\Windows\System32\dbghelp.dll --saveCmd out\c\run_gcc.bat -w
```

This will:

- run `gcc` command so that your code is compiled into `bin\main.exe`
- copy files that are required at runtime into `bin\`.
- save commands as `out\c\run_gcc.bat`.

The batch file looks like:

```Batchfile
@echo off

if not exist c:\yourDir\bin\ ^
mkdir c:\yourDir\bin\

echo Compiling...

gcc ^
-o c:\yourDir\bin\main ^
-I c:\hashlink\1.11.0\include\ ^
-I c:\yourDir\out\c\ ^
-w ^
-std=c11 ^
c:\yourDir\out\c\main.c ^
c:\Windows\System32\dbghelp.dll ^
c:\hashlink\1.11.0\libhl.lib

echo Copying runtime files...

copy c:\hashlink\1.11.0\libhl.dll c:\yourDir\bin\ > nul

echo Completed.
```

It depends on your `hlc.json` which library files are required.


## Library Dependencies

- [sinker](https://github.com/fal-works/sinker) v0.6.0 or compatible
- [greeter](https://github.com/fal-works/greeter) v0.1.0 or compatible
- [locator](https://github.com/fal-works/banker) v0.5.0 or compatible

See also:
[FAL Haxe libraries](https://github.com/fal-works/fal-haxe-libraries)


## Something other

[hlc-compiler wiki](https://github.com/fal-works/hlc-compiler/wiki)
