package hlc_compiler.types;

import haxe.Json;
import sinker.globals.Globals.maybe;

/**
	Content of `hlc.json`.
**/
@:structInit
class HlcJson {
	public static function parse(file: FileRef): HlcJson {
		final obj = try {
			Json.parse(file.getContent());
		} catch (e) {
			final msg = 'Failed to parse JSON: ${file.path}\n$e';
			throw new HlcCompilerError(msg);
		}

		final libs = maybe(Reflect.field(obj, "libs")).map(x -> {
			if (!Std.isOfType(x, std.Array)) {
				final msg = 'Failed to parse: ${file.path}\nlibs must be an array of String.';
				throw new HlcCompilerError(msg);
			}
			return (x : Array<Any>);
		}).orElse(() -> {
			warn('Field libs not found in: ${file.path}');
			return [];
		});

		return {
			libs: libs.map(x -> {
				if (!Std.isOfType(x, String)) {
					final msg = 'Failed to parse: ${file.path}\nlibs must be an array of String.';
					throw new HlcCompilerError(msg);
				}
				return (x : String);
			})
		};
	}

	public final libs: Array<String>;
}
