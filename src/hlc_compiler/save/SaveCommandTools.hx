package hlc_compiler.save;

class SaveCommandTools {
	/**
		Saves commands (including `gcc`) as a shell script.
		@return Path to the saved file (with extension).
	**/
	public static function saveCommandShell(
		savePath: FilePath,
		outDir: DirectoryRef,
		compileCommand: CommandLine,
		filesToCopy: Array<FileRef>,
		relative: Bool
	): FilePath {
		final content = ShellCommandBuilder.build(
			outDir,
			compileCommand.format(Cli.unix),
			filesToCopy,
			relative
		);

		// TODO: use Environment after supporting Linux
		final defaultExtension = switch Sys.systemName() {
			case "Mac": "command";
			default: "sh";
		};
		final savedPath = saveFile(savePath, content, defaultExtension);

		Sys.command("chmod", ["u+x", savedPath]);

		return savedPath;
	}

	/**
		Saves commands (including `gcc`) as a Windows batch file.
		@return Path to the saved file (with extension).
	**/
	public static function saveCommandBat(
		savePath: FilePath,
		outDir: DirectoryRef,
		compileCommand: CommandLine,
		filesToCopy: Array<FileRef>,
		relative: Bool
	): FilePath {
		final content = BatchBuilder.build(
			outDir,
			compileCommand.format(Cli.dos),
			filesToCopy,
			relative
		);

		return saveFile(savePath, content, "bat");
	}

	/**
		Saves `content` in the file specified by `savePath`.
		@return Path to the saved file (with extension).
	**/
	static function saveFile(
		savePath: FilePath,
		content: String,
		defaultExtension: String
	): FilePath {
		if (savePath.getExtension().isNone())
			savePath = savePath.setExtension(defaultExtension);

		savePath.saveContent(content);

		return savePath;
	}
}
