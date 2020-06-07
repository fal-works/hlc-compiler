package hlc_compiler;

/**
	Half-validated arguments that have been passed to hlc-compiler.
**/
typedef Arguments = {
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
