package hlc_compiler.types;

import haxe.Json;

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
			throw error(msg);
		}

		final libs = Maybe.from(Reflect.field(obj, "libs")).map(x -> {
			if (!Std.isOfType(x, std.Array)) {
				final msg = 'Failed to parse: ${file.path}\n  libs must be Array<String>.';
				throw error(msg);
			}
			return (x : Array<Any>);
		}).orElse(() -> {
			throw error('Field libs not found in: ${file.path}');
		});

		return {
			libs: libs.map(x -> {
				if (!Std.isOfType(x, String)) {
					final msg = 'Failed to parse: ${file.path}\n  libs must be Array<String>.';
					throw error(msg);
				}
				return (x : String);
			})
		};
	}

	public final libs: Array<String>;
}
