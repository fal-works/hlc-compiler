package hlc_compiler;

import hlc_compiler.gcc.CommandBuilder as GccCommandBuilder;
import hlc_compiler.gcc.SanitizedCommand as GccCommand;

class Main {
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
		Compiles HL/C into executable according to `arguments`.
	**/
	static function run(arguments: Arguments): Void {
		final outFile = arguments.outFile;
		final outDirPath = outFile.getDirectoryPath();
		final gcc = GccCommandBuilder.build(arguments);
		final gccCommand = gcc.command.sanitize();
		final filesToCopy = if (!arguments.copyDlls) [] else
			arguments.exDlls.concat(gcc.libraryFiles.runtime);

		final outDir = if (outDirPath.exists()) outDirPath.find() else
			outDirPath.createDirectory();

		Sys.println("Running GCC command...");
		gccCommand.run();

		if (0 < filesToCopy.length) {
			Sys.println("Copying DLL files...");
			for (file in filesToCopy)
				file.copy(outDirPath.makeFilePath(file.getName()));
		}

		Sys.println("Completed.");

		if (arguments.saveCmdPath.isSome()) {
			final savePath = arguments.saveCmdPath.unwrap();
			saveBat(savePath, outDir, gccCommand, filesToCopy);
			Sys.println('Saved command: $savePath');
		}
	}

	/**
		Saves build command as a Windows batch file.
	**/
	static function saveBat(
		savePath: FilePath,
		outDir: DirectoryRef,
		gccCommand: GccCommand,
		filesToCopy: Array<FileRef>
	): Void {
		final saveDirPath = savePath.getDirectoryPath();
		if (!saveDirPath.exists()) saveDirPath.createDirectory();

		final outDirStr = outDir.path.quote();
		final mkOutDirCmd = 'if not exist $outDirStr ^\nmkdir $outDirStr';

		final gccBlock = ["gcc"].concat(gccCommand).join(" ^\n");

		final contents = [
			"@echo off",
			mkOutDirCmd,
			"echo Running GCC command...",
			gccBlock
		];
		if (0 < filesToCopy.length) {
			contents.push("echo Copying DLL files...");
			for (file in filesToCopy)
				contents.push('copy ${file.path.quote()} $outDirStr > nul');
		}
		contents.push("echo Completed.");

		sys.io.File.saveContent(savePath, contents.join("\n\n") + "\n");
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
