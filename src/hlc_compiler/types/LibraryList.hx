package hlc_compiler.types;

/**
	List of libraries to be linked.
**/
@:notNull @:forward
abstract LibraryList(Array<Library>) from Array<Library> {
	/**
		Function that returns a specifier if `library` should be statically linked.
	**/
	static final getStatic = (library: Library) -> Maybe.from(switch library {
		case Static(nameOrFile): nameOrFile;
		case Shared(_): null;
		case StaticShared(file, name):
			(if (name.isSome()) Name(name.unwrap()) else File(file) : LibrarySpecifier);
	});

	/**
		Function that returns a file if `library` is required in runtime.
	**/
	static final getShared = (library: Library) -> Maybe.from(switch library {
		case Static(_): null;
		case Shared(file): file;
		case StaticShared(file, _): file;
	});

	/**
		@return List of libraries required in buildtime.
	**/
	public inline function filterStatic()
		return this.filterMap(getStatic);

	/**
		@return List of libraries required in runtime.
	**/
	public inline function filterShared()
		return this.filterMap(getShared);
}
