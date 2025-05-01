# Inline Assembler Tutorial

This section begins with a brief overview of the **monitor** and its role in the
system, followed by a tutorial on how to use its **inline assembler** feature to
build small, custom code snippets.

## Monitor

The **monitor** is a simple interactive program that gives you low-level control
over the system’s memory and CPU. It supports reading and writing memory,
executing code at arbitrary addresses, disassembling machine instructions, and
assembling new instructions directly from the command line using its built-in
assembler.

!!! note
    The description provided here pertains to the `/TINY/` board, but the
    instructions are transferable to the `/MINI/` board. The major difference
    is that the `/MINI/` board supports bank switching and has its ROM
    starting at `0xC000` where as the `/TINY/` has ROM starting at `0x8000`.

Upon booting the `/TINY/` board, you will be greeted with a selection menu
which allows you to select the `MONITOR` option. 

```
+----------------------------------------------+
|             BYTECRADLE MONITOR               |
+----------------------------------------------+
| FREE ZERO PAGE :     0x40 - 0xFF             |
| FREE RAM       : 0x0400 - 0x7F00             |
| ROM            : 0x8000 - 0xFFFF             |
+----------------------------------------------+
| COMMANDS                                     |
| R<XXXX>[:<XXXX>] read memory                 |
| W<XXXX>          write to memory             |
| G<XXXX>          run from address            |
| A<XXXX>          assemble from address       |
| D<XXXX>          disassemble from address    |
| M                show this menu              |
| Q                quit                        |
+----------------------------------------------+
```

## Monitor Functions

The Monitor provides several commands that allow direct interaction with the
system's memory and CPU. These functions are essential for writing, testing, and
debugging programs at a low level:

* Reading memory (`R<XXXX>[:<XXXX>]`) Allows you to examine memory contents at a
  specific address or within a range of addresses.
* Writing to memory (`W<XXXX>`) Enables manual modification of memory contents at
  a given address. Useful for inserting data like ASCII strings or instructions.
* Running code (`G<XXXX>`) Starts execution of code from a specific memory
  address, enabling you to run programs you have written or loaded into RAM.
* Inline assembly (`A<XXXX>`) Opens an assembler interface at the specified
  address, allowing you to input machine code instructions directly in mnemonic
  form.
* Disassembling code (`D<XXXX>`) Reads machine code from memory and converts it
  back into human-readable assembly instructions.
* Showing the menu (`M`) Displays the monitor’s command menu and current memory
  layout for quick reference.
* Quitting (`Q`) Exits the monitor and returns control to the system selection
  menu or operating environment.

These functions work together to provide a lightweight but powerful development
environment directly on the hardware.

## Sample programs

The following examples demonstrate how to use the Monitor’s inline assembler,
memory writing, and program execution features. By manually assembling
instructions and inserting data, you can create simple programs directly in
memory and run them without needing external tools. These exercises are ideal
for learning how the system interacts with memory and the CPU at a low level.

### Hello World

Open the inline-assembler using `A0400` and insert the following assembly instructions:

```ca65
0400: LDA #10       A9 10
0402: LDX #04       A2 04
0404: JSR FFE8      20 E8 FF
0407: RTS           60
```

Next, insert the ASCII characters for the string `Hello World!` by first typing `W0410` and entering the following values:

```
0410: 48 65 6C 6C 6F 20 57 6F 72 6C 64 21 00
```

To run the small program, type `G0400`.

The expected output is:

```
@:G0400
Hello World!
```

!!! note
    Observe that we used one of the kernel functions, `putch` located at `#FFE8`
    to output a single character to the ACIA. An overview of all the kernel
    functions can be found [here](../software/kernel-functions.md).

### Fibonacci series

Open the inline-assembler using `A0400` and insert the following assembly instructions:

```ca65
0400: LDA #01                  A9 01
0402: LDX #01                  A2 01
0404: LDY #00                  A0 00
0406: PHX                      DA
0407: PHY                      5A
0408: JSR FFF4                 20 F4 FF
040B: JSR FFEE                 20 EE FF
040E: PLY                      7A
040F: PLX                      FA
0410: STX 40                   86 40
0412: CLC                      18
0413: PHA                      48
0414: ADC 40                   65 40
0416: PLX                      FA
0417: INY                      C8
0418: CPY #0C                  C0 0C
041A: BNE EA                   D0 EA
041C: RTS                      60
```

!!!note
    The value of `$40` used for `STX 40` and `ADC 40` refer to zero page address
    `$40`. Note that we are only allowed to use zero page addresses starting from
    `$40` as everything below is used by the system (including the monitor).

To run the program, type `G0400`, which yields the following output:

```
@:G0400
1
2
3
5
8
13
21
34
55
89
```
