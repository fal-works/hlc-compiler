package hlc_compiler;

import hlc_compiler.Macros.getVersion;

/**
	Common static fields.
**/
class Common {
	/**
		The name of this library.
	**/
	public static inline final libName = "hlc-compiler";

	/**
		The version of this library.
	**/
	public static inline final version: String = getVersion();

	/**
		The URL of the repository.
	**/
	public static inline final repositoryUrl = 'https://github.com/fal-works/$libName';

	/**
		The URL of haxelib page.
	**/
	public static inline final haxelibUrl = 'https://lib.haxe.org/p/$libName';

	/**
		Prints version info of this library.
	**/
	public static function showVersion(emptyLineBefore: Bool, emptyLineAfter: Bool): Void {
		showText(
			'$libName $version\n  $haxelibUrl',
			emptyLineBefore,
			emptyLineAfter
		);
	}

	/**
		Prints hint message.
	**/
	public static function showHint(emptyLineBefore: Bool, emptyLineAfter: Bool): Void {
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
	public static inline function tryDo(proc: () -> Void): Void {
		try {
			proc();
		} catch (e) {
			Sys.println('Caught exception:\n$e');
			Common.showHint(true, true);
			Sys.exit(1);
		}
	}

	/**
		Prints text with or without empty lines.
	**/
	static function showText(
		text: String,
		emptyLineBefore: Bool,
		emptyLineAfter: Bool
	): Void {
		if (emptyLineBefore) Sys.println("");
		Sys.println(text);
		if (emptyLineAfter) Sys.println("");
	}
}
