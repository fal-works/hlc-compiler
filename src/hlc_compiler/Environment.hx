package hlc_compiler;

class Environment {
	/**
		The system on which the program is running.
	**/
	public static final system = Systems.getCurrent();
}

/**
	Instance set of `System`s supported by hlc-compiler.
**/
class Systems {
	/**
		Windows system.
	**/
	public static final windows: System = {
		type: Windows,
		getDefaultLibDir: curDir -> searchHashLinkDirectory().or(curDir),
		suggestIncludeDir: libDir -> libDir.path.concat("include").tryFind()
	};

	/**
		Mac system.
	**/
	public static final mac: System = {
		type: Mac,
		getDefaultLibDir: curDir -> DirectoryPath.from('/usr/local/lib/')
			.tryFind()
			.or(curDir),
		suggestIncludeDir: libDir -> Maybe.none()
	};

	/**
		@return The system on which the program is currently running.
	**/
	public static function getCurrent(): System {
		final name = Sys.systemName();
		return switch name {
			case "Windows": Systems.windows;
			case "Mac": Systems.mac;
			default:
				Sys.println('[WARNING] $name system is not yet supported.');
				Sys.println('[WARNING] Running in Mac mode, but this is not tested on $name.');
				Systems.mac;
		}
	}

	/**
		List of environment variable names for searching HashLink installation directory.
	**/
	static final hlPathEnvVarCandidates = [
		"HASHLINKPATH",
		"HASHLINK",
		"HASHLINK_BIN"
	];

	/**
		Tries to find HashLink installation directory from environment variables.
	**/
	static function searchHashLinkDirectory(): Maybe<DirectoryRef> {
		return hlPathEnvVarCandidates.mapFirst(varName -> {
			final envVarValue = Maybe.from(Sys.getEnv(varName));
			if (envVarValue.isNone()) return Maybe.none();
			return DirectoryPath.from(envVarValue.unwrap()).tryFind();
		});
	}
}

/**
	Object that represents an operation system and provides system-specific behavior.
**/
typedef System = {
	/**
		System type.
	**/
	final type: SystemType;

	/**
		@return Default direcotry path of libraries.
	**/
	final getDefaultLibDir: (curDir: DirectoryRef) -> DirectoryRef;

	/**
		@return Default directory path of HashLink files to be included.
	**/
	final suggestIncludeDir: (libDir: DirectoryRef) -> Maybe<DirectoryRef>;
}

/**
	System types that are currently supported by hlc-compiler.
**/
enum abstract SystemType(String) {
	final Windows;
	final Mac;
}
