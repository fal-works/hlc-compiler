package hlc_compiler;

class Environment {
	/**
		The system on which the program is running.
	**/
	public static final systemType = {
		final name = Sys.systemName();
		switch name {
			case "Windows": Windows;
			case "Mac": Mac;
			default:
				Sys.println('[WARNING] $name system is not yet supported.');
				Sys.println('[WARNING] Running in Mac mode, but this is not tested on $name.');
				Mac;
		};
	}
}

/**
	System types that are currently supported by hlc-compiler.
**/
enum abstract SystemType(String) {
	final Windows;
	final Mac;
}
