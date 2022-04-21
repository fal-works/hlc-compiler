package hlc_compiler;

function warn(message:String):Void {
	final msg = '[WARNING] $message';
	Sys.println('\u001b[33m${msg}\u001b[0m');
}
