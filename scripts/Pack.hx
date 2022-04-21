/**
	Packs files to be published.
	Requires that the `7z` command is available.
**/
private function main() {
	final zipName = "lib.zip";
	final fileList = "public-files.txt";

	if (sys.FileSystem.exists(zipName)) {
		sys.FileSystem.deleteFile(zipName);
		Sys.println('Deleted: $zipName');
	}

	Sys.command("7z", [
		"a",
		"-tzip",
		zipName,
		'@$fileList'
	]);
}
