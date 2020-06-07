package hlc_compiler;

class BatBuilder {
	/**
		Builds content of a Windows batch (`.bat`) file.
	**/
	public static function build(
		outDir: DirectoryRef,
		compileCommandBlock: String,
		filesToCopy: FileList
	): String {
		final outDirStr = outDir.path.quote();
		final mkOutDirCmd = 'if not exist $outDirStr ^\nmkdir $outDirStr';
		final mkDirCatcher = exitIfError("Failed to prepare output directory. Aborting.");

		final contents = [
			"@echo off",
			'$mkOutDirCmd\n$mkDirCatcher',
			"echo Running GCC command...",
			compileCommandBlock.trim(),
			exitIfError("GCC command failed. Aborting.")
		];

		if (0 < filesToCopy.length) {
			contents.push("echo Copying runtime files...");
			for (file in filesToCopy) {
				final copyCommand = 'copy /y ${file.path.quote()} $outDirStr > nul';
				final catcher = exitIfError("Copy failed. Aborting.");
				contents.push('$copyCommand\n$catcher');
			}
		}

		contents.push("echo Completed.");

		return contents.join("\n\n") + "\n";
	}

	/**
		@return BAT command block for aborting on any error.
	**/
	static function exitIfError(message: String): String
		return 'if %ERRORLEVEL% neq 0 (\n  echo $message\n  exit /b 1\n)';
}
