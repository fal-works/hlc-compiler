package hlc_compiler.gcc;

/**
	GCC command that is ready to be run on the current OS.
**/
abstract SanitizedCommand(Array<String>) to Array<String> {
	extern inline function new(data: Array<String>)
		this = data;

	/**
		Runs `gcc` command.
	**/
	public extern inline function run(): Void
		Sys.command('gcc ${this.join(" ")}');
}
