package hlc_compiler.types;

// TODO: optional constructor args

/**
	Sanitized arguments for hlc-compiler, completed with default values.
	Converted from command line arguments.
**/
@:structInit
class Arguments {
	/**
		Directory containing `main.c` and `hlc.json`.
	**/
	public final srcDir: DirectoryRef;

	/**
		Source `*.c` file.
	**/
	public final srcFile: FileRef;

	/**
		`hlc.json` in the HL/C source directory.
	**/
	public final hlcJsonFile: FileRef;

	/**
		Output file path.
	**/
	public final outFile: FilePath;

	/**
		Output directory path.
	**/
	public final outDir: DirectoryPath;

	/**
		Directory containing `*.hdll` and other library files bundled with HashLink.
	**/
	public final hlLibDir: DirectoryRef;

	/**
		Directory containing HL files to be included (such as `hlc.h`).
		Is not mandatory because the directory may be automatically searched by the C compiler (especially if not Windows).
	**/
	public final hlIncludeDir: Maybe<DirectoryRef>;

	/**
		`true` if files that are required at runtime should be copied to the output directory.
	**/
	public final copyRuntimeFiles: Bool;

	/**
		Additional files that should be passed to the C compiler.
		These are not copied to the destination directory.
	**/
	public final exFiles: Array<FileRef>;

	/**
		Additional files that should be copied if `--copyRuntimeFiles` is specified.
		No effect on compilation.
	**/
	public final runtime: FileOrDirectoryList;

	/**
		Additional options that should be passed to the C compiler.
	**/
	public final exOptions: Array<String>;

	/**
		The file path where the command should be saved.
		Does not emit file if `null`.
	**/
	public final saveCmdPath: Maybe<FilePath>;

	/**
		`true` if file/directory paths should be converted to relative paths when creating commands lines.
	**/
	public final relative: Bool;

	/**
		C compiler to use. Either `gcc` or `clang`.
	**/
	public final compiler: CCompiler;

	/**
		`true` if verbose logging should be enabled.
	**/
	public final verbose: Bool;

	/**
		Formats `this`.
	**/
	public inline function format(indent = ""): String {
		var s = "";
		s += '${indent}srcDir:           ${this.srcDir.toString()}\n';
		s += '${indent}srcFile:          ${this.srcFile.toString()}\n';
		s += '${indent}hlcJsonFile:      ${this.hlcJsonFile.toString()}\n';
		s += '${indent}outDir:           ${this.outDir.toString()}\n';
		s += '${indent}outFile:          ${this.outFile.toString()}\n';
		s += '${indent}hlLibDir:         ${this.hlLibDir.toString()}\n';
		s += '${indent}hlIncludeDir:     ${this.hlIncludeDir.toString()}\n';
		s += '${indent}copyRuntimeFiles: ${this.copyRuntimeFiles}\n';
		s += '${indent}exFiles:          ${this.exFiles.toString()}\n';
		s += '${indent}runtime:          ${this.runtime.toString()}\n';
		s += '${indent}exOptions:        ${this.exOptions.toString()}\n';
		s += '${indent}relative:         ${this.relative}\n';
		s += '${indent}compiler:         ${this.compiler}\n';
		s += '${indent}saveCmd:          ${this.saveCmdPath.toString()}';
		return s;
	}

	/**
		@return `this` as a formatted `String`.
	**/
	public function toString(): String
		return format();
}

enum abstract CCompiler(String) to String {
	final Gcc = "gcc";
	final Clang = "clang";
}
