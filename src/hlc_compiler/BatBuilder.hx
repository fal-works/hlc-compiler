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

		final contents = [
			"@echo off",
			mkOutDirCmd,
			"echo Running GCC command...",
			compileCommandBlock.trim()
		];

		if (0 < filesToCopy.length) {
			contents.push("echo Copying runtime files...");
			for (file in filesToCopy)
				contents.push('copy ${file.path.quote()} $outDirStr > nul');
		}

		contents.push("echo Completed.");

		return contents.join("\n\n") + "\n";
	}
}
