package hlc_compiler;

/**
	Either name or file of a library.
**/
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
