package hlc_compiler;

import hlc_compiler.save.SaveCommandTools;
import hlc_compiler.types.Arguments;

/**
	Runs the main process of hlc-compiler according to `arguments`.
	- Compiles HL/C into executable.
	- (If specified) Copies runtime files.
	- (If specified) Saves command lines.
**/
function run(arguments: Arguments): Void {
	final verbose = arguments.verbose;

	final prepared = prepareRun(arguments);
	final compileCommand = prepared.compileCommand;
	final copyList = prepared.copyList;

	final outDir = arguments.outDir.findOrCreate(); // Prepare dir before compiling

	Sys.println("Compiling...");
	final errorLevel = compileCommand.run(verbose);

	if (errorLevel != 0) {
		final msg = if (verbose) {
			"Compilation command failed."; // Command already printed if verbose
		} else {
			'Compilation command failed:\n${compileCommand.quote(Cli.current)}';
		}
		throw error(msg);
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
function prepareRun(arguments: Arguments): PreparedData {
	final hlLibs = LibrarySearcher.getRequiredLibraries(
		arguments.hlcJsonFile,
		arguments.hlLibDir
	);

	final compileCommand = GccCommandBuilder.build(
		arguments,
		hlLibs.filterStatic(),
		Cli.current
	);
	final copyList = if (arguments.copyRuntimeFiles) {
		final hlLibsToCopy = hlLibs.filterShared().map(x -> FileOrDirectoryRef.fromFile(x));
		hlLibsToCopy.concat(arguments.runtime);
	} else [];

	return {
		compileCommand: compileCommand,
		copyList: copyList,
	}
}

private typedef PreparedData = {
	final compileCommand: CommandLine;
	final copyList: FileOrDirectoryList;
};
