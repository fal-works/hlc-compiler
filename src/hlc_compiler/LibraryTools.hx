package hlc_compiler;

class LibraryTools {
	/**
		@return Library files required by `srcDir/hlc.json`.
	**/
	public static function getRequiredLibraries(
		hlcJsonFile: FileRef,
		hlLibDir: DirectoryRef
	): LibraryList {
		final hlLibDirPath = hlLibDir.path;
		final libs: Array<Library> = [];

		final hlcJsonData: HlcJson = haxe.Json.parse(hlcJsonFile.getContent());
		final systemType = Environment.systemType;

		for (lib in hlcJsonData.libs) {
			switch lib {
				case "std":
					switch systemType {
						case Windows:
							libs.push(Static(Name("libhl"))); // "-lhl" seems to hit another file
							libs.push(Shared(hlLibDir.findFile("libhl.dll")));
						case Mac:
							libs.push(Static(Name("hl")));
							// Seems it's not required at runtime
					}
				case "openal":
					switch systemType {
						case Windows:
							libs.push(Static(Name("openal")));
							libs.push(Shared(hlLibDir.findFile("openal.hdll")));
							libs.push(Shared(hlLibDir.findFile("OpenAL32.dll")));
						case Mac:
							// TODO: test
							libs.push(Static(Name("openal")));
							libs.push(Shared(hlLibDir.findFile("openal.hdll")));
					}
				case "sdl":
					switch systemType {
						case Windows:
							libs.push(Static(Name("sdl2")));
							libs.push(Shared(hlLibDir.findFile("sdl.hdll")));
							libs.push(Shared(hlLibDir.findFile("SDL2.dll")));
						case Mac:
							// TODO: test
							libs.push(Static(Name("sdl2")));
							libs.push(Shared(hlLibDir.findFile("sdl.hdll")));
					}
				default:
					final hdllPath = hlLibDirPath.makeFilePath('$lib.hdll');
					switch systemType {
						case Windows:
							// final libPath = hlLibDirPath.makeFilePath('$lib.lib'); // Don't know why but *.lib files don't work
							final dllPath = hlLibDirPath.makeFilePath('$lib.dll');
							final file = FileRef.from(hdllPath.or(dllPath));
							libs.push(Static(File(file)));
							libs.push(Shared(file));
						case Mac:
							// TODO: test
							// final aPath = hlLibDirPath.makeFilePath('$lib.a').or(hlLibDirPath.makeFilePath('lib$lib.a'));
							final dylibPath = hlLibDirPath.makeFilePath('$lib.dylib')
								.or(hlLibDirPath.makeFilePath('lib$lib.dylib'));
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
