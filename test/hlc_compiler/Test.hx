package hlc_compiler;

import greeter.Cli;

function testTryProcessArguments() {
	final args = "--srcDir test/src-c --outDir out/bin --copyRuntimeFiles --saveCmd out/compile".split(" ");

	switch Cli.current.type {
		case Unix:
		case Dos:
			args.push("--exFile");
			args.push("C:/Windows/System32/dbghelp.dll");
	}

	hlc_compiler.Main.tryProcessArguments(args);

	Sys.println("Run the compiled executable...");
	switch Cli.current.type {
		case Unix: Sys.command("open", ["out/bin/main"]);
		case Dos: Sys.command("call", ["out\\bin\\main"]);
	}
}
