package hlc_compiler;

import hlc_compiler.gcc.GccCommand;

class Main {
	/**
		Entry point of `hlc_compiler` package.
	**/
	public static function main() {
		final rawArguments = Sys.args();
		if (showInstruction(rawArguments)) return;

		try {
			final arguments = ArgumentTools.validateRaw(rawArguments);
			run(arguments);
		} catch (e:Dynamic) {
			Sys.println("Caught exception:");
			Sys.println(e);
			Common.showHint(true, true);
		}
	}

	/**
		The main process of hlc-compiler.
		Compiles HL/C into executable according to `arguments`.
	**/
	static function run(arguments: Arguments): Void {
		final prepared = prepareRun(arguments);
		final gccCommand = prepared.gccCommand;
		final filesToCopy = prepared.filesToCopy;

		final outDir = ArgumentTools.getOutDir(arguments);

		Sys.println("Running GCC command...");
		gccCommand.run(arguments.verbose);

		if (0 < filesToCopy.length) {
			Sys.println("Copying runtime files...");
			filesToCopy.copyTo(outDir.path);
		}

		Sys.println("Completed.");

		final saveCmdPath = arguments.saveCmdPath;
		if (saveCmdPath.isSome()) {
			final path = saveCmdPath.unwrap();
			SaveCommandTools.saveGccBat(path, outDir, gccCommand, filesToCopy);
			Sys.println('Saved command: $path');
		}
	}

	/**
		Prepares for `run()`.
	**/
	static function prepareRun(arguments: Arguments) {
		final hlcJsonFile = FileRef.from(arguments.srcDir + "hlc.json");
		final requiredLibraries = LibraryTools.getRequiredLibraries(
			hlcJsonFile,
			arguments.libDir
		);

		final gccCommand = GccCommand.from(arguments, requiredLibraries.build);
		final filesToCopy = if (arguments.copyRuntimeFiles)
			FileList.from(arguments.exLibs.concat(requiredLibraries.runtime)) else [];

		return {
			gccCommand: gccCommand,
			filesToCopy: filesToCopy
		}
	}

	/**
		Shows instruction info under some conditions.
		@return `true` if anything is shown.
	**/
	static function showInstruction(rawArguments: Array<String>): Bool {
		switch rawArguments.length {
			case 0 | 1:
				Common.showVersion(true, true);
				Common.showHint(false, true);
				return true;
			case 2 if (rawArguments[0] == "--version"):
				Common.showVersion(true, true);
				return true;
			default:
				return false;
		}
	}
}
