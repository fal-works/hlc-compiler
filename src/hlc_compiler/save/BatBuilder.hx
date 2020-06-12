package hlc_compiler.save;

class BatBuilder {
	/**
		Builds content of a Windows batch (`.bat`) file.
	**/
	public static function build(
		outDir: DirectoryRef,
		compileCommandBlock: String,
		filesToCopy: FileList,
		relative: Bool
	): String {
		final outDirStr = switch relative {
			case false: outDir.path.quote(Cli.dos);
			case true: Cli.dos.quoteArgument(outDir.path.toRelative());
		};
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
				final filePath = switch relative {
					case false: file.path.quote(Cli.dos);
					case true: Cli.dos.quoteArgument(file.path.toRelative());
				};
				final copyCommand = 'copy /y $filePath $outDirStr > nul';
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
