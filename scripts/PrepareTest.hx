private function main() {
	Sys.command("haxe", ["hxml/prepare-test.hxml"]);
	Sys.println("Generated HL/C for test.");
}
