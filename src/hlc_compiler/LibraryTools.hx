package hlc_compiler;

import haxe.Json;

class LibraryTools {
	/**
		@return Library files required by `hlcJsonFile`.
	**/
	public static function getRequiredLibraries(
		hlcJsonFile: FileRef,
		hlLibDir: DirectoryRef
	): LibraryList {
		final hlLibDirPath = hlLibDir.path;
		final libs: Array<Library> = [];

		final hlcJsonData: HlcJsonData = Json.parse(hlcJsonFile.getContent());
		final systemType = Environment.systemType;

		switch systemType {
			case Windows:
				for (lib in hlcJsonData.libs) switch lib {
					case "std":
						libs.push(Static(Name("libhl"))); // "-lhl" seems to hit another file
						libs.push(Shared(hlLibDir.findFile("libhl.dll")));
					case "openal":
						libs.push(Static(Name("openal")));
						libs.push(Shared(hlLibDir.findFile("openal.hdll")));
						libs.push(Shared(hlLibDir.findFile("OpenAL32.dll")));
					case "sdl":
						libs.push(Static(Name("sdl2")));
						libs.push(Shared(hlLibDir.findFile("sdl.hdll")));
						libs.push(Shared(hlLibDir.findFile("SDL2.dll")));
					default:
						final hdllPath = hlLibDirPath.makeFilePath('$lib.hdll');
						// final libPath = hlLibDirPath.makeFilePath('$lib.lib'); // Don't know why but *.lib files don't work
						final dllPath = hlLibDirPath.makeFilePath('$lib.dll');
						final file = FileRef.from(hdllPath.or(dllPath));
						libs.push(Static(File(file)));
						libs.push(Shared(file));
				};
			case Mac:
				for (lib in hlcJsonData.libs) switch lib {
					case "std":
						libs.push(Static(Name("hl"))); // Seems dynamic link is not required. Just -lhl
					case "openal":
						// TODO: test
						libs.push(Static(Name("openal")));
						libs.push(Shared(hlLibDir.findFile("openal.hdll")));
					case "sdl":
						// TODO: test
						libs.push(Static(Name("sdl2")));
						libs.push(Shared(hlLibDir.findFile("sdl.hdll")));
					default:
						final hdllPath = hlLibDirPath.makeFilePath('$lib.hdll');
						// TODO: test
						if (hdllPath.exists())
							libs.push(StaticShared(hdllPath.find(), null));
						else {
							// final aPath = hlLibDirPath.makeFilePath('$lib.a').or(hlLibDirPath.makeFilePath('lib$lib.a'));
							final dylibPath = hlLibDirPath.makeFilePath('$lib.dylib')
								.or(hlLibDirPath.makeFilePath('lib$lib.dylib'));
							libs.push(StaticShared(FileRef.from(dylibPath), null));
						}
				};
		}

		return libs;
	}
}

/**
	Content of `hlc.json`.
**/
typedef HlcJsonData = {
	final libs: Array<String>;
};
