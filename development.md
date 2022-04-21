# Development guide

## Environment

### Using [lix](https://github.com/lix-pm/lix.client)

This project uses `lix` for managing Haxe library dependencies.

- Install `lix` (requires [Node.js](https://nodejs.org/ja/)): `npm install -g lix`
- Download Haxe libraries: `lix download`


## Test

Run the following in the terminal:

1. `haxe test-prepare.hxml` to generate a HL/C code sample (which is a simple Hello World).
2. `haxe test.hxml` to test compiling the HL/C code generated above.


## Submission to [Haxelib](https://lib.haxe.org/)

Before submitting, check if [hlc-compiler-sample](https://github.com/fal-works/hlc-compiler-sample) still works.

1. Update `haxelib.json`.
2. Pack the library by executing `lix Pack`, which generates `lib.zip`.
3. Submit the library by executing `haxelib submit lib.zip`.
