package hlc_compiler;

import hlc_compiler.types.HlcJson;
import hlc_compiler.types.Library;
import hlc_compiler.types.LibraryList;

/**
	List of environment variable names for searching HashLink installation directory.
**/
final hlPathEnvVarCandidates = [
	"HASHLINKPATH",
	"HASHLINK",
	"HASHLINK_BIN"
];

/**
	@return Default direcotry path of HashLink-bundled libraries (`*.hdll` etc).
**/
function suggestHashLinkLibraryDirectory(): Maybe<DirectoryRef> {
	return switch Environment.systemType {
		case Windows: searchHashLinkDirectory();
		case Mac: Maybe.from(DirectoryRef.from("/usr/local/lib/"));
	}
}

/**
	@return Default directory path of HashLink files to be included (`*.h`/`*.c`).
**/
function suggestHashLinkIncludeDirectory(hlLibDir: DirectoryRef): Maybe<DirectoryRef> {
	return switch Environment.systemType {
		case Windows: hlLibDir.tryFindDirectory("./include");
		case Mac: Maybe.none();
	}
}

/**
	Tries to find HashLink installation directory from environment variables.
**/
function searchHashLinkDirectory(): Maybe<DirectoryRef> {
	return hlPathEnvVarCandidates.mapFirst(varName -> {
		final envVarValue = Maybe.from(Sys.getEnv(varName));
		if (envVarValue.isNone()) return Maybe.none();
		return DirectoryPath.from(envVarValue.unwrap()).tryFind();
	});
}

/**
	@return Library files required by `hlcJsonFile`.
**/
function getRequiredLibraries(
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

	switch Environment.systemType {
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
					if (!hdllPath.exists()) {
						var msg = "File not found: sqlite.hdll";
						msg += "\n  See also: https://github.com/HaxeFoundation/hashlink/pull/323";
						throw error(msg);
					}
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
