package hlc_compiler;

import hlc_compiler.types.Arguments;
import hlc_compiler.types.LibrarySpecifier;

/**
	Converts provided data to `CommandLine` that runs the specified C compiler.
**/
function buildCompilerCommand(
	arguments: Arguments,
	basicLibraries: Array<LibrarySpecifier>,
	cli: Cli
): CommandLine {
	final srcDir = arguments.srcDir;
	final srcFile = arguments.srcFile;
	final outFile = arguments.outFile;
	final hlLibDir = arguments.hlLibDir;
	final hlIncludeDir = arguments.hlIncludeDir;
	final exOptions = arguments.exOptions;

	final files = [srcFile].concat(arguments.exFiles);
	final libs = basicLibraries;

	final filePath = switch arguments.relative {
		case false: (path: FilePath) -> path.validate(cli).toString();
		case true: (path: FilePath) -> path.validate(cli).toRelative();
	};
	final dirPath = switch arguments.relative {
		case false: (path: DirectoryPath) -> path.validate(cli).toString();
		case true: (path: DirectoryPath) -> path.validate(cli).toRelative();
	};

	final args: CommandArgumentList = [];

	args.push(OptionParameter("-o", Space, filePath(outFile)));

	args.push(OptionParameter("-I", Space, dirPath(srcDir.path)));
	if (hlIncludeDir.isSome()) {
		final path = dirPath(hlIncludeDir.unwrap().path);
		args.push(OptionParameter("-I", Space, path));
	}

	args.push(OptionParameter("-L", Space, dirPath(hlLibDir.path)));

	for (exOption in exOptions)
		args.push(Parameter(exOption));
	if (!exOptions.hasAny(s -> s.startsWith("-std=")))
		args.push(Parameter("-std=c11"));

	for (file in files)
		args.push(Parameter(filePath(file.path)));

	for (lib in libs) switch lib {
		case File(file):
			args.push(Parameter(filePath(file.path)));
		default:
	};

	for (lib in libs) switch lib {
		case Name(name):
			args.push(OptionParameter("-l", None, cli.quoteArgument(name)));
		default:
	}

	return new CommandLine(arguments.compiler, args);
}
