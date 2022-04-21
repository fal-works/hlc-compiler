private function main() {
	Sys.command("haxe", ["hxml/build.hxml"]);
	Sys.println('Built neko bytecode of hlc-compiler.');
}
