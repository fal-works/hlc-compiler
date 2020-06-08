package hlc_compiler;

import haxe.SysTools;

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
		lineSeparator: "^".code,
		quoteCommandArgument: s -> SysTools.quoteWinArg(s.replace("/", "\\"), true),
		getDefaultLibDir: curDir -> searchHashLinkDirectory().or(curDir),
		suggestIncludeDir: libDir -> libDir.path.concat("include").tryFind()
	};

	/**
		Mac system.
	**/
	public static final mac: System = {
		type: Mac,
		lineSeparator: "\\".code,
		quoteCommandArgument: SysTools.quoteUnixArg,
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
			default: throw 'Unsupported system: $name';
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
		Character code for separating one command line into multiple lines.
	**/
	final lineSeparator: Int;

	/**
		@return String that can be used as a single command line argument.
		On Windows, slash is replaced with backslash.
	**/
	final quoteCommandArgument: (s: String) -> String;

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
	System types that are supported by hlc-compiler.
**/
enum abstract SystemType(String) {
	final Windows;
	final Mac;
}
