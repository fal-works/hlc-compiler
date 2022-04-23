package hlc_compiler;

import hlc_compiler.LibrarySearcher;
import hlc_compiler.internal.Common;
import hlc_compiler.types.Arguments;
import locator.DirectoryRef.fromStringCallback as toDir;
import locator.FileOrDirectoryRef.fromStringCallback as toFileOrDir;
import locator.FileRef.fromStringCallback as toFile;

/**
	Parses an array of raw argument strings and returns an `Arguments` instance.

	If only 0..1 arguments are provided, prints some messages and returns `Maybe.none()`.
**/
function parseOptions(rawArguments: Array<String>): Maybe<Arguments> {
	final argList = Cli.current.parseArguments(
		rawArguments,
		CommandOptions.rules
	);
	final argSummary = argList.summary(CommandOptions.aliases);
	final options = argSummary.optionValuesMap;

	if (options.exists("--verbose")) {
		Sys.println("Passed options:");
		Sys.println(argSummary.formatOptions("  "));
	}

	return switch argList.length {
		case 0 | 1:
			showVersion(true, true);
			showHint(false, true);
			Maybe.none();

		default:
			Maybe.from(validateArguments(argSummary));
	}
}

/**
	Validates file/directory paths and completes them with default values.
	@return Arguments for hlc-compiler in `Arguments` representation.
**/
function validateArguments(args: CommandArgumentSummary): Arguments {
	final currentDirectory = DirectoryRef.current();
	final options = args.optionValuesMap;

	if (options.exists("--version"))
		showVersion(false, true);

	final srcDir = options.one("--srcDir").map(toDir).or(currentDirectory);
	final srcFile = srcDir.findFile(options.one("--srcFile").or("main.c"));
	final hlcJsonFile = srcDir.findFile(options.one("--hlcJsonFile").or("hlc.json"));

	final outDirOption = options.one("--outDir");
	final outFileOption = options.one("--outFile");
	final defaultOutFileName = srcFile.getNameWithoutExtension();
	var outDir: DirectoryPath;
	var outFile: FilePath;
	switch outDirOption.toOption() {
		case Some(outDirStr):
			outDir = DirectoryPath.from(outDirStr);
			outFile = outDir.makeFilePath(outFileOption.or(defaultOutFileName));
		case None:
			switch outFileOption.toOption() {
				case Some(outFileStr):
					outFile = FilePath.from(outFileStr);
					outDir = outFile.getParentPath();
				case None:
					outDir = currentDirectory.path;
					outFile = outDir.makeFilePath(defaultOutFileName);
			}
	}

	final hlLibDir = options.one("--hlLibDir")
		.map(toDir)
		.coalesceWith(() -> suggestHashLinkLibraryDirectory())
		.or(currentDirectory);

	final hlIncludeDir = options.one("--hlIncludeDir")
		.map(toDir)
		.coalesceWith(() -> suggestHashLinkIncludeDirectory(hlLibDir));

	final copyRuntimeFiles = options.exists("--copyRuntimeFiles");
	final exFiles = options.oneOrMore("--exFile").or([]).map(toFile);
	final runtime = options.oneOrMore("--runtime").or([]).map(toFileOrDir);
	final saveCmdPath = options.zeroOrOne("--saveCmd").map(path -> switch path {
		case Zero: FilePath.from("./compile_hlc");
		case One(relPath): FilePath.from(relPath);
	});
	final relative = options.exists("--relative");
	final compiler = options.one("--compiler")
		.map(validateCompiler)
		.orElse(() -> switch Environment.systemType {
			case Windows: Gcc;
			case Mac: Clang;
		});
	final verbose = options.exists("--verbose");

	final exOptions: Array<String> = [];

	final hlcCompilerOptionSet = CommandOptions.set;
	for (option in options.keys())
		if (!hlcCompilerOptionSet.has(option)) exOptions.push(option.toString());

	final arguments: Arguments = {
		srcDir: srcDir,
		srcFile: srcFile,
		hlcJsonFile: hlcJsonFile,
		outDir: outDir,
		outFile: outFile,
		hlLibDir: hlLibDir,
		hlIncludeDir: hlIncludeDir,
		copyRuntimeFiles: copyRuntimeFiles,
		exFiles: exFiles,
		runtime: runtime,
		exOptions: exOptions,
		saveCmdPath: saveCmdPath,
		relative: relative,
		compiler: compiler,
		verbose: verbose
	};

	if (verbose) {
		Sys.println('Set $currentDirectory as current directory.\n');
		Sys.println('Sanitized arguments:\n${arguments.format("  ")}\n');
	}

	return arguments;
}

private function validateCompiler(compilerStr: String): CCompiler {
	return switch compilerStr.toLowerCase() {
		case "gcc": Gcc;
		case "clang": Clang;
		default:
			final msg = 'Unknown compiler: $compilerStr\n  This should be either gcc or clang.';
			throw error(msg);
	}
}
