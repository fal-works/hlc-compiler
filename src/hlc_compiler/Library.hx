package hlc_compiler;

/**
	Library to be linked with executable.
**/
enum Library {
	/**
		Library to be linked statically in buildtime.
	**/
	Static(nameOrFile: LibrarySpecifier);

	/**
		Library to be linked in runtime.
	**/
	Shared(file: FileRef);

	/**
		Library required both in buildtime and runtime.
	**/
	StaticShared(file: FileRef, name: Maybe<String>);
}
