package hlc_compiler;

/**
	List of library files, both for build and runtime.
**/
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
