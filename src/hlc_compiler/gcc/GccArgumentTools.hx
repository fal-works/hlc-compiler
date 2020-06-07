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
		libraries: Array<FileRef>
	): GccArguments {
		final srcDir = commonArguments.srcDir;
		final includeDir = commonArguments.includeDir;

		final srcFile = srcDir.path.makeFilePath("main.c").find();

		final includes = [srcDir];
		if (includeDir.isSome()) includes.push(includeDir.unwrap());

		final files: Array<FileRef> = [
			[srcFile],
			commonArguments.exFiles,
			commonArguments.exDlls,
			libraries
		].flatten();

		final exOptions = commonArguments.exOptions.copy();
		if (!exOptions.hasAny(s -> s.startsWith("-std=")))
			exOptions.push("-std=c11");

		return {
			outFile: commonArguments.outFile,
			includes: includes,
			exOptions: exOptions,
			files: files
		};
	}

	/**
		Formats `arguments` so that they can be used in command line on the current OS.
	**/
	public static function format(arguments: GccArguments): Array<String> {
		final argLines: Array<String> = [];

		argLines.push('-o ${arguments.outFile.quote()}');

		for (dir in arguments.includes)
			argLines.push('-I ${dir.path.quote()}');

		for (option in arguments.exOptions)
			argLines.push(quoteCommandArgument(option));

		for (file in arguments.files)
			argLines.push(file.path.quote());

		return argLines;
	}
}
