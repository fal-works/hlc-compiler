package hlc_compiler;

import hlc_compiler.OptionsParser.parseOptions;

class Main {
	/**
		Entry point to be called from `haxelib run hlc-compiler`.

		The last argument should be the current working directory.
	**/
	public static function main(): Void {
		tryProcessArguments(processHaxelibArguments());
	}

	/**
		Reads arguments via `Sys.args()`,
		consumes the last one as the current working directory
		and returns the rest.
	**/
	static function processHaxelibArguments():Array<RawArgument> {
		final args: Array<String> = Sys.args();

		inline function cwdError() {
			var msg = 'Cannot get current working directory.';
			msg += '\n  Passed command arguments (the last should be the cwd):';
			msg += '\n  ${Sys.args().join(" ")}';
			throw error(msg);
		}

		final lastArg = args.pop();
		if (lastArg.isNone()) cwdError();
		final cwdPath = DirectoryPath.from(lastArg.unwrap());
		if (!cwdPath.exists()) cwdError();

		cwdPath.find().setAsCurrent();

		return args;
	}

	/**
		Tries to process `args`.
		If caught any exception, prints it with a hint info and exits the current process with return code `1`.
		@param args Arguments passed to hlc-compiler.
	**/
	public static function tryProcessArguments(args: Array<RawArgument>): Void {
		try {
			parseOptions(args).may(Runner.run);
		} catch (e) {
			Sys.println('Caught exception:\n$e');
			Common.showHint(true, true);
			Sys.exit(1);
		}
	}
}
