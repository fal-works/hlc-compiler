package hlc_compiler;

class LibraryTools {
	/**
		@return Library files required by `srcDir/hlc.json`.
	**/
	public static function getRequiredLibraries(
		hlcJsonFile: FileRef,
		libDir: DirectoryRef
	): LibraryList {
		final libDirPath = libDir.path;
		final libs: Array<Library> = [];

		final hlcJsonData: HlcJson = haxe.Json.parse(hlcJsonFile.getContent());
		final systemType = Environment.system.type;

		for (lib in hlcJsonData.libs) {
			switch lib {
				case "std":
					switch systemType {
						case Windows:
							libs.push(Static(Name("libhl"))); // "-lhl" seems to hit another file
							libs.push(Shared(libDir.findFile("libhl.dll")));
						case Mac:
							libs.push(Static(Name("hl")));
							// Seems it's not required at runtime
					}
				case "openal":
					switch systemType {
						case Windows:
							libs.push(Static(Name("openal")));
							libs.push(Shared(libDir.findFile("openal.hdll")));
							libs.push(Shared(libDir.findFile("OpenAL32.dll")));
						case Mac:
							// TODO: test
							libs.push(Static(Name("openal")));
							libs.push(Shared(libDir.findFile("openal.hdll")));
					}
				case "sdl":
					switch systemType {
						case Windows:
							libs.push(Static(Name("sdl2")));
							libs.push(Shared(libDir.findFile("sdl.hdll")));
							libs.push(Shared(libDir.findFile("SDL2.dll")));
						case Mac:
							// TODO: test
							libs.push(Static(Name("sdl2")));
							libs.push(Shared(libDir.findFile("sdl.hdll")));
					}
				default:
					final hdllPath = libDirPath.makeFilePath('$lib.hdll');
					switch systemType {
						case Windows:
							// final libPath = libDirPath.makeFilePath('$lib.lib'); // Don't know why but *.lib files don't work
							final dllPath = libDirPath.makeFilePath('$lib.dll');
							final file = FileRef.from(hdllPath.or(dllPath));
							libs.push(Static(File(file)));
							libs.push(Shared(file));
						case Mac:
							// TODO: test
							// final aPath = libDirPath.makeFilePath('$lib.a').or(libDirPath.makeFilePath('lib$lib.a'));
							final dylibPath = libDirPath.makeFilePath('$lib.dylib').or(libDirPath.makeFilePath('lib$lib.dylib'));
							libs.push(Static(Name(lib)));
							libs.push(Shared(FileRef.from(hdllPath.or(dylibPath))));
					}
			};
		}

		return libs;
	}
}

/**
	Content of `hlc.json`.
**/
typedef HlcJson = {
	final libs: Array<String>;
};
