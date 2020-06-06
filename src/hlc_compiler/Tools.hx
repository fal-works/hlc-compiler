package hlc_compiler;

import haxe.SysTools;

/**
	Common static utility functions.
**/
class Tools {
	/**
		`true` if the program is running on Windows.
	**/
	public static final windows = Sys.systemName() == "Windows";

	/**
		@return String that can be used as a single command line argument on the current OS.
		On Windows, slash is replaced with backslash.
	**/
	public static inline function quoteCommandArgument(s: String): String {
		return if (windows) {
			SysTools.quoteWinArg(s.replace("/", "\\"), true);
		} else SysTools.quoteUnixArg(s);
	}
}
