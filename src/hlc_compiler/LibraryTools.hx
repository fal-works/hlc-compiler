package hlc_compiler;

import hlc_compiler.Environment.system;

class LibraryTools {
	/**
		@return Library files required by `srcDir/hlc.json`.
	**/
	public static function getRequiredLibraries(
		hlcJsonFile: FileRef,
		hlDir: DirectoryRef
	): LibraryFiles {
		final hlDirPath = hlDir.path;
		final buildFiles: Array<FileRef> = [];
		final runtimeFiles: Array<FileRef> = [];

		inline function addLink(fileName: String)
			buildFiles.push(FileRef.from('$hlDirPath$fileName'));

		inline function addDll(fileName: String)
			runtimeFiles.push(FileRef.from('$hlDirPath$fileName'));

		final hlcJsonData: HlcJson = haxe.Json.parse(hlcJsonFile.getContent());

		for (lib in hlcJsonData.libs) {
			switch lib {
				case "std":
					switch system {
						case Windows:
							addLink("libhl.lib");
							addDll("libhl.dll");
						case Mac:
							addLink("libhl.dylib");
							// Seems it's not required at runtime
					}
				case "openal":
					switch system {
						case Windows:
							addLink("openal.lib");
							addDll("openal.hdll");
							addDll("OpenAL32.dll");
						case Mac:
							// TODO: test
							addLink("openal.hdll");
							addDll("openal.hdll");
					}
				case "sdl":
					switch system {
						case Windows:
							addLink("libsdl2.lib");
							addDll("sdl.hdll");
							addDll("SDL2.dll");
						case Mac:
							// TODO: test
							addLink("libsdl2.a");
							addDll("sdl.hdll");
					}
				default:
					final hdllPath = hlDirPath.makeFilePath('$lib.hdll');
					switch system {
						case Windows:
							// final libPath = hlDirPath.makeFilePath('$lib.lib'); // Don't know why but *.lib files don't work
							final dllPath = hlDirPath.makeFilePath('$lib.dll');
							final file = FileRef.from(hdllPath.or(dllPath));
							buildFiles.push(file);
							runtimeFiles.push(file);
						case Mac:
							// TODO: test
							final aPath = hlDirPath.makeFilePath('$lib.a').or(hlDirPath.makeFilePath('lib$lib.a'));
							final dylibPath = hlDirPath.makeFilePath('$lib.dylib').or(hlDirPath.makeFilePath('lib$lib.dylib'));
							buildFiles.push(FileRef.from(aPath.or(hdllPath).or(dylibPath)));
							runtimeFiles.push(FileRef.from(hdllPath.or(dylibPath)));
					}
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
