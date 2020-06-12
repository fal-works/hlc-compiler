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
		"--outDir" => [Space],
		"--outFile" => [Space],
		"-o" => [Space],
		"--hlLibDir" => [Space],
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

	/**
		@return Default direcotry path of HashLink-bundled libraries (`*.hdll` etc).
	**/
	public static function suggestHashLinkLibraryDirectory(): Maybe<DirectoryRef> {
		return switch Environment.systemType {
			case Windows: searchHashLinkDirectory();
			case Mac: Maybe.from(DirectoryRef.from("/usr/local/lib/"));
		}
	}

	/**
		@return Default directory path of HashLink files to be included (`*.h`/`*.c`).
	**/
	public static function suggestHashLinkIncludeDirectory(
		hlLibDir: DirectoryRef
	): Maybe<DirectoryRef> {
		return switch Environment.systemType {
			case Windows: hlLibDir.tryFindDirectory("./include");
			case Mac: Maybe.none();
		}
	}

	/**
		List of environment variable names for searching HashLink installation directory.
	**/
	static final hlPathEnvVarCandidates = [
		"HASHLINKPATH",
		"HASHLINK",
		"HASHLINK_BIN"
	];

	/**
		Tries to find HashLink installation directory from environment variables.
	**/
	static function searchHashLinkDirectory(): Maybe<DirectoryRef> {
		return hlPathEnvVarCandidates.mapFirst(varName -> {
			final envVarValue = Maybe.from(Sys.getEnv(varName));
			if (envVarValue.isNone()) return Maybe.none();
			return DirectoryPath.from(envVarValue.unwrap()).tryFind();
		});
	}
}
