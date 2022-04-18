import sys.FileSystem;
import greeter.Cli;

using Lambda;

function getArguments(): Array<String> {
	var args = [];
	args.push('--srcDir test/src-c');
	args.push('--outDir out/bin');
	args.push('--copyRuntimeFiles');
	switch Cli.current.type {
		case Unix:
		case Dos:
			args.push('--exFile C:/Windows/System32/dbghelp.dll');
	}

	return args.join(" ").split(" ");
}

function clearOutput() {
	deleteRecursive("out/bin");
}

function runOutput() {
	Sys.println("Run the compiled executable...");
	switch Cli.current.type {
		case Unix: Sys.command("open", ["out/bin/main"]);
		case Dos: Sys.command("call", ["out\\bin\\main"]);
	}
}

private function deleteRecursive(path: String) {
	if (!FileSystem.exists(path)) return;
	if (!FileSystem.isDirectory(path)) {
		FileSystem.deleteFile(path);
		return;
	}

	FileSystem.readDirectory(path).map(x -> '$path/$x').iter(deleteRecursive);
	FileSystem.deleteDirectory(path);
}
