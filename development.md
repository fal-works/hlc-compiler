# Development guide

## Environment

### Using [lix](https://github.com/lix-pm/lix.client)

This project uses `lix` for managing Haxe library dependencies.

- Install `lix` (requires [Node.js](https://nodejs.org/ja/)): `npm install -g lix`
- Download Haxe libraries: `lix download`


## Test

Run the following in the terminal:

1. `lix PrepareTest` to generate a HL/C code sample (which is a simple Hello World). This only needs to be done once.
2. `lix Test` to test compiling the HL/C code generated above, using the current source code of `hlc-compiler`.


## Submission to [Haxelib](https://lib.haxe.org/)

Before submitting, check if [hlc-compiler-sample](https://github.com/fal-works/hlc-compiler-sample) still works.

1. Update `haxelib.json`.
2. Build the neko bytecode by `lix Build`, and check if it works by `lix Test neko`.
3. Pack the library by executing `lix Pack`, which generates `lib.zip`.
4. Submit the library by executing `haxelib submit lib.zip`.
