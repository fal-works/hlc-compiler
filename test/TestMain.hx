using StringTools;
using Lambda;

function main() {
	heading("testTryProcessArguments()");
	TestConfig.clearOutput();
	hlc_compiler.Main.tryProcessArguments(TestConfig.getArguments());
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
	Sys.println('---- $s'.rpad("-", 80));
