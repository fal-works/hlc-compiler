package hlc_compiler.gcc;

/**
	Data object representing a `gcc` command with specific arguments.
**/
typedef Command = {
	final outFile: FilePath;
	final includes: Array<DirectoryRef>;
	final exOptions: Array<String>;
	final files: Array<FileRef>;
}
