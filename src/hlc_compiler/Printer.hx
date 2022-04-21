package hlc_compiler;

/**
	Prints `message` in yellow with a warning prefix.
**/
function warn(message: String): Void {
	final msg = '[WARNING] $message';
	Sys.println('\u001b[33m${msg}\u001b[0m');
}

/**
	Prints `exception` in red with an error prefix.
**/
function printError(exception: haxe.Exception): Void {
	final msg = '[ERROR] Caught exception:\n$exception';
	Sys.println('\u001b[31m${msg}\u001b[0m');
}
