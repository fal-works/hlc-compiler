package hlc_compiler.save;

class SaveCommandTools {
	/**
		Saves commands (including `gcc`) as a Windows batch file (`.bat`).
	**/
	public static function saveCommandShell(
		savePath: FilePath,
		outDir: DirectoryRef,
		compileCommand: CommandLine,
		filesToCopy: Array<FileRef>,
		relative: Bool
	): Void {
		final content = ShellCommandBuilder.build(
			outDir,
			compileCommand.format(Cli.unix),
			filesToCopy,
			relative
		);

		saveFile(savePath, content, "command");
	}

	/**
		Saves commands (including `gcc`) as a Windows batch file (`.bat`).
	**/
	public static function saveCommandBat(
		savePath: FilePath,
		outDir: DirectoryRef,
		compileCommand: CommandLine,
		filesToCopy: Array<FileRef>,
		relative: Bool
	): Void {
		final content = BatchBuilder.build(
			outDir,
			compileCommand.format(Cli.dos),
			filesToCopy,
			relative
		);

		saveFile(savePath, content, "bat");
	}

	/**
		Saves `content` in the file specified by `savePath`.
	**/
	static function saveFile(
		savePath: FilePath,
		content: String,
		defaultExtension: String
	): Void {
		if (savePath.getExtension().isNone())
			savePath = savePath.setExtension(defaultExtension);

		savePath.saveContent(content);
	}
}