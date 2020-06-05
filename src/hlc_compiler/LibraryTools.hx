package hlc_compiler;

class LibraryTools {
	/**
		@return Library files required by `srcDir/hlc.json`.
	**/
	public static function getRequiredLibraries(
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

		final hlcJsonFile = FileRef.from(srcDir + "hlc.json");
		final hlcJsonData: HlcJson = haxe.Json.parse(hlcJsonFile.getContent());

		for (lib in hlcJsonData.libs) {
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

/**
	Content of `hlc.json`.
**/
typedef HlcJson = {
	final libs: Array<String>;
};
