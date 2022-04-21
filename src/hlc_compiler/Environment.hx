package hlc_compiler;

/**
	The system on which the program is running.
**/
final systemType = {
	final name = Sys.systemName();
	switch name {
		case "Windows": Windows;
		case "Mac": Mac;
		default:
			warn('Unknown system: $name');
			warn('Continue running in Mac mode, but this is not tested on $name.');
			Mac;
	};
}

/**
	System types that are currently supported by hlc-compiler.
**/
enum abstract SystemType(String) {
	final Windows;
	final Mac;
}
