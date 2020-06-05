package hlc_compiler.gcc;

/**
	Arguments to be passed to `gcc` command.
**/
typedef GccArguments = {
	final outFile: FilePath;
	final includes: Array<DirectoryRef>;
	final exOptions: Array<String>;
	final files: Array<FileRef>;
}
