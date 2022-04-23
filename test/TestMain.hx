import hlc_compiler.Main.parseRun;

using Lambda;
using StringTools;

function main() {
	final args = Sys.args();

	if (args.has("all")) testAll();
	else if (args.has("main")) testMain();
	else if (args.has("neko")) testNeko();
	else testParseRun();
}

function testAll() {
	testParseRun();
	testMain();
	testNeko();
}

function testParseRun() {
	heading("test parseRun()");
	TestConfig.clearOutput();
	parseRun(TestConfig.getTestArguments());
	TestConfig.runOutput();
}

function testMain() {
	heading("test main()");
	TestConfig.clearOutput();
	Sys.command("haxe", [
		["hxml/test-main-func.hxml"],
		TestConfig.getTestArguments(),
	].flatten());
	TestConfig.runOutput();
}

function testNeko() {
	heading("test Run.n");
	TestConfig.clearOutput();
	// Emulating call by haxelib
	Sys.command("neko", [
		["Run.n"],
		TestConfig.getTestArguments(),
		[Sys.getCwd()]
	].flatten());
	TestConfig.runOutput();
}

function heading(s: String)
	Sys.println('---- $s '.rpad("-", 80));
