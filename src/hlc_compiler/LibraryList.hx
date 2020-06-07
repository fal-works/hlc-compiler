package hlc_compiler;

/**
	List of library files, both for build and runtime.
**/
typedef LibraryList = {
	/**
		Files to be linked when compiling.
	**/
	final buildtime: Array<Library>;

	/**
		Files to be linked when run.
	**/
	final runtime: Array<FileRef>;
};
