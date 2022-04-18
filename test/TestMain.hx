using StringTools;
using Lambda;

function main() {
	heading("testTryProcessArguments()");
	hlc_compiler.Main.tryProcessArguments(TestConfig.getArguments());
	TestConfig.runOutput();

	heading("test Run.n");
	Sys.command("neko", [
		["Run.n"],
		TestConfig.getArguments(),
		[Sys.getCwd()]
	].flatten());
	TestConfig.runOutput();
}

function heading(s: String)
	Sys.println('---- $s'.rpad("-", 80));
