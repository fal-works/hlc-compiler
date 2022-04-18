using StringTools;

function main() {
	heading("testTryProcessArguments()");
	hlc_compiler.Test.testTryProcessArguments();
}

function heading(s:String)
	Sys.println('---- $s'.rpad("-", 80));
