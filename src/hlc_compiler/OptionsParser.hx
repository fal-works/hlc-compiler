package hlc_compiler;

import hlc_compiler.types.Arguments;

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
			Common.showVersion(true, true);
			Common.showHint(false, true);
			Maybe.none();

		default:
			Maybe.from(Arguments.from(argSummary));
	}
}
