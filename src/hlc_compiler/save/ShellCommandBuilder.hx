package hlc_compiler.save;

class ShellCommandBuilder {
	/**
		Builds content of a shell command file.
	**/
	public static function build(
		outDir: DirectoryRef,
		compileCommandBlock: String,
		copyList: FileOrDirectoryList,
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

		if (0 < copyList.length) {
			contents.push("echo Copying runtime files...");
			final copyCatcher = exitIfError("Copy failed. Aborting.");

			for (element in copyList) {
				final srcAbsPath = element.toPath();
				final srcPath = switch relative {
					case false: srcAbsPath.quote(cli);
					case true: cli.quoteArgument(srcAbsPath.toRelative());
				};
				final destPath = outDirStr + switch srcAbsPath.toEnum() {
					case File(path): path.getName();
					case Directory(path): path.getName() + "/";
				};
				final copyCommand = 'cp -r $srcPath $destPath';

				contents.push('$copyCommand\n$copyCatcher');
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
