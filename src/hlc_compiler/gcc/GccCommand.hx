package hlc_compiler.gcc;

import hlc_compiler.gcc.GccArgumentTools.*;

/**
	`gcc` command that is ready to be run in commandline on the current OS.
**/
class GccCommand {
	final lines: Array<String>;

	public function new(lines: Array<String>)
		this.lines = lines;

	/**
		Creates a new `gcc` command.
		@param basicLibraries Libraries specified in `hlc.json`.
	**/
	public static extern inline function from(
		commonArguments: Arguments,
		basicLibraries: Array<LibrarySpecifier>
	): GccCommand {
		final arguments = createGccArguments(commonArguments, basicLibraries);
		return new GccCommand(format(arguments));
	}

	/**
		Runs `gcc` command.
		@return The exit code.
	**/
	public extern inline function run(print: Bool = false): Int {
		final cmdString = 'gcc ${this.lines.join(" ")}';
		if (print) Sys.println(cmdString);
		return Sys.command(cmdString);
	}

	/**
		@return Arguments for `gcc` command as string lines which can be used in command line
		(actually this is the internal representation of `GccCommand`).
	**/
	public extern inline function getArgumentLines(): Array<String>
		return this.lines;
}
