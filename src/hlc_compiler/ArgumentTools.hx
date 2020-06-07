package hlc_compiler;

import hlc_compiler.Environment.system;

class ArgumentTools {
	/**
		Validates arguments that were passed in the command line
	**/
	public static function validateRaw(rawArguments: Array<String>): Arguments {
		// The last argument should be the location where haxelib was called
		rawArguments = rawArguments.copy();
		final lastArgument = rawArguments.pop();
		if (lastArgument.isNone()) throw "Passed no arguments."; // should not be reached
		final currentDirectory = DirectoryRef.from(lastArgument.unwrap());
		currentDirectory.setAsCurrent();
		final rawArgumentsLength = rawArguments.length;
		var index = 0;

		inline function hasNext()
			return index < rawArgumentsLength;

		inline function next()
			return rawArguments[index++];

		inline function nextOption(option: String) {
			if (!hasNext())
				throw 'Missing argument for option: $option';
			return next();
		}

		var srcDir = currentDirectory;
		var outFile = currentDirectory.path.makeFilePath("hlc_bin/main");
		var libDir = switch system {
			case Windows: findHashlinkDirectory().or(currentDirectory);
			case Mac: DirectoryPath.from('/usr/local/lib/').tryFind().or(currentDirectory);
		};
		var includeDir: Maybe<DirectoryRef> = Maybe.none();
		var copyRuntimeFiles = false;
		var exFiles: Array<FileRef> = [];
		var exLibs: Array<FileRef> = [];
		var exOptions: Array<String> = [];
		var saveCmdPath: Maybe<FilePath> = Maybe.none();
		var verbose = false;

		while (hasNext()) {
			switch (next()) {
				case "--srcDir":
					srcDir = DirectoryRef.from(nextOption("--srcDir [directory path]"));
				case "--outFile":
					outFile = FilePath.from(nextOption("--outFile [file path]"));
				case "--libDir":
					libDir = DirectoryRef.from(nextOption("--libDir [directory path]"));
				case "--includeDir":
					includeDir = Maybe.from(DirectoryRef.from(nextOption("--includeDir [directory path]")));
				case "--copyRuntimeFiles":
					copyRuntimeFiles = true;
				case "--exFiles":
					exFiles = nextOption("--exFiles [comma-separated file paths]").split(",")
						.map(FileRef.fromStringCallback);
				case "--exLibs":
					exLibs = nextOption("--exLibs [comma-separated file paths]").split(",")
						.map(FileRef.fromStringCallback);
				case "--saveCmd":
					saveCmdPath = FilePath.from(nextOption("--saveCmd [file path]"));
				case "--verbose":
					verbose = true;
				case "--version":
					Common.showVersion(false, true);
				case otherValue:
					exOptions.push(otherValue);
			}
		}

		// Suggestion for `includeDir` if not provided
		if (includeDir.isNone()) switch system {
			case Windows: includeDir = libDir.path.concat("include").tryFind();
			default:
		}

		if (verbose) {
			Sys.println('Provided arguments:\n  ${rawArguments.join(" | ")}\n');
			Sys.println('Set $currentDirectory as current directory.\n');
			Sys.println('Validated arguments:');
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
		Tries to find HashLink installation directory from environment variables:
		- `HASHLINKPATH`
		- `HASHLINK`
		- `HASHLINK_BIN`
	**/
	static function findHashlinkDirectory(): Maybe<DirectoryRef> {
		var libDir: Maybe<DirectoryRef> = Maybe.none();

		[
			"HASHLINKPATH",
			"HASHLINK",
			"HASHLINK_BIN"
		].forFirst(s -> {
			final envVarValue = Maybe.from(Sys.getEnv(s));
			if (envVarValue.isNone()) return false;

			final dir = DirectoryPath.from(envVarValue.unwrap()).tryFind();
			if (dir.isNone()) return false;

			libDir = dir;
			return true;
		}, s -> {});

		return libDir;
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
