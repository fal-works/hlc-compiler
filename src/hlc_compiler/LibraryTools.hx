package hlc_compiler;

import hlc_compiler.types.HlcJson;
import hlc_compiler.types.Library;
import hlc_compiler.types.LibraryList;

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

		final libs: Array<Library> = [];
		final hlcJson = HlcJson.parse(hlcJsonFile);
		final systemType = Environment.systemType;

		switch systemType {
			case Windows:
				for (lib in hlcJson.libs) switch lib {
					case "std":
						libs.push(Static(Name("libhl"))); // "-lhl" seems to hit another file
						libs.push(Shared(findDll("libhl")));
					case "openal":
						libs.push(StaticShared(findHdll("openal"), null));
						libs.push(Shared(findDll("OpenAL32")));
					case "sdl":
						libs.push(StaticShared(findHdll("sdl"), null));
						libs.push(Shared(findDll("SDL2")));
					case "fmt" | "directx" | "ui" | "uv" | "ssl" | "mysql" | "sqlite":
						libs.push(StaticShared(findHdll(lib), null));
					default:
						warn('Unknown library: $lib');
						final hdllPath = getHdllPath(lib);
						if (hdllPath.exists()) {
							libs.push(StaticShared(hdllPath.find(), null));
						} else {
							final libPath = hlLibDir.makeFilePath('$lib.lib')
								.or(hlLibDir.makeFilePath('lib$lib.lib'));
							final dllPath = hlLibDir.makeFilePath('$lib.dll')
								.or(hlLibDir.makeFilePath('lib$lib.dll'));
							if (libPath.or(dllPath).exists())
								libs.push(Static(Name(lib)));
							if (dllPath.exists())
								libs.push(Shared(dllPath.find()));
						}
				};
			case Mac:
				for (lib in hlcJson.libs) switch lib {
					case "std":
						libs.push(Static(Name("hl")));
					case "fmt" | "openal" | "ui" | "mysql" | "ssl":
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
					default:
						warn('Unknown library: $lib');
						final hdllPath = getHdllPath(lib);
						if (hdllPath.exists()) {
							libs.push(Static(File(hdllPath.find())));
						} else {
							libs.push(Static(Name(lib)));
						}
				};
		}

		return libs;
	}
}
