package hlc_compiler;

import locator.FileRef.fromStringCallback as toFile;
import locator.FilePath.fromStringCallback as toFilePath;
import locator.DirectoryRef.fromStringCallback as toDir;

/**
	Sanitized arguments for hlc-compiler, completed with default values.
	Converted from command line arguments.
**/
@:notNull @:forward
abstract Arguments(Data) from Data {
	/**
		Validates file/directory paths and completes them with default values.
		@return Arguments in `Arguments` representation.
	**/
	public static function from(args: CommandArgumentSummary): Arguments {
		final commandValues = args.commandValues.copy();
		final options = args.optionValuesMap;

		final lastCommandValue = commandValues.pop();

		// The last value should be the location where haxelib was called
		if (lastCommandValue.isNone())
			throw 'Cannot get current working directory. Provided arguments: ${Sys.args()}';
		final currentDirectory = DirectoryRef.from(lastCommandValue.unwrap());
		currentDirectory.setAsCurrent();

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
		final exLibs = options.oneOrMore("--exLib").or([]).map(toFile);
		final saveCmdPath = options.zeroOrOne("--saveCmd").map(path -> switch path {
			case Zero: FilePath.from("./compile_hlc");
			case One(relPath): FilePath.from(relPath);
		});
		final relative = options.exists("--relative");
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
			exLibs: exLibs,
			exOptions: exOptions,
			saveCmdPath: saveCmdPath,
			relative: relative,
			verbose: verbose
		};

		if (verbose) {
			Sys.println('Set $currentDirectory as current directory.\n');
			Sys.println('Sanitized arguments:\n${arguments.format("  ")}\n');
		}

		return arguments;
	}

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
		s += '${indent}exLibs:           ${this.exLibs.toString()}\n';
		s += '${indent}exOptions:        ${this.exOptions.toString()}\n';
		s += '${indent}saveCmd:          ${this.saveCmdPath.toString()}';
		return s;
	}

	/**
		@return `this` as a formatted `String`.
	**/
	public function toString()
		return format();
}

private typedef Data = {
	/**
		Directory containing `main.c` and `hlc.json`.
	**/
	final srcDir: DirectoryRef;

	/**
		Source `*.c` file.
	**/
	final srcFile: FileRef;

	/**
		`hlc.json` in the HL/C source directory.
	**/
	final hlcJsonFile: FileRef;

	/**
		Output file path.
	**/
	final outFile: FilePath;

	/**
		Output directory path.
	**/
	final outDir: DirectoryPath;

	/**
		Directory containing `*.hdll` and other library files bundled with HashLink.
	**/
	final hlLibDir: DirectoryRef;

	/**
		Directory containing HL files to be included (such as `hlc.h`).
		Is not mandatory because the directory may be automatically searched by `gcc` (especially if not Windows).
	**/
	final hlIncludeDir: Maybe<DirectoryRef>;

	/**
		`true` if files that are required at runtime should be copied to the output directory.
	**/
	final copyRuntimeFiles: Bool;

	/**
		Additional files that should be passed to GCC.
		These are not copied to the destination directory.
	**/
	final exFiles: Array<FileRef>;

	/**
		Additional files that should be passed to GCC.
		Unlike `exFile`, these are also copied if `copyRuntimeFiles` is `true`.
	**/
	final exLibs: Array<FileRef>;

	/**
		Additional options that should be passed to GCC.
	**/
	final exOptions: Array<String>;

	/**
		The file path where the command should be saved.
		Does not emit file if `null`.
	**/
	final saveCmdPath: Maybe<FilePath>;

	/**
		`true` if file/directory paths should be converted to relative paths when creating commands lines.
	**/
	final relative: Bool;

	/**
		`true` if verbose logging should be enabled.
	**/
	final verbose: Bool;
};
