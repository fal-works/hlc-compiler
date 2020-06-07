package hlc_compiler;

/**
	Library specifier.
**/
enum Library {
	/**
		Library specified by a name and can be linked by `-l` option of `gcc`.
	**/
	Name(s: String);

	/**
		Library specified by a file path.
	**/
	File(file: FileRef);
}
