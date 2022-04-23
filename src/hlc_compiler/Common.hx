package hlc_compiler;

import hlc_compiler.internal.Constants;

/**
	Prints version info of this library.
**/
function showVersion(emptyLineBefore: Bool, emptyLineAfter: Bool): Void {
	showText(
		'$libName v$version\n  $haxelibUrl',
		emptyLineBefore,
		emptyLineAfter
	);
}

/**
	Prints hint message.
**/
function showHint(emptyLineBefore: Bool, emptyLineAfter: Bool): Void {
	showText(
		'For a list of options, see:\n  $repositoryUrl',
		emptyLineBefore,
		emptyLineAfter
	);
}

/**
	Wraps `proc` with a `try`-`catch` block.

	If caught any exception, prints it with a hint info and exits the current process with code `1`.
**/
inline function tryDo(proc: () -> Void): Void {
	try {
		proc();
	} catch (e) {
		printError(e);
		Common.showHint(true, true);
		Sys.exit(1);
	}
}

/**
	Prints text with or without empty lines.
**/
private function showText(
	text: String,
	emptyLineBefore: Bool,
	emptyLineAfter: Bool
): Void {
	if (emptyLineBefore) Sys.println("");
	Sys.println(text);
	if (emptyLineAfter) Sys.println("");
}
