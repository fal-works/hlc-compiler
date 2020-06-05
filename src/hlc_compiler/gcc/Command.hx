package hlc_compiler.gcc;

typedef Command = {
	final outFile: FilePath;
	final includes: Array<DirectoryRef>;
	final exOptions: Array<String>;
	final files: Array<FileRef>;
}
