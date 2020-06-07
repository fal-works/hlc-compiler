package hlc_compiler;

/**
	Library specifier.
	Either just a name (can be linked by *-l* option) or a specific file path.
**/
enum Library {
	Name(s: String);
	File(file: FileRef);
}
