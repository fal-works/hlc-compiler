# Development guide

## Environment/Tools

- [VS Code](https://code.visualstudio.com/)
- [lix](https://github.com/lix-pm/lix.client)


## Build

Run `lix Build` in the terminal to build the neko bytecode.


## Test

Run the following in the terminal:

1. `lix PrepareTest` to generate a HL/C code sample (which is a simple Hello World). This only needs to be done once.
1. `lix Test` to test compiling the HL/C code generated above, using the current source code of `hlc-compiler`.
    - Additional arguments:
        - `main` for testing the `main()` function
        - `neko` for testing the neko bytecode
        - `no-args` for testing without arguments
        - `all` for all of the above


## Maintain

- Run `lix Format` to format code.
- Run `lix Build` to update the neko bytecode.
- Run `lix Test all` to test everything.
- Check if [hlc-compiler-sample](https://github.com/fal-works/hlc-compiler-sample) still works.


## Submission to [Haxelib](https://lib.haxe.org/)

1. Update the library version.
    - Update `version` in the `Constants` module.
    - Update `haxelib.json`.
1. Check and update everything (see the "Maintain" section above).
1. Reflect to the main branch on GitHub, and add a version tag.
1. Pack the library by `lix Pack`, which generates `lib.zip`.
1. Submit the library by `haxelib submit lib.zip`.
