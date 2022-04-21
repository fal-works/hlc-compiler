package hlc_compiler;

import hlc_compiler.save.SaveCommandTools;
import hlc_compiler.types.Arguments;

class Main {
	/**
		Entry point to be called from `haxelib run hlc-compiler`.

		The last argument should be the current working directory.
	**/
	public static function main(): Void {
		final args: Array<String> = Sys.args();

		inline function error()
			throw 'Cannot get current working directory. Passed arguments: ${Sys.args()}';

		final lastArg = args.pop();
		if (lastArg.isNone()) error();
		final cwdPath = DirectoryPath.from(lastArg.unwrap());
		if (!cwdPath.exists()) error();

		cwdPath.find().setAsCurrent();

		tryProcessArguments(args);
	}

	/**
		Tries to process `args`.
		If caught any exception, prints it with a hint info and exits the current process with return code `1`.
		@param args Arguments passed to hlc-compiler in the command line.
	**/
	public static function tryProcessArguments(args: Array<String>): Void {
		try {
			processArguments(args);
		} catch (e:Dynamic) {
			Sys.println('Caught exception:\n$e');
			Common.showHint(true, true);
			Sys.exit(1);
		}
	}

	/**
		Processes `args`, and runs compilation or shows instruction depending on `args`.
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
		final copyList = prepared.copyList;

		final outDir = arguments.outDir.findOrCreate(); // Prepare dir before compiling

		Sys.println("Compiling...");
		final errorLevel = compileCommand.run(verbose);

		if (errorLevel != 0) {
			if (verbose)
				throw "Compilation command failed."; // Command already printed if verbose
			else
				throw 'Compilation command failed:\n${compileCommand.quote(Cli.current)}';
		}

		if (0 < copyList.length) {
			Sys.println("Copying runtime files...");
			if (verbose) Sys.println('${copyList.getNames()} => ${outDir.path}');
			copyList.copyTo(outDir.path);
		}

		Sys.println("Completed.");

		final saveCmdPath = arguments.saveCmdPath;
		if (saveCmdPath.isSome()) {
			final savePath = saveCmdPath.unwrap();
			final savedPath = switch Environment.systemType {
				case Windows:
					SaveCommandTools.saveCommandBat(
						savePath,
						outDir,
						compileCommand,
						copyList,
						arguments.relative
					);
				case Mac:
					SaveCommandTools.saveCommandShell(
						savePath,
						outDir,
						compileCommand,
						copyList,
						arguments.relative
					);
			}
			Sys.println('Saved command: $savedPath');
		}
	}

	/**
		Prepares for `run()`.
	**/
	static function prepareRun(arguments: Arguments): PreparedData {
		final hlLibs = LibraryTools.getRequiredLibraries(
			arguments.hlcJsonFile,
			arguments.hlLibDir
		);
		final hlLibsToCopy = hlLibs.filterShared().map(FileOrDirectoryRef.fromFileCallback);

		return {
			compileCommand: GccCommandBuilder.build(
				arguments,
				hlLibs.filterStatic(),
				Cli.current
			),
			copyList: if (!arguments.copyRuntimeFiles) [] else
				hlLibsToCopy.concat(arguments.runtime)
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
	final copyList: FileOrDirectoryList;
};
