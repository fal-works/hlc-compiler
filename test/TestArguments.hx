import greeter.Cli;

function get(): Array<String> {
	var args = [];
	args.push('--srcDir test/src-c');
	args.push('--outDir out/bin');
	args.push('--copyRuntimeFiles');
	args.push('--saveCmd out/compile');
	switch Cli.current.type {
		case Unix:
		case Dos:
			args.push('--exFile C:/Windows/System32/dbghelp.dll');
	}

	return args.join(" ").split(" ");
}
