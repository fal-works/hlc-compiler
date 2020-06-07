package hlc_compiler;

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
		var hlDir = findHashlinkDirectory().or(currentDirectory);
		var copyDlls = false;
		var exFiles: Array<FileRef> = [];
		var exDlls: Array<FileRef> = [];
		var exOptions: Array<String> = [];
		var saveCmdPath: Maybe<FilePath> = Maybe.none();
		var verbose = false;

		while (hasNext()) {
			switch (next()) {
				case "--srcDir":
					srcDir = DirectoryRef.from(nextOption("--srcDir [directory path]"));
				case "--outFile":
					outFile = FilePath.from(nextOption("--outFile [file path]"));
				case "--hlDir":
					hlDir = DirectoryRef.from(nextOption("--hlDir [directory path]"));
				case "--copyDlls":
					copyDlls = true;
				case "--exFiles":
					exFiles = nextOption("--exFiles [comma-separated file paths]").split(",")
						.map(FileRef.fromStringCallback);
				case "--exDlls":
					exDlls = nextOption("--exDlls [comma-separated file paths]").split(",")
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

		if (verbose) {
			Sys.println('Provided arguments:\n  ${rawArguments.join(" | ")}\n');
			Sys.println('Set $currentDirectory as current directory.\n');
			Sys.println('Validated arguments:');
			Sys.println('  srcDir:    $srcDir');
			Sys.println('  outFile:   $outFile');
			Sys.println('  hlDir:     $hlDir');
			Sys.println('  copyDlls:  $copyDlls');
			Sys.println('  exFiles:   $exFiles');
			Sys.println('  exDlls:    $exDlls');
			Sys.println('  exOptions: $exOptions');
			Sys.println('  saveCmd:   ${saveCmdPath.toString()}');
			Sys.println("");
		}

		return {
			srcDir: srcDir,
			outFile: outFile,
			hlDir: hlDir,
			copyDlls: copyDlls,
			exFiles: exFiles,
			exDlls: exDlls,
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
		var hlDir: Maybe<DirectoryRef> = Maybe.none();

		["HASHLINKPATH", "HASHLINK", "HASHLINK_BIN"].forFirst(s -> {
			final envVarValue = Maybe.from(Sys.getEnv(s));
			if (envVarValue.isNone()) return false;

			final dir = DirectoryPath.from(envVarValue.unwrap()).tryFind();
			if (dir.isNone()) return false;

			hlDir = dir;
			return true;
		}, s -> {});

		return hlDir;
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
