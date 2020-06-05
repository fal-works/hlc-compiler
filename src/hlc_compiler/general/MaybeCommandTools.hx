package hlc_compiler.general;

class MaybeCommandTools {
	/**
		Null object for `MaybeCommand`.
	**/
	public static final nullCommand: MaybeCommand = {
		command: Maybe.none(),
		run: () -> return
	};

	public static function createCommand(cmd: String): MaybeCommand {
		return {
			command: Maybe.from(cmd),
			run: () -> Sys.command(cmd)
		};
	}
}
