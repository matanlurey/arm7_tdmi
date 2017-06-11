<p align="center">
  <h1 align="center">armv4t_asm</h1>
  <p align="center">
    Assembler for the ARMv4T CPU Architecture.
  </p>
</p>

_Recommended reading: ["An Introduction to the GNU Assembler"][intro]._

[intro]: doc/gnu_assembler.pdf

## Installation

This package can be used as a standalone executable, or as a dependency.

### CLI

Use [`pub global activate`](https://www.dartlang.org/tools/pub/cmd/pub-global)
to install the assembler as a local program to be used on the command-line:

```bash
$ pub global activate armv4t_asm
$ armv4t_asm filename.s
> Assembling filename.s as filename.o...
> Wrote filename.o in 10ms.
```

Use `armv4t_asm --help` to get full usage information.

### Pub

```yaml
dependencies:
  armv4t_asm:
```

## Usage

TBD.
