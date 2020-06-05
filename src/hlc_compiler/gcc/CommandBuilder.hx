package hlc_compiler.gcc;

class CommandBuilder {
	public static function build(
		arguments: Arguments
	): { command: Command, libraryFiles: LibraryFiles } {
		final srcDir = arguments.srcDir;
		final outFile = arguments.outFile;
		final hlDir = arguments.hlDir;

		final srcFile = srcDir.path.makeFilePath("main.c").find();
		final libraryFiles = getLibraryFiles(srcDir, hlDir);

		final includes = [hlDir.path.concat("include").find(), srcDir];
		final files: Array<FileRef> = [
			[srcFile],
			arguments.exFiles,
			arguments.exDlls,
			libraryFiles.build
		].flatten();

		final command: Command = {
			outFile: outFile,
			includes: includes,
			exOptions: arguments.exOptions,
			files: files
		};

		return {
			command: command,
			libraryFiles: libraryFiles
		};
	}

	static function getLibraryFiles(
		srcDir: DirectoryRef,
		hlDir: DirectoryRef
	): LibraryFiles {
		final hlDirPath = hlDir.path;
		final buildFiles: Array<FileRef> = [];
		final runtimeFiles: Array<FileRef> = [];

		inline function addLink(fileName: String)
			buildFiles.push(FileRef.from('$hlDirPath$fileName'));

		inline function addDll(fileName: String)
			runtimeFiles.push(FileRef.from('$hlDirPath$fileName'));

		final jsonFile = FileRef.from(srcDir + "hlc.json");
		final jsonData: JsonData = haxe.Json.parse(jsonFile.getContent());

		for (lib in jsonData.libs) {
			switch lib {
				case "std":
					addLink("libhl.lib");
					addDll("libhl.dll");
				case "openal":
					addLink("openal.lib");
					addDll("openal.hdll");
					addDll("OpenAL32.dll");
				case "sdl":
					addLink("sdl.lib");
					addDll("sdl.hdll");
					addDll("SDL2.dll");
				default:
					final libPath = FilePath.from('$hlDirPath$lib.lib');
					final hdllPath = FilePath.from('$hlDirPath$lib.hdll');
					final dllPath = FilePath.from('$hlDirPath$lib.dll');
					buildFiles.push(libPath.or(hdllPath).or(dllPath));
					runtimeFiles.push(hdllPath.or(dllPath));
			};
		}

		return {
			build: buildFiles,
			runtime: runtimeFiles
		};
	}
}
