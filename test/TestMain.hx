import hlc_compiler.Main.parseRun;

using Lambda;
using StringTools;

function main() {
	heading("test parseRun()");
	TestConfig.clearOutput();
	parseRun(TestConfig.getArguments());
	TestConfig.runOutput();

	heading("test Run.n");
	TestConfig.clearOutput();
	Sys.command("neko", [
		["Run.n"],
		TestConfig.getArguments(),
		[Sys.getCwd()]
	].flatten());
	TestConfig.runOutput();
}

function heading(s: String)
	Sys.println('---- $s '.rpad("-", 80));
