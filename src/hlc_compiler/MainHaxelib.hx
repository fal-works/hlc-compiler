package hlc_compiler;

/**
	Entry point to be called from `haxelib run hlc-compiler`.

	The last argument should be the current working directory.
**/
function main(): Void {
	Common.tryDo(() -> Main.parseRun(processHaxelibArguments()));
}

/**
	Reads arguments via `Sys.args()`,
	consumes the last one as the current working directory
	and returns the rest.
**/
function processHaxelibArguments(): Array<RawArgument> {
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
