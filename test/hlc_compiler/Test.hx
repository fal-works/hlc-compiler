package hlc_compiler;

import greeter.Cli;

function testTryProcessArguments() {
	hlc_compiler.Main.tryProcessArguments(TestArguments.get());

	Sys.println("Run the compiled executable...");
	switch Cli.current.type {
		case Unix: Sys.command("open", ["out/bin/main"]);
		case Dos: Sys.command("call", ["out\\bin\\main"]);
	}
}
