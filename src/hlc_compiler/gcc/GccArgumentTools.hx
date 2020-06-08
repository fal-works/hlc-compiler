package hlc_compiler.gcc;

import hlc_compiler.Tools.quoteCommandArgument;

/**
	Static functions for creating/formatting gcc arguments.
**/
class GccArgumentTools {
	/**
		Regular expression that matches `someKey=someValue`.
	**/
	static final withValue = ~/([^=]+=)([ .]+)/i;

	/**
		Converts provided data to `GccArguments`.
	**/
	public static function createGccArguments(
		commonArguments: Arguments,
		basicLibraries: Array<LibrarySpecifier>
	): GccArguments {
		final srcDir = commonArguments.srcDir;
		final includeDir = commonArguments.includeDir;

		final srcFile = srcDir.path.makeFilePath("main.c").find();

		final includes = [srcDir];
		if (includeDir.isSome()) includes.push(includeDir.unwrap());

		final exOptions = commonArguments.exOptions.copy();
		if (!exOptions.hasAny(s -> s.startsWith("-std=")))
			exOptions.push("-std=c11");

		final files = [srcFile];
		files.pushFromArray(commonArguments.exFiles);

		final exLibs = commonArguments.exLibs.map(file -> LibrarySpecifier.File(file));
		final libs = exLibs.concat(basicLibraries);

		return {
			outFilePath: commonArguments.outFile,
			includeDirectories: includes,
			libraryDirectory: commonArguments.libDir,
			exOptions: exOptions,
			files: files,
			libraries: libs
		};
	}

	/**
		Formats `arguments` so that they can be used in command line on the current OS.
	**/
	public static function format(arguments: GccArguments): Array<String> {
		final argLines: Array<String> = [];

		argLines.push('-o ${arguments.outFilePath.quote()}');

		for (dir in arguments.includeDirectories)
			argLines.push('-I ${dir.path.quote()}');

		argLines.push('-L ${arguments.libraryDirectory.path.quote()}');

		for (option in arguments.exOptions)
			argLines.push(quoteCommandArgument(option));

		for (file in arguments.files)
			argLines.push(file.path.quote());

		for (lib in arguments.libraries)
			argLines.push(switch lib {
				case Name(name): '-l$name';
				case File(file): file.path.quote();
			});

		return argLines;
	}
}
