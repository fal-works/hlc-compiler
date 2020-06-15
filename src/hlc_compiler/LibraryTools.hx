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
						libs.push(Static(Name("hl")));
					case "openal" | "mysql" | "steam":
						libs.push(Static(File(hlLibDir.findFile('$lib.hdll'))));
					case "sdl":
						libs.push(Static(Name("sdl2")));
						libs.push(Static(File(hlLibDir.findFile('$lib.hdll'))));
					case "uv":
						libs.push(Static(Name(lib)));
						libs.push(Static(File(hlLibDir.findFile('$lib.hdll'))));
					case "sqlite":
						final hdllPath = hlLibDirPath.makeFilePath('$lib.hdll');
						if (!hdllPath.exists())
							throw "File not found: sqlite.hdll\nSee also: https://github.com/HaxeFoundation/hashlink/pull/323";
						libs.push(Static(File(hdllPath.find())));
					default: // Unknown library
						final hdllPath = hlLibDirPath.makeFilePath('$lib.hdll');
						if (hdllPath.exists())
							libs.push(Static(File(hdllPath.find())));
						else
							libs.push(Static(Name(lib)));
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
