package hlc_compiler;

/**
	Static functions for creating/formatting gcc arguments.
**/
class GccCommandBuilder {
	/**
		Converts provided data to `CommandLine`.
	**/
	public static function build(
		commonArguments: Arguments,
		basicLibraries: Array<LibrarySpecifier>,
		cli: Cli
	): CommandLine {
		final srcDir = commonArguments.srcDir;
		final outFile = commonArguments.outFile;
		final libDir = commonArguments.libDir;
		final includeDir = commonArguments.includeDir;
		final exOptions = commonArguments.exOptions;

		final srcFile = srcDir.path.makeFilePath("main.c").find();
		final files = [srcFile].concat(commonArguments.exFiles);
		final libs = commonArguments.exLibs.map(LibrarySpecifier.File).concat(basicLibraries);

		final args: CommandArgumentList = [];

		args.push(OptionParameter("-o", Space, outFile.validate(cli)));

		args.push(OptionParameter("-I", Space, srcDir.path.validate(cli)));
		if (includeDir.isSome()) {
			final path = includeDir.unwrap().path.validate(cli);
			args.push(OptionParameter("-I", Space, path));
		}

		args.push(OptionParameter("-L", Space, libDir.path.validate(cli)));

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
