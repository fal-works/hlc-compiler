package hlc_compiler.gcc;

using locator.Statics;

class CommandExtensions {
	static final withValue = ~/([^=]+=)([ .]+)/i;

	@:access(hlc_compiler.gcc.SanitizedCommand)
	public static function sanitize(command: Command): SanitizedCommand {
		final argLines: Array<String> = [];

		argLines.push('-o ${command.outFile.quote()}');

		for (dir in command.includes)
			argLines.push('-I ${dir.path.quote()}');

		for (option in command.exOptions)
			argLines.push(sanitizeExOption(option));

		for (file in command.files)
			argLines.push(file.path.quote());

		return new SanitizedCommand(argLines);
	}

	static function sanitizeExOption(option: String) {
		if (!option.startsWith("-")) return option.quote();
		if (withValue.match(option)) return withValue.matched(1) + withValue.matched(2).quote();
		return option;
	}
}
