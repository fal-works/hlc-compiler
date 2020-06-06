package hlc_compiler;

import hlc_compiler.gcc.GccCommand;

class SaveCommandTools {
	/**
		Saves commands (including `gcc`) as a Windows batch file (`.bat`).
	**/
	public static function saveGccBat(
		savePath: FilePath,
		outDir: DirectoryRef,
		gccCommand: GccCommand,
		filesToCopy: Array<FileRef>
	): Void {
		final gccCommandBlock = ["gcc"].concat(gccCommand.getArgumentLines()).join(" ^\n");
		final content = BatBuilder.build(outDir, gccCommandBlock, filesToCopy);

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
