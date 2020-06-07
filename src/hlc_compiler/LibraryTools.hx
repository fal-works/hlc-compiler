package hlc_compiler;

import hlc_compiler.Environment.system;

class LibraryTools {
	/**
		@return Library files required by `srcDir/hlc.json`.
	**/
	public static function getRequiredLibraries(
		hlcJsonFile: FileRef,
		libDir: DirectoryRef
	): LibraryFiles {
		final libDirPath = libDir.path;
		final buildtimeLibs: Array<Library> = [];
		final runtimeFiles: Array<FileRef> = [];

		inline function addDll(fileName: String)
			runtimeFiles.push(FileRef.from('$libDirPath$fileName'));

		final hlcJsonData: HlcJson = haxe.Json.parse(hlcJsonFile.getContent());

		for (lib in hlcJsonData.libs) {
			switch lib {
				case "std":
					switch system {
						case Windows:
							buildtimeLibs.push(Name("libhl")); // "-lhl" seems to hit another file
							addDll("libhl.dll");
						case Mac:
							buildtimeLibs.push(Name("hl"));
							// Seems it's not required at runtime
					}
				case "openal":
					switch system {
						case Windows:
							buildtimeLibs.push(Name("openal"));
							addDll("openal.hdll");
							addDll("OpenAL32.dll");
						case Mac:
							// TODO: test
							buildtimeLibs.push(Name("openal"));
							addDll("openal.hdll");
					}
				case "sdl":
					switch system {
						case Windows:
							buildtimeLibs.push(Name("sdl2"));
							addDll("sdl.hdll");
							addDll("SDL2.dll");
						case Mac:
							// TODO: test
							buildtimeLibs.push(Name("sdl2"));
							addDll("sdl.hdll");
					}
				default:
					final hdllPath = libDirPath.makeFilePath('$lib.hdll');
					switch system {
						case Windows:
							// final libPath = libDirPath.makeFilePath('$lib.lib'); // Don't know why but *.lib files don't work
							final dllPath = libDirPath.makeFilePath('$lib.dll');
							final file = FileRef.from(hdllPath.or(dllPath));
							buildtimeLibs.push(File(file)); // not -l
							runtimeFiles.push(file);
						case Mac:
							// TODO: test
							final aPath = libDirPath.makeFilePath('$lib.a').or(libDirPath.makeFilePath('lib$lib.a'));
							final dylibPath = libDirPath.makeFilePath('$lib.dylib').or(libDirPath.makeFilePath('lib$lib.dylib'));
							buildtimeLibs.push(Name(lib));
							runtimeFiles.push(FileRef.from(hdllPath.or(dylibPath)));
					}
			};
		}

		return {
			buildtime: buildtimeLibs,
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
