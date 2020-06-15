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
		inline function findHdll(name: String): FileRef
			return hlLibDir.findFile('$name.hdll');

		inline function getHdllPath(name: String): FilePath
			return hlLibDir.path.makeFilePath('$name.hdll');

		inline function findDll(name: String): FileRef
			return hlLibDir.findFile('$name.dll');

		inline function getDllPath(name: String): FilePath
			return hlLibDir.path.makeFilePath('$name.dll');

		final libs: Array<Library> = [];
		final hlcJsonData: HlcJsonData = Json.parse(hlcJsonFile.getContent());
		final systemType = Environment.systemType;

		// TODO: test "steam"
		switch systemType {
			case Windows:
				for (lib in hlcJsonData.libs) switch lib {
					case "std":
						libs.push(Static(Name("libhl"))); // "-lhl" seems to hit another file
						libs.push(Shared(findDll("libhl")));
					case "openal":
						libs.push(Static(Name("openal")));
						libs.push(Shared(findHdll("openal")));
						libs.push(Shared(findDll("OpenAL32")));
					case "sdl":
						libs.push(Static(Name("sdl2")));
						libs.push(Shared(findHdll("sdl")));
						libs.push(Shared(findDll("SDL2")));
					case "fmt" | "directx" | "ui" | "uv" | "ssl" | "mysql" | "sqlite" | "steam":
						libs.push(StaticShared(findHdll(lib), null));
					default: // Unknown library
						// final libPath = hlLibDirPath.makeFilePath('$lib.lib'); // Don't know why but *.lib files don't work
						final hdllPath = getHdllPath(lib);
						final dllPath = getDllPath(lib);
						final file = FileRef.from(hdllPath.or(dllPath));
						libs.push(Static(File(file)));
						libs.push(Shared(file));
				};
			case Mac:
				for (lib in hlcJsonData.libs) switch lib {
					case "std":
						libs.push(Static(Name("hl")));
					case "fmt" | "openal" | "mysql" | "steam":
						libs.push(Static(File(findHdll(lib))));
					case "sdl":
						libs.push(Static(Name("sdl2")));
						libs.push(Static(File(findHdll(lib))));
					case "uv":
						libs.push(Static(Name(lib)));
						libs.push(Static(File(findHdll(lib))));
					case "sqlite":
						final hdllPath = getHdllPath(lib);
						if (!hdllPath.exists())
							throw "File not found: sqlite.hdll\nSee also: https://github.com/HaxeFoundation/hashlink/pull/323";
						libs.push(Static(File(hdllPath.find())));
					default: // Unknown library
						final hdllPath = getHdllPath(lib);
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
