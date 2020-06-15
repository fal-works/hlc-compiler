package hlc_compiler.save;

class BatchBuilder {
	/**
		Builds content of a Windows batch (`.bat`) file.
	**/
	public static function build(
		outDir: DirectoryRef,
		compileCommandBlock: String,
		copyList: FileOrDirectoryList,
		relative: Bool
	): String {
		final cli = Cli.dos;
		final outDirStr = switch relative {
			case false: outDir.path.quote(cli);
			case true: cli.quoteArgument(outDir.path.toRelative());
		};
		final mkOutDirCmd = 'if not exist $outDirStr ^\nmkdir $outDirStr';
		final mkDirCatcher = exitIfError("Failed to prepare output directory. Aborting.");

		final contents = [
			"@echo off",
			'$mkOutDirCmd\n$mkDirCatcher',
			"echo Compiling...",
			compileCommandBlock.trim(),
			exitIfError("Compilation command failed. Aborting.")
		];

		if (0 < copyList.length) {
			contents.push("echo Copying runtime files...");
			final copyCatcher = exitIfError("Copy failed. Aborting.");

			for (element in copyList) {
				final srcAbsPath = element.toPath();
				var srcPath = switch relative {
					case false: srcAbsPath.toString();
					case true: srcAbsPath.toRelative();
				};
				if (srcPath.endsWith("\\"))
					srcPath = srcPath.substr(0, srcPath.length - 1);
				srcPath = cli.quoteArgument(srcPath);

				final copyCommand = switch srcAbsPath.toEnum() {
					case File(_):
						'copy /y $srcPath $outDirStr > nul';
					case Directory(path):
						final destPath = outDirStr + path.getName() + "\\";
						'xcopy /y /e $srcPath $destPath > nul';
				};

				contents.push('$copyCommand\n$copyCatcher');
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
