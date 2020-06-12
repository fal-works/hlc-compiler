package hlc_compiler;

/**
	Static functions for creating/formatting gcc arguments.
**/
class GccCommandBuilder {
	/**
		Converts provided data to `CommandLine`.
	**/
	public static function build(
		arguments: Arguments,
		basicLibraries: Array<LibrarySpecifier>,
		cli: Cli
	): CommandLine {
		final srcDir = arguments.srcDir;
		final srcFile = arguments.srcFile;
		final outFile = arguments.outFile;
		final hlLibDir = arguments.hlLibDir;
		final includeDir = arguments.includeDir;
		final exOptions = arguments.exOptions;

		final files = [srcFile].concat(arguments.exFiles);
		final libs = arguments.exLibs.map(LibrarySpecifier.File).concat(basicLibraries);

		final args: CommandArgumentList = [];

		args.push(OptionParameter("-o", Space, outFile.validate(cli)));

		args.push(OptionParameter("-I", Space, srcDir.path.validate(cli)));
		if (includeDir.isSome()) {
			final path = includeDir.unwrap().path.validate(cli);
			args.push(OptionParameter("-I", Space, path));
		}

		args.push(OptionParameter("-L", Space, hlLibDir.path.validate(cli)));

		for (exOption in exOptions)
			args.push(Parameter(exOption));
		if (!exOptions.hasAny(s -> s.startsWith("-std=")))
			args.push(Parameter("-std=c11"));

		for (file in files)
			args.push(Parameter(file.path.validate(cli)));

		for (lib in libs)
			args.push(OptionParameter("-l", None, lib.quote(cli)));

		return new CommandLine("gcc", args);
	}
}
