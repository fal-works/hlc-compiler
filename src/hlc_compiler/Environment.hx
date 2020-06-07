package hlc_compiler;

/**
	Info related to the environment in which hlc-compiler is running.
**/
class Environment {
	/**
		System in which the program is running.
	**/
	public static final system: SystemType = {
		final name = Sys.systemName();
		switch name {
			case "Windows": Windows;
			case "Mac": Mac;
			default: throw 'Unsupported system: $name';
		}
	};
}

/**
	System types that are supported by hlc-compiler.
**/
enum abstract SystemType(String) {
	final Windows;
	final Mac;
}
