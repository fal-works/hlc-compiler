package hlc_compiler;

import hlc_compiler.gcc.CommandBuilder as GccCommandBuilder;
import hlc_compiler.gcc.SanitizedCommand as GccCommand;

class Main {
	public static function main() {
		try {
			final arguments = validateArguments();
			run(arguments);
		} catch (e) {
			Sys.println(e);
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
		Validates arguments that were passed in the command line
	**/
	static function validateArguments(): Arguments {
		final args = Sys.args();
		args.pop(); // The last argument should be the hlc-compiler directory
		final argsLength = args.length;
		var index = 0;

		inline function hasNext()
			return index < argsLength;

		inline function next()
			return args[index++];

		inline function nextOption(option: String) {
			if (!hasNext())
				throw 'Missing argument for option: $option';
			return next();
		}

		final currentDir = DirectoryRef.current();
		var srcDir = currentDir;
		var outFile = currentDir.path.makeFilePath("hlc_bin/main");
		var hlDir = currentDir;
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
				case otherValue:
					exOptions.push(otherValue);
			}
		}

		if (verbose) {
			Sys.println('Provided arguments:\n  ${args.join(" | ")}\n');
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
}
