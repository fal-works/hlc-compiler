package hlc_compiler;

import haxe.Json;
import sys.io.File;

/**
	Reads `version` in `haxelib.json` and returns it as `String`.
**/
macro function getVersion() {
	final ver = Json.parse(File.getContent("haxelib.json")).version;

	if (!Std.isOfType(ver, String)) throw 'Cannot read version in haxelib.json';

	return macro $v{ver};
}
