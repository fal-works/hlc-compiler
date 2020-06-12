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
	public static function from(
		args: CommandArgumentSummary
	): Arguments {
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

		final outFile = options.one("--outFile")
			.map(toFilePath)
			.orElse(() -> currentDirectory.makeFilePath("hlc_bin/main"));

		final libDir = options.one("--libDir")
			.map(toDir)
			.orElse(() -> CommandOptions.suggestHashLinkLibraryDirectory().or(currentDirectory));

		final includeDir = options.one("--includeDir")
			.map(toDir)
			.coalesceWith(() -> CommandOptions.suggestHashLinkIncludeDirectory(libDir));

		final copyRuntimeFiles = options.exists("--copyRuntimeFiles");
		final exFiles = options.oneOrMore("--exFiles").or([]).map(toFile);
		final exLibs = options.oneOrMore("--exLibs").or([]).map(toFile);
		final saveCmdPath = options.one("--saveCmd").map(toFilePath); // TODO: make optional
		final verbose = options.exists("--verbose");

		final exOptions: Array<String> = [];

		final hlcCompilerOptionSet = CommandOptions.set;
		for (option in options.keys())
			if (!hlcCompilerOptionSet.has(option)) exOptions.push(option.toString());

		final arguments: Arguments = {
			srcDir: srcDir,
			outFile: outFile,
			libDir: libDir,
			includeDir: includeDir,
			copyRuntimeFiles: copyRuntimeFiles,
			exFiles: exFiles,
			exLibs: exLibs,
			exOptions: exOptions,
			saveCmdPath: saveCmdPath,
			verbose: verbose
		};

		if (verbose) {
			Sys.println('Set $currentDirectory as current directory.\n');
			Sys.println('Arguments:\n${arguments.format("  ")}\n');
		}

		return arguments;
	}

	/**
		Formats `this`.
	**/
	public inline function format(indent = ""): String {
		var s = "";
		s += '${indent}srcDir:           ${this.srcDir}\n';
		s += '${indent}outFile:          ${this.outFile}\n';
		s += '${indent}libDir:           ${this.libDir}\n';
		s += '${indent}includeDir:       ${this.includeDir}\n';
		s += '${indent}copyRuntimeFiles: ${this.copyRuntimeFiles}\n';
		s += '${indent}exFiles:          ${this.exFiles}\n';
		s += '${indent}exLibs:           ${this.exLibs}\n';
		s += '${indent}exOptions:        ${this.exOptions}\n';
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
		Output file path.
	**/
	final outFile: FilePath;

	/**
		Directory containing `*.hdll` and other library files.
	**/
	final libDir: DirectoryRef;

	/**
		Directory containing HL files to be included (such as `hlc.h`).
		Is not mandatory because the directory may be automatically searched by `gcc` (especially if not Windows).
	**/
	final includeDir: Maybe<DirectoryRef>;

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
		Unlike `exFiles`, these are also copied if `copyRuntimeFiles` is `true`.
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
		`true` if verbose logging should be enabled.
	**/
	final verbose: Bool;
};
