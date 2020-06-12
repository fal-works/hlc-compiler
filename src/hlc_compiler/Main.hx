package hlc_compiler;

class Main {
	/**
		Entry point of this package.
		Processes all the arguments passed to hlc-compiler.
	**/
	public static function main(): Void {
		try {
			processArguments(Sys.args());
		} catch (e:Dynamic) {
			Sys.println('Caught exception:\n$e');
			Common.showHint(true, true);
			Sys.exit(1);
		}
	}

	/**
		Processes `args`, and runs compilation or shows instruction depending on `args`.
		@param args Typically the result of `Sys.args()`.
	**/
	public static function processArguments(args: Array<RawArgument>): Void {
		final argList = Cli.current.parseArguments(args, CommandOptions.rules);
		final argSummary = argList.summary(CommandOptions.aliases);

		if (argSummary.optionValuesMap.exists("--verbose")) {
			Sys.println("Passed options:");
			Sys.println(argSummary.formatOptions("  "));
		}

		if (showInstruction(argList, argSummary)) return;

		final sanitizedArguments = Arguments.from(argSummary);
		run(sanitizedArguments);
	}

	/**
		Runs the main process of hlc-compiler according to `arguments`.
		- Compiles HL/C into executable.
		- (If specified) Copies runtime files.
		- (If specified) Saves the command.
	**/
	public static function run(arguments: Arguments): Void {
		final verbose = arguments.verbose;

		final prepared = prepareRun(arguments);
		final compileCommand = prepared.compileCommand;
		final filesToCopy = prepared.filesToCopy;

		final outDir = arguments.outFile.getParentPath().findOrCreate(); // Prepare dir before compiling

		Sys.println("Compiling...");
		final errorLevel = compileCommand.run(verbose);

		if (errorLevel != 0) {
			if (verbose)
				throw "Compilation command failed."; // Command already printed if verbose
			else
				throw 'Compilation command failed:\n${compileCommand.quote(Cli.current)}';
		}

		if (0 < filesToCopy.length) {
			Sys.println("Copying runtime files...");
			filesToCopy.copyTo(outDir.path);
		}

		Sys.println("Completed.");

		final saveCmdPath = arguments.saveCmdPath;
		if (saveCmdPath.isSome()) {
			final path = saveCmdPath.unwrap();
			SaveCommandTools.saveCommandBat(path, outDir, compileCommand, filesToCopy);
			Sys.println('Saved command: $path');
		}
	}

	/**
		Prepares for `run()`.
	**/
	static function prepareRun(arguments: Arguments): PreparedData {
		final hlcJsonFile = FileRef.from(arguments.srcDir + "hlc.json");
		final requiredLibraries = LibraryTools.getRequiredLibraries(
			hlcJsonFile,
			arguments.libDir
		);

		return {
			compileCommand: GccCommandBuilder.build(
				arguments,
				requiredLibraries.filterStatic(),
				Cli.current
			),
			filesToCopy: if (!arguments.copyRuntimeFiles) [] else
				arguments.exLibs.concat(requiredLibraries.filterShared())
		}
	}

	/**
		Shows instruction info under some conditions.
		@return `true` if anything is shown.
	**/
	static function showInstruction(
		argList: CommandArgumentList,
		argsSummary: CommandArgumentSummary
	): Bool {
		switch argList.length {
			case 0 | 1:
				Common.showVersion(true, true);
				Common.showHint(false, true);
				return true;
			case 2 if (argsSummary.optionValuesMap.exists("--version")):
				Common.showVersion(true, true);
				return true;
			default:
				return false;
		}
	}
}

private typedef PreparedData = {
	final compileCommand: CommandLine;
	final filesToCopy: FileList;
};
