package hlc_compiler.gcc;

/**
	Arguments to be passed to `gcc` command.
**/
typedef GccArguments = {
	final outFilePath: FilePath;
	final includeDirectories: Array<DirectoryRef>;
	final libraryDirectory: DirectoryRef;
	final exOptions: Array<String>;
	final files: Array<FileRef>;
}
