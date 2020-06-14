package hlc_compiler.save;

class ShellCommandBuilder {
	/**
		Builds content of a shell command file.
	**/
	public static function build(
		outDir: DirectoryRef,
		compileCommandBlock: String,
		filesToCopy: FileList,
		relative: Bool
	): String {
		final cli = Cli.unix;
		final outDirStr = switch relative {
			case false: outDir.path.quote(cli);
			case true: cli.quoteArgument(outDir.path.toRelative());
		};
		final mkOutDirCmd = 'mkdir -p $outDirStr';
		final mkDirCatcher = exitIfError("Failed to prepare output directory. Aborting.");

		final contents = [
			"#!/bin/sh",
			'$mkOutDirCmd\n$mkDirCatcher',
			"echo Compiling...",
			compileCommandBlock.trim(),
			exitIfError("Compilation command failed. Aborting.")
		];

		if (0 < filesToCopy.length) {
			contents.push("echo Copying runtime files...");
			for (file in filesToCopy) {
				final filePath = switch relative {
					case false: file.path.quote(cli);
					case true: cli.quoteArgument(file.path.toRelative());
				};
				final copyCommand = 'cp $filePath $outDirStr';
				final catcher = exitIfError("Copy failed. Aborting.");
				contents.push('$copyCommand\n$catcher');
			}
		}

		contents.push("echo Completed.");

		return contents.join("\n\n") + "\n";
	}

	/**
		@return Shell command block for aborting on any error.
	**/
	static function exitIfError(message: String): String
		return 'trap \'echo $message\' ERR';
}
