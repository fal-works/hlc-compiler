package hlc_compiler.types;

import locator.DirectoryRef.fromStringCallback as toDir;
import locator.FileOrDirectoryRef.fromStringCallback as toFileOrDir;
import locator.FileRef.fromStringCallback as toFile;

/**
	Sanitized arguments for hlc-compiler, completed with default values.
	Converted from command line arguments.
**/
@:structInit
class Arguments {
	/**
		Validates file/directory paths and completes them with default values.
		@return Arguments in `Arguments` representation.
	**/
	public static function from(args: CommandArgumentSummary): Arguments {
		final currentDirectory = DirectoryRef.current();
		final options = args.optionValuesMap;

		if (options.exists("--version"))
			Common.showVersion(false, true);

		final srcDir = options.one("--srcDir").map(toDir).or(currentDirectory);
		final srcFile = srcDir.findFile(options.one("--srcFile").or("main.c"));
		final hlcJsonFile = srcDir.findFile(options.one("--hlcJsonFile").or("hlc.json"));

		final outDirOption = options.one("--outDir");
		final outFileOption = options.one("--outFile");
		final defaultOutFileName = srcFile.getNameWithoutExtension();
		var outDir: DirectoryPath;
		var outFile: FilePath;
		switch outDirOption.toOption() {
			case Some(outDirStr):
				outDir = DirectoryPath.from(outDirStr);
				outFile = outDir.makeFilePath(outFileOption.or(defaultOutFileName));
			case None:
				switch outFileOption.toOption() {
					case Some(outFileStr):
						outFile = FilePath.from(outFileStr);
						outDir = outFile.getParentPath();
					case None:
						outDir = currentDirectory.path;
						outFile = outDir.makeFilePath(defaultOutFileName);
				}
		}

		final hlLibDir = options.one("--hlLibDir")
			.map(toDir)
			.orElse(() -> CommandOptions.suggestHashLinkLibraryDirectory()
				.or(currentDirectory));

		final hlIncludeDir = options.one("--hlIncludeDir")
			.map(toDir)
			.coalesceWith(() -> CommandOptions.suggestHashLinkIncludeDirectory(hlLibDir));

		final copyRuntimeFiles = options.exists("--copyRuntimeFiles");
		final exFiles = options.oneOrMore("--exFile").or([]).map(toFile);
		final runtime = options.oneOrMore("--runtime").or([]).map(toFileOrDir);
		final saveCmdPath = options.zeroOrOne("--saveCmd").map(path -> switch path {
			case Zero: FilePath.from("./compile_hlc");
			case One(relPath): FilePath.from(relPath);
		});
		final relative = options.exists("--relative");
		final compiler = options.one("--compiler")
			.map(validateCompiler)
			.orElse(() -> switch Environment.systemType {
				case Windows: Gcc;
				case Mac: Clang;
			});
		final verbose = options.exists("--verbose");

		final exOptions: Array<String> = [];

		final hlcCompilerOptionSet = CommandOptions.set;
		for (option in options.keys())
			if (!hlcCompilerOptionSet.has(option)) exOptions.push(option.toString());

		final arguments: Arguments = {
			srcDir: srcDir,
			srcFile: srcFile,
			hlcJsonFile: hlcJsonFile,
			outDir: outDir,
			outFile: outFile,
			hlLibDir: hlLibDir,
			hlIncludeDir: hlIncludeDir,
			copyRuntimeFiles: copyRuntimeFiles,
			exFiles: exFiles,
			runtime: runtime,
			exOptions: exOptions,
			saveCmdPath: saveCmdPath,
			relative: relative,
			compiler: compiler,
			verbose: verbose
		};

		if (verbose) {
			Sys.println('Set $currentDirectory as current directory.\n');
			Sys.println('Sanitized arguments:\n${arguments.format("  ")}\n');
		}

		return arguments;
	}

	static function validateCompiler(compilerStr: String): CCompiler {
		return switch compilerStr.toLowerCase() {
			case "gcc": Gcc;
			case "clang": Clang;
			default: throw 'C compiler should be either gcc or clang. Specified unknown compiler: $compilerStr';
		}
	}

	/**
		Directory containing `main.c` and `hlc.json`.
	**/
	public final srcDir: DirectoryRef;

	/**
		Source `*.c` file.
	**/
	public final srcFile: FileRef;

	/**
		`hlc.json` in the HL/C source directory.
	**/
	public final hlcJsonFile: FileRef;

	/**
		Output file path.
	**/
	public final outFile: FilePath;

	/**
		Output directory path.
	**/
	public final outDir: DirectoryPath;

	/**
		Directory containing `*.hdll` and other library files bundled with HashLink.
	**/
	public final hlLibDir: DirectoryRef;

	/**
		Directory containing HL files to be included (such as `hlc.h`).
		Is not mandatory because the directory may be automatically searched by `gcc` (especially if not Windows).
	**/
	public final hlIncludeDir: Maybe<DirectoryRef>;

	/**
		`true` if files that are required at runtime should be copied to the output directory.
	**/
	public final copyRuntimeFiles: Bool;

	/**
		Additional files that should be passed to GCC.
		These are not copied to the destination directory.
	**/
	public final exFiles: Array<FileRef>;

	/**
		Additional files that should be copied if `--copyRuntimeFiles` is specified.
		No effect on compilation.
	**/
	public final runtime: FileOrDirectoryList;

	/**
		Additional options that should be passed to GCC.
	**/
	public final exOptions: Array<String>;

	/**
		The file path where the command should be saved.
		Does not emit file if `null`.
	**/
	public final saveCmdPath: Maybe<FilePath>;

	/**
		`true` if file/directory paths should be converted to relative paths when creating commands lines.
	**/
	public final relative: Bool;

	/**
		C compiler to use. Either `gcc` or `clang`.
	**/
	public final compiler: CCompiler;

	/**
		`true` if verbose logging should be enabled.
	**/
	public final verbose: Bool;

	/**
		Formats `this`.
	**/
	public inline function format(indent = ""): String {
		var s = "";
		s += '${indent}srcDir:           ${this.srcDir.toString()}\n';
		s += '${indent}srcFile:          ${this.srcFile.toString()}\n';
		s += '${indent}hlcJsonFile:      ${this.hlcJsonFile.toString()}\n';
		s += '${indent}outDir:           ${this.outDir.toString()}\n';
		s += '${indent}outFile:          ${this.outFile.toString()}\n';
		s += '${indent}hlLibDir:         ${this.hlLibDir.toString()}\n';
		s += '${indent}hlIncludeDir:     ${this.hlIncludeDir.toString()}\n';
		s += '${indent}copyRuntimeFiles: ${this.copyRuntimeFiles}\n';
		s += '${indent}exFiles:          ${this.exFiles.toString()}\n';
		s += '${indent}runtime:          ${this.runtime.toString()}\n';
		s += '${indent}exOptions:        ${this.exOptions.toString()}\n';
		s += '${indent}saveCmd:          ${this.saveCmdPath.toString()}';
		return s;
	}

	/**
		@return `this` as a formatted `String`.
	**/
	public function toString():String
		return format();
}

enum abstract CCompiler(String) to String {
	final Gcc = "gcc";
	final Clang = "clang";
}
