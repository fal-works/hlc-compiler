package hlc_compiler;

import hlc_compiler.gcc.CommandBuilder as GccCommandBuilder;
import hlc_compiler.gcc.SanitizedCommand as GccCommand;
import hlc_compiler.general.MaybeCommand;
import hlc_compiler.general.MaybeCommandTools.*;

class Main {
	public static function main() {
		try {
			final arguments = validateArguments();
			run(arguments);
		} catch (e) {
			Sys.println(e);
		}
	}

	static function run(arguments: Arguments): Void {
		final outFile = arguments.outFile;
		final outDir = outFile.getDirectoryPath();
		final outDirStr = outDir.quote();
		final mkOutDirCmd = 'if not exist $outDirStr ^\nmkdir $outDirStr';
		final gccCommand = GccCommandBuilder.build(arguments).sanitize();

		Sys.command(mkOutDirCmd);

		Sys.println("Running GCC command...");
		gccCommand.run();
		Sys.println("Completed.");

		if (arguments.saveCmdPath.isSome()) {
			final savePath = arguments.saveCmdPath.unwrap();
			saveBat(savePath, mkOutDirCmd, gccCommand);
			Sys.println('Saved command: $savePath');
		}
	}

	static function saveBat(
		savePath: FilePath,
		mkOutDirCmd: String,
		gccCommand: GccCommand
	): Void {
		final saveDirPath = savePath.getDirectoryPath();
		if (!saveDirPath.exists()) saveDirPath.createDirectory();

		final gccBlock = ["gcc"].concat(gccCommand).join(" ^\n");

		var contents = ["@echo off", "echo Running GCC command...", mkOutDirCmd, gccBlock, "echo Completed."];

		sys.io.File.saveContent(savePath, contents.join("\n\n") + "\n");
	}

	static function createMkdirCommand(dirPath: DirectoryPath): MaybeCommand {
		return switch (dirPath.exists()) {
			case false: nullCommand;
			case true: createCommand('mkdir ${dirPath.quote()}');
		}
	}

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
			exOptions: exOptions,
			saveCmdPath: saveCmdPath,
			verbose: verbose
		};
	}
}
