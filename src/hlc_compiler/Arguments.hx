package hlc_compiler;

/**
	Half-validated arguments that have been passed to hlc-compiler.
**/
@:notNull @:forward
abstract Arguments(Data) from Data {
	public inline function print(indent = "") {
		Sys.println('${indent}srcDir:           ${this.srcDir}');
		Sys.println('${indent}outFile:          ${this.outFile}');
		Sys.println('${indent}libDir:           ${this.libDir}');
		Sys.println('${indent}includeDir:       ${this.includeDir}');
		Sys.println('${indent}copyRuntimeFiles: ${this.copyRuntimeFiles}');
		Sys.println('${indent}exFiles:          ${this.exFiles}');
		Sys.println('${indent}exLibs:           ${this.exLibs}');
		Sys.println('${indent}exOptions:        ${this.exOptions}');
		Sys.println('${indent}saveCmd:          ${this.saveCmdPath.toString()}');
	}
}

private typedef Data = {
	/**
		Directory containing `main.c` and `hlc.json`.
	**/
	final srcDir: DirectoryRef;

	/**
		Output file path.
	**/
	final outFile: FilePath;

	/**
		Directory containing `*.hdll` and other library files.
	**/
	final libDir: DirectoryRef;

	/**
		Directory containing HL files to be included (such as `hlc.h`).
		Is not mandatory because the directory may be automatically searched by `gcc` (especially if not Windows).
	**/
	final includeDir: Maybe<DirectoryRef>;

	/**
		`true` if files that are required at runtime should be copied to the output directory.
	**/
	final copyRuntimeFiles: Bool;

	/**
		Additional files that should be passed to GCC.
		These are not copied to the destination directory.
	**/
	final exFiles: Array<FileRef>;

	/**
		Additional files that should be passed to GCC.
		Unlike `exFiles`, these are also copied if `copyRuntimeFiles` is `true`.
	**/
	final exLibs: Array<FileRef>;

	/**
		Additional options that should be passed to GCC.
	**/
	final exOptions: Array<String>;

	/**
		The file path where the command should be saved.
		Does not emit file if `null`.
	**/
	final saveCmdPath: Maybe<FilePath>;

	/**
		`true` if verbose logging should be enabled.
	**/
	final verbose: Bool;
};
