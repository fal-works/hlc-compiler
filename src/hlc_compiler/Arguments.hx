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
		HashLink installation directory containing HDLL and other library files.
	**/
	final hlDir: DirectoryRef;

	/**
		`true` if DLL files should be copied to the output directory.
	**/
	final copyDlls: Bool;

	/**
		Additional files that should be passed to GCC.
		These are not copied to the destination directory.
	**/
	final exFiles: Array<FileRef>;

	/**
		Additional files that should be passed to GCC.
		Unlike `exFiles`, these are also copied if `copyDlls` is `true`.
	**/
	final exDlls: Array<FileRef>;

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
