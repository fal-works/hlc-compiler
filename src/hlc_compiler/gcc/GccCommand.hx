package hlc_compiler.gcc;

import hlc_compiler.gcc.GccArgumentTools.*;

/**
	`gcc` command that is ready to be run on the current OS.
**/
abstract GccCommand(Array<String>) {
	/**
		Creates a new `gcc` command.
	**/
	public static extern inline function from(
		commonArguments: Arguments,
		libraries: Array<FileRef>
	): GccCommand {
		final arguments = createGccArguments(commonArguments, libraries);
		return new GccCommand(format(arguments));
	}

	/**
		Runs `gcc` command.
	**/
	public extern inline function run(): Void
		Sys.command('gcc ${this.join(" ")}');

	/**
		@return Arguments for `gcc` command as string lines which can be used in command line
		(actually this is the internal representation of `GccCommand`).
	**/
	public extern inline function getArgumentLines(): Array<String>
		return this;

	extern inline function new(data: Array<String>)
		this = data;
}
