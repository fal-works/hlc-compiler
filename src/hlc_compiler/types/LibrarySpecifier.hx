package hlc_compiler.types;

/**
	Either name or file of a library.
**/
@:using(LibrarySpecifier.LibrarySpecifierExtension)
enum LibrarySpecifier {
	/**
		Library specified by a name and can be linked by `-l` option of `gcc`.
	**/
	Name(s: String);

	/**
		Library specified by a file path.
	**/
	File(file: FileRef);
}

class LibrarySpecifierExtension {
	/**
		Checks if `this` can be used in `cli`. If not, throws an error.
		No effect if `this` is `Name`.
		@return `String` representation of `this`.
	**/
	public static function validatePathString(_this: LibrarySpecifier, cli: Cli): String {
		return switch _this {
			case Name(s): s;
			case File(file): file.path.validate(cli).toString();
		}
	}

	/**
		@return `String` that can be used in `cli`.
	**/
	public static function quote(_this: LibrarySpecifier, cli: Cli): String {
		return switch _this {
			case Name(s): cli.quoteArgument(s);
			case File(file): file.path.quote(cli);
		}
	}
}
