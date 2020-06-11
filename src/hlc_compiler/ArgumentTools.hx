package hlc_compiler;

import greeter.*;
import locator.FileRef.fromStringCallback as toFile;
import locator.FilePath.fromStringCallback as toFilePath;
import locator.DirectoryRef.fromStringCallback as toDir;

class ArgumentTools {
	/**
		Validates arguments that were passed in the command line
	**/
	public static function validateRaw(args: CommandArgumentSummary): Arguments {
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
			.orElse(() -> Environment.system.getDefaultLibDir(currentDirectory));

		final includeDir = options.one("--includeDir")
			.map(toDir)
			.coalesceWith(() -> Environment.system.suggestIncludeDir(libDir));

		final copyRuntimeFiles = options.exists("--copyRuntimeFiles");
		final exFiles = options.oneOrMore("--exFiles").or([]).map(toFile);
		final exLibs = options.oneOrMore("--exLibs").or([]).map(toFile);
		final saveCmdPath = options.one("--saveCmd").map(toFilePath); // TODO: make optional
		final verbose = options.exists("--verbose");

		final exOptions: Array<String> = [];

		final hlcCompilerOptionSet: Array<CommandOption> = [
			"--version",
			"--srcDir",
			"--outFile",
			"--libDir",
			"--includeDir",
			"--copyRuntimeFiles",
			"--exFiles",
			"--exLibs",
			"--saveCmd",
			"--verbose"
		];

		for (option in options.keys())
			if (!hlcCompilerOptionSet.has(option)) exOptions.push(option.toString());

		if (verbose) {
			Sys.println('Set $currentDirectory as current directory.\n');
			Sys.println('Arguments:');
			Sys.println('  srcDir:           $srcDir');
			Sys.println('  outFile:          $outFile');
			Sys.println('  libDir:           $libDir');
			Sys.println('  includeDir:       $includeDir');
			Sys.println('  copyRuntimeFiles: $copyRuntimeFiles');
			Sys.println('  exFiles:          $exFiles');
			Sys.println('  exLibs:           $exLibs');
			Sys.println('  exOptions:        $exOptions');
			Sys.println('  saveCmd:          ${saveCmdPath.toString()}');
			Sys.println("");
		}

		return {
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
	}

	/**
		Finds or creates the output directory according to `arguments`.
	**/
	public static function getOutDir(arguments: Arguments): DirectoryRef {
		final outDirPath = arguments.outFile.getParentPath();

		final maybeOutDir = outDirPath.tryFind();
		if (maybeOutDir.isSome()) return maybeOutDir.unwrap();

		return outDirPath.createDirectory();
	}
}
