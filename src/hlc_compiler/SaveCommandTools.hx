package hlc_compiler;

class SaveCommandTools {
	/**
		Saves commands (including `gcc`) as a Windows batch file (`.bat`).
	**/
	public static function saveGccBat(
		savePath: FilePath,
		outDir: DirectoryRef,
		gccCommand: CommandLine,
		filesToCopy: Array<FileRef>
	): Void {
		final content = BatBuilder.build(
			outDir,
			gccCommand.format(Cli.dos),
			filesToCopy
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
