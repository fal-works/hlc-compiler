package hlc_compiler.types;

import haxe.Exception;

/**
	Exception object that may be thrown from `hlc-compiler`.
**/
class HlcCompilerError extends Exception {
	/**
		Alias for `new HlcCompilerError()`.
	**/
	public static function error(
		message: String,
		?previous: Exception,
		?native: Any
	): HlcCompilerError {
		return new HlcCompilerError(message, previous, native);
	}
}
