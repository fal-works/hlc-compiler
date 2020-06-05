package hlc_compiler.general;

typedef MaybeCommand = {
	final command: Maybe<String>;
	final run: () -> Void;
};
