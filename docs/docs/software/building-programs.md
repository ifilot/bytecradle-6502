# Building programs

## Introduction

This page explains how to build stand-alone programs for the ByteCradle system
using the cc65 toolchain, a complete suite for developing software targeting the
65(C)02 processor. It covers the full development workflow, including tool
installation, memory layout planning, linker configuration, and Makefile-based
build processes for both assembly and C-based programs.

A key concept in this process is **cross-compilation**, the practice of building
software on a modern host system (such as Linux, macOS, or Windows) that is
intended to run on a different target system, in this case, a 6502-based
platform like ByteCradle. Since the target hardware is typically much more
limited and may not support native development tools, cross-compilation enables
developers to leverage the power and convenience of modern systems to build code
for retro or embedded environments.

By following this guide, you will learn how to prepare your code and toolchain
for effective cross-compilation and deploy programs to either target system
using the appropriate method—file-based for ByteCradle OS, or raw memory writes
for TinyROM.

## Toolchain

The **cc65 toolchain** is a complete suite of tools for developing software for
6502-based systems. It includes:

- `cc65` – A C compiler for the 6502 processor
- `ca65` – A macro assembler
- `ld65` – A powerful linker with configurable memory mapping
- `ar65` – An archiver for managing libraries
- `od65`, `da65`, and more – Tools for object file inspection and disassembly

This toolchain is ideal for both **assembly** and **C-based** development for
the ByteCradle system.

### Installing cc65 on Ubuntu (Linux)

To install the toolchain and supporting build tools on Ubuntu, follow these steps:

```bash
sudo apt update
sudo apt install -y cc65 make
```

### Windows Subsystem for Linux

On Windows, the easiest way to use cc65 is through WSL (Windows Subsystem for
Linux), which lets you run Linux tools natively:

Install WSL by running this in PowerShell (as Administrator):

```powershell
wsl --install
```

After rebooting, open the Ubuntu app from the Start Menu.

Then run the same commands as on Ubuntu:

```bash
sudo apt update
sudo apt install -y cc65 make
```

This gives you a clean, Linux-based development environment that integrates well
with editors like Visual Studio Code.

## Writing stand-alone software

A stand-alone program is a self-contained executable that is loaded into RAM and
run directly under the control of the system's firmware or operating system.
Unlike more complex environments with memory protection or multitasking, these
programs run in a simple, flat memory model and are responsible for managing
their own execution context.

In the ByteCradle ecosystem, stand-alone programs are typically loaded into
memory either from a ROM device or over UART. Once loaded, they are executed by
the system without the aid of a loader or process isolation. Because the 6502
architecture does not provide protected mode or automatic resource management, a
stand-alone program must take full responsibility for:

* Preserving system integrity: The program must leave the system in a consistent
  state when it finishes, including cleaning up the stack and registers as needed.
* Memory management: The program must fit within the [memory region](../hardware/memory-maps.md) made
  available by the environment.
    - Under [TinyROM](../software/operating-system.md#tinyrom-operating-system-tiny-board), 
      this region spans from $0400 to $7EFF.
    - Under the [ByteCradle Operating System](../software/operating-system.md#bytecradle-operating-system-mini-board), 
      it spans from $0800 to $7EFF.
* Stack usage: The program shares the system stack at page $01xx (starting at
  $0100) with the operating system. If compiled with cc65, the program may also
  use a soft stack (an emulated stack in RAM), which consumes additional memory.

It is the responsibility of the program's author to ensure that the code, data,
heap, and any stack usage—both hardware and soft—remain within these limits,
avoiding conflicts with the operating system and ensuring reliable execution.

## Program lay-out

The way stand-alone programs are stored and loaded differs between TinyROM and
the ByteCradle Operating System, reflecting the capabilities of each
environment.

* TinyROM is a minimal operating system and does not include a file system. As a
  result, stand-alone programs for TinyROM are treated as raw binary data,
  directly placed into memory. These binaries are typically loaded at a known
  memory address (usually starting at $0400) and executed from there. Since
  there is no file metadata or structured loading mechanism, the user or host
  system must know exactly where and how to place the binary in memory.

* ByteCradle OS includes a simple file system with support for named files using
  the 8.3 filename format (eight-character name, three-character extension).
  Executable stand-alone programs use the .COM extension, consistent with legacy
  CP/M-style conventions. Each .COM file begins with a two-byte little-endian
  value that specifies the deployment address—the memory location where the
  program should be loaded before execution. For most stand-alone programs, this
  address is $0800, encoded as 00 08 (least significant byte first). This small
  header allows the OS to automatically place the program in memory at the
  correct location, simplifying the loading process compared to TinyROM's raw
  approach.

## Configuration files and linker

To create an executable for the ByteCradle system, the process typically
involves compiling or assembling the source code, followed by a linking step:

* **Compiling** (if written in C): The C source file is translated into intermediate
  object code using cc65, the C compiler.
* **Assembling** (if written in 6502 assembly): The assembly source is assembled
  into object code using ca65, the assembler.
* **Linking**: All object files are combined into a final binary using ld65, the
  linker. This step determines where each part of the program will reside in
  memory.

The linker relies on a linker configuration file (.cfg) to guide how code and
data are placed in memory. This configuration file serves as a map of the
system's memory—defining which regions are available, where segments should go,
and how the output binary should be structured.

### Assembly

Below is a minimal linker configuration file used to build a stand-alone program
for the ByteCradle Operating System in assembly.

```
MEMORY {
    HEADER: start = $0800, size = 2, file = %O;             # Explicit start position
    ROM:    start = $0802, size = $7FFE, file = %O;         # Start right after HEADER
}

SEGMENTS {
    HEADER: load = HEADER, type = ro, define = yes;
    CODE:   load = ROM, type = ro;
}
```

* `MEMORY` block:
    * `HEADER` defines the first 2 bytes of the output file, starting at $0800.
       These bytes contain the deployment address in little-endian format (00 08) and
       are used by ByteCradle OS to know where to load and run the program.
    * `ROM` begins immediately after the header (at $0802) and holds the actual
      program code.
* `SEGMENTS` block:
    * `HEADER` is linked into the HEADER memory region. Typically, the assembly
      source includes this manually as a .word $0800.
    * `CODE` refers to the main code segment, which is placed into the ROM
      region starting at $0802.

This structure matches the ByteCradle OS convention for .COM executables, where
files begin with a 2-byte deployment address. The remainder of the file is
loaded into memory at that address and executed.

### C programs

Compiled C programs have more complex requirements than simple assembly
programs. The compiler and runtime system expect multiple segments for code,
data, initialization routines, and memory management. The `.cfg` file configures
how those segments are placed in memory and is essential for successful linking
using `ld65`.

```
MEMORY {
    ZP:     start = $50, size = $B0, type = rw, define = yes;
    HEADER: start = $0800, size = 2, file = %O;
    RAM:    start = $0802, size = $7700-$0802, type = rw, define = yes;
    STACK:  start = $7700, size = $0800, type = rw, define = yes;
}

SEGMENTS {
    ZEROPAGE: load = ZP,        type = zp,  define   = yes;
    HEADER:   load = HEADER,    type = ro,  define   = yes;
    STARTUP:  load = RAM,       type = ro;
    CODE:     load = RAM,       type = ro;
    ONCE:     load = RAM,       type = ro,  optional = yes;
    RODATA:   load = RAM,       type = ro;
    DATA:     load = RAM,       type = rw,  define   = yes, run = RAM;
    BSS:      load = RAM,       type = bss, define   = yes;
    HEAP:     load = RAM,       type = bss, optional = yes;
}

FEATURES {
    CONDES:    segment = STARTUP,
               type    = constructor,
               label   = __CONSTRUCTOR_TABLE__,
               count   = __CONSTRUCTOR_COUNT__;
    CONDES:    segment = STARTUP,
               type    = destructor,
               label   = __DESTRUCTOR_TABLE__,
               count   = __DESTRUCTOR_COUNT__;
}

SYMBOLS {
    # Define the stack size for the application
    __STACKSIZE__:  value = $0200, type = weak;
}
```

#### MEMORY Block

- **ZP**: Defines a section in zero page RAM (`$0050–$00FF`) for variables that
  benefit from fast zero-page addressing. Many cc65 runtime features rely on
  this region.

- **HEADER**: Occupies the first two bytes at `$0800`. It stores the deployment
  address in little-endian format (typically `00 08`), which is used by the
  ByteCradle OS to determine where to load and execute the program.

- **RAM**: This is the main region used for program code, read-only data,
  initialized data, and uninitialized data. It starts at `$0802`, immediately
  after the header, and ends just before the stack.

- **STACK**: Defines a dedicated memory area for the hardware stack, beginning
  at `$7700` and sized to 2 KB (ending at `$7EFF`). This keeps stack usage
  isolated from the rest of the program.

#### SEGMENTS Block

This section defines how various parts of the program are mapped into the memory regions defined above.

- **ZEROPAGE**: Holds variables that reside in the zero page. These are accessed
  more efficiently by the 6502 and are typically used for frequently accessed or
  performance-critical data.

- **HEADER**: Contains the two-byte deployment address used by the ByteCradle OS
  loader.

- **STARTUP**: Contains startup routines provided by the cc65 runtime (such as
  `crt0`) that initialize the system before `main()` is called.

- **CODE**: The main compiled C code.

- **ONCE**: Optional segment for code that is executed once and can be discarded
  afterward.

- **RODATA**: Read-only data such as string literals and constants.

- **DATA**: Holds initialized global and static variables.

- **BSS**: Contains uninitialized global and static variables. This area is
  zeroed at runtime before `main()` executes.

- **HEAP**: Optional segment for dynamically allocated memory (used by
  `malloc()` and similar functions).

#### FEATURES Block

This section configures constructor and destructor support in the cc65 runtime.

- `__CONSTRUCTOR_TABLE__` and `__DESTRUCTOR_TABLE__` define where initialization
  and cleanup function pointers are stored. These are called automatically
  before and after `main()`.

#### SYMBOLS Block

- Defines the application’s hardware stack size as 512 bytes (`$0200`), which
  can be overridden at link time or in code because it is declared as a weak
  symbol.

## Compilation

While it is possible to compile and link programs manually using command-line
tools, using a **Makefile** provides a more efficient and repeatable way to
manage builds—especially as a project grows. A Makefile ensures that only the
necessary parts of the build are recompiled when changes are made, saving time
and reducing errors.

!!! tip
    For a more detailed tutorial on how to write a stand-alone program, consider
    the [Hello World in assembly](../tutorials/hello-world-assembly.md) and 
    [Hello World in C](../tutorials/hello-world-assembly.md) tutorials.

### Makefile for assembly source

Below is a simple example of a Makefile used to compile a stand-alone **assembly
program** written for the ByteCradle system. This example assumes a single
`.asm` source file and a custom linker configuration (`.cfg`) file:

```makefile
PROG = HELLO.COM
OBJ  = helloworld.o
CFG  = rom.cfg

all: $(PROG)

$(OBJ): helloworld.asm
	ca65 helloworld.asm -o $(OBJ)

$(PROG): $(OBJ)
	ld65 -o $(PROG) -C $(CFG) $(OBJ)
```

### Makefile for C-source

This example `Makefile` demonstrates how to compile and link a C program for the
ByteCradle system using the **cc65 toolchain**. It combines C source code
(`main.c`) with a custom startup file (`crt0.s`) and links against a library to
produce a standalone executable.

```makefile
PROG = FIBO.COM

all: $(PROG)

$(PROG): prog.cfg crt0.o main.o prog.lib
	ar65 a prog.lib crt0.o
	ld65 -C prog.cfg -m main.map main.o -o $(PROG) prog.lib

crt0.o: crt0.s
	ca65 --cpu 65c02 crt0.s

main.s: main.c
	cc65 -t none -O --cpu 65c02 main.c

prog.lib: crt0.o
	cp -v /usr/share/cc65/lib/supervision.lib prog.lib 
	ar65 a prog.lib crt0.o

main.o: main.s
	ca65 --cpu 65c02 main.s

clean:
	rm -v *.bin *.o *.lib
```

The build process consists of the following steps:

- Compile the C source (`main.c`) to assembly using `cc65`
- Assemble both the generated assembly and a custom startup file (`crt0.s`)
  using `ca65`
- Combine the startup object with a lightweight runtime library
  (`supervision.lib`) into a static library using `ar65`
- Link the object files and library into a final binary using `ld65`, guided by
  a linker configuration file (`prog.cfg`)
- The result is a `.COM` file that starts with a 2-byte load address and is
  ready to run on ByteCradle OS

#### Explanation of Makefile Targets

- `PROG = FIBO.COM`: Specifies the output binary name. `.COM` is the standard
  extension for executables under ByteCradle OS.

- `all`: Default target, builds the complete program.

- `main.c → main.s`: The C compiler `cc65` translates the C source into 6502
  assembly. The `-t none` flag disables platform-specific features, and `--cpu
  65c02` targets the 65C02 processor used by ByteCradle.

- `main.s → main.o`: The assembler `ca65` compiles the assembly into an object
  file.

- `crt0.s → crt0.o`: Custom startup code, also assembled with `ca65`. This
  typically includes the program’s entry point and the call to `main()`.

- `prog.lib`: A static library created by first copying `supervision.lib` (from
  the cc65 library directory) and then adding the startup object file to it
  using `ar65`.

- `ld65`: The linker takes the object files, linker config file (`prog.cfg`),
  and library, and produces the final `.COM` binary. A map file (`main.map`) is
  also generated for inspection.

- `clean`: Removes temporary and intermediate files.

#### Why Use `supervision.lib`?

The cc65 toolchain includes a number of prebuilt runtime libraries for different systems. `supervision.lib` is used here for the following reasons:

- It is one of the simplest and smallest libraries included with cc65.
- It provides basic C runtime support (e.g., `memcpy`, `strlen`, `memcmp`) without assuming the presence of I/O hardware or a full operating system.
- It is compatible with `-t none` and targets systems similar in simplicity to the ByteCradle SBC.
- Using this library, along with a custom `crt0.s` file, gives full control over how the program starts and runs.

This approach avoids unnecessary dependencies and gives the developer direct control over memory layout, system initialization, and runtime behavior.

## Deployment

This document outlines the deployment process for stand-alone programs on two
distinct platforms: ByteCradle OS and TinyROM. While both systems are designed
for simplicity and low-level control, they offer different approaches to program
execution. ByteCradle OS provides a file-based interface that simplifies running
compiled applications, whereas TinyROM offers a more hands-on experience,
requiring direct memory interaction through a built-in monitor.

!!! note 
    ByteCradle OS uses the same monitor as TinyROM, so you can deploy
    programs using the TinyROM method (writing raw hex via the monitor) on
    ByteCradle OS as well.

## ByteCradle OS

Deploying a stand-alone program on the ByteCradle OS is straightforward. Simply
copy the compiled `.COM` file to the SD card used by the system. Once the card
is mounted and the system is running, navigate to the appropriate directory
using the shell, and type the **base name** of the file (without the `.COM`
extension) to execute it. For example, if your file is named `HELLO.COM`, you
can run it by typing `HELLO` at the prompt.

An example is provided below:

```
 ____             __           ____                      __   ___
/\  _`\          /\ \__       /\  _`\                   /\ \ /\_ \
\ \ \L\ \  __  __\ \ ,_\    __\ \ \/\_\  _ __    __     \_\ \\//\ \      __
 \ \  _ <'/\ \/\ \\ \ \/  /'__`\ \ \/_/_/\`'__\/'__`\   /'_` \ \ \ \   /'__`\
  \ \ \L\ \ \ \_\ \\ \ \_/\  __/\ \ \L\ \ \ \//\ \L\.\_/\ \L\ \ \_\ \_/\  __/
   \ \____/\/`____ \\ \__\ \____\\ \____/\ \_\\ \__/.\_\ \___,_\/\____\ \____\
    \/___/  `/___/> \\/__/\/____/ \/___/  \/_/ \/__/\/_/\/__,_ /\/____/\/____/
               /\___/
               \/__/
  ____  ______     __      ___
 /'___\/\  ___\  /'__`\  /'___`\
/\ \__/\ \ \__/ /\ \/\ \/\_\ /\ \
\ \  _``\ \___``\ \ \ \ \/_/// /__
 \ \ \L\ \/\ \L\ \ \ \_\ \ // /_\ \
  \ \____/\ \____/\ \____//\______/
   \/___/  \/___/  \/___/ \/_____/

Starting system.
Clearing user space...   [OK]
Connecting to SD-card... [OK]
:/> ls
FIBO    .COM 00000007 2302
HELLO   .COM 00000008 23
MANDEL  .COM 00000006 1406
:/> hello
Hello World!
:/>
```

## TinyROM

Deploying programs to the TinyROM system is a bit more involved than on
ByteCradle OS. TinyROM relies on its built-in monitor for program loading. To
begin, power on the system and access the monitor prompt. From there, type
`W0800` to enter write mode starting at memory address `$0800`. In this mode,
you'll input the raw machine code of your program as a continuous stream of
hexadecimal values—with no spaces or line breaks.

For instance, to deploy a simple "Hello World" program, you would enter:

```
0008A90AA20820E8FF6048656C6C6F20576F726C642100
```

!!! tip 
    Need the raw hex of an executable? On Linux, use this one-liner to dump
    it as a continuous stream of HEX characters: `hexdump -v -e '/1 "%02X"' HELLO.COM`

!!! warning 
    When pasting "large" files (e.g., several hundred bytes), the
    ByteCradle system may struggle to keep up with the incoming data stream,
    leading to dropped or corrupted input. To prevent this, consider using
    terminal programs like Tera Term, which allow you to insert small delays
    between characters during transmission.

After typing the entire sequence, press Enter to exit write mode. Then, to
execute the program, type:

```
G0802
```

The result below shows how it should look like.

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

@:W0800
 > Enabling WRITE MODE. Enter HEX values. Hit RETURN to quit.
    0800: 00 08 A9 0A A2 08 20 E8 FF 60 48 65 6C 6C 6F 20
    0810: 57 6F 72 6C 64 21 00
@:G0802
Hello World!

@:
```