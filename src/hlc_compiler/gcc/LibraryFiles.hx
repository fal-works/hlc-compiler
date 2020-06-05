package hlc_compiler.gcc;

typedef LibraryFiles = {
	/**
		Files to be linked when compiling.
	**/
	final build: Array<FileRef>;

	/**
		Files to be linked when run.
	**/
	final runtime: Array<FileRef>;
};
