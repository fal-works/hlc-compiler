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
		"--outFile" => [Space],
		"-o" => [Space],
		"--libDir" => [Space],
		"--includeDir" => [Space],
		"--copyRuntimeFiles" => [],
		"--exFiles" => [Space],
		"--exLibs" => [Space],
		"--saveCmd" => [Space],
		"--verbose" => [],
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
