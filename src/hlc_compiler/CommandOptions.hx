package hlc_compiler;

/**
	Settings of command options passed to hlc-compiler.
**/
class CommandOptions {
	/**
		Rule set about how to parse option argument strings.
	**/
	public static final rules = OptionParseRules.from([
		"--version" => [],
		"--srcDir" => [Space],
		"--srcFile" => [Space],
		"--hlcJsonFile" => [Space],
		"--outDir" => [Space],
		"--outFile" => [Space],
		"-o" => [Space, None],
		"--hlLibDir" => [Space],
		"--hlIncludeDir" => [Space],
		"--copyRuntimeFiles" => [],
		"--exFile" => [Space],
		"--runtime" => [Space],
		"--saveCmd" => [Space],
		"--relative" => [],
		"--compiler" => [Space],
		"--verbose" => [],
		"-std" => [Equal]
	]);

	/**
		Set of all command option instances used in hlc-compiler
		(excluding the ones that should be treated as external gcc options).
	**/
	public static final set = rules.getAllOptions();

	/**
		Mapping from alias options to representative options.
	**/
	public static final aliases: Map<CommandOption, CommandOption> = ["-o" => "--outFile"];
}
