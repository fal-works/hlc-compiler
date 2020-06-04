import sys.FileSystem;
import sys.io.File;

using StringTools;

class Main {
  static function main() {
    final args = Sys.args();
    final argsLength = args.length;
    var index = 0;

    inline function hasNext()
      return index < argsLength;

    inline function next()
      return args[index++];

    inline function nextOption(option:String) {
      if (!hasNext())
        throw 'Missing argument for option: $option';
      return next();
    }

    final cwd = Sys.getCwd();
    var srcDir: String = cwd;
    var outFile: String = cwd + "main";
    var hlDir: String = cwd;

    while (hasNext()) {
      switch (next()) {
        case "--srcDir":
          srcDir = validateDirPath(nextOption("--srcDir [directory path]"));
        case "--outFile":
          outFile = FileSystem.absolutePath(nextOption("--outFile [file path]"));
        case "--hlDir":
          hlDir = validateDirPath(nextOption("--hlDir [directory path]"));
      }
    }

    if (outFile == null) outFile = srcDir + "main";

    final jsonFile = validateFilePath(srcDir + "hlc.json");
    final srcFile = validateFilePath(srcDir + "main.c");


  }

  static function validateFilePath(relPath:String) {
    final absPath = FileSystem.absolutePath(relPath);
    if (!FileSystem.exists(absPath))
      throw "File not found: " + absPath;
    return absPath;
  }

  static function validateDirPath(relPath:String) {
    var absPath = FileSystem.absolutePath(relPath);
    if (!FileSystem.exists(absPath))
      throw "Directory not found: " + absPath;
    if (!absPath.endsWith("/") && !absPath.endsWith("\\"))
      absPath += "/";
    return absPath;
  }
}
