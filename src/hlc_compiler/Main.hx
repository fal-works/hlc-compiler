package hlc_compiler;

import hlc_compiler.OptionsParser.parseOptions;

/**
	Entry point to be called directly.
	Not used if called from `haxelib`.
**/
function main(): Void {
	Common.tryDo(() -> parseRun(Sys.args()));
}

/**
	Parses the given arguments and then runs the main process of `hlc-compiler`.
**/
function parseRun(args: Array<RawArgument>): Void {
	parseOptions(args).may(HlcCompiler.run);
}
