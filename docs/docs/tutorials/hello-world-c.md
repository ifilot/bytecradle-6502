# Writing a Standalone C Program for ByteCradle with CC65

This tutorial walks through the process of building a standalone C program for
the **ByteCradle** platform using the **cc65 toolchain**. You'll learn how to
set up the startup code, write a simple `main()` function, configure memory
mapping, and compile the final binary.

!!! tip
    You can find several example programs in [the official repository](https://github.com/ifilot/bytecradle-6502/tree/master/programs).

## Prerequisites

- A Linux system with the `cc65` toolchain installed (`ca65`, `cc65`, `ld65`, `ar65`)
- Basic familiarity with 6502 architecture and C programming
- Make and a standard build environment

!!! tip
    More information on the toolchain is provided [here](../software/building-programs.md#toolchain).

## Project Structure

The project consists of the following files:

| File        | Description |
|-------------|-------------|
| `crt0.s`    | Startup code (called before `main()`) |
| `main.c`    | Your main application in C |
| `io.h`      | Helper for system-level I/O routines |
| `prog.cfg`  | Memory layout and segment configuration for the linker |
| `Makefile`  | Automates the build process |

## Step 1: Write the Startup Code

The startup assembly file initializes the stack, clears the BSS section, copies initialized data, and finally calls `main()`. It also defines an `_exit` routine for cleanup.

```
; ---------------------------------------------------------------------------
; crt0.s
; ---------------------------------------------------------------------------

.import __HEADER_LOAD__                     ; import start location

.export   _init, _exit
.import   _main, _charout

.export   __STARTUP__ : absolute = 1        ; Mark as startup
.import   __RAM_START__, __RAM_SIZE__       ; Linker generated

.import    copydata, zerobss, initlib, donelib

.include  "zeropage.inc"

; ---------------------------------------------------------------------------

.segment "HEADER"

.word __HEADER_LOAD__

; ---------------------------------------------------------------------------

.segment  "STARTUP"

; ---------------------------------------------------------------------------
; Set cc65 argument stack pointer
; ---------------------------------------------------------------------------
_init:

          LDA     #<(__RAM_START__ + __RAM_SIZE__)
          STA     sp
          LDA     #>(__RAM_START__ + __RAM_SIZE__)
          STA     sp+1

; ---------------------------------------------------------------------------
; Initialize memory storage
; ---------------------------------------------------------------------------

          JSR     zerobss              ; Clear BSS segment
          JSR     copydata             ; Initialize DATA segment
          JSR     initlib              ; Run constructors

; ---------------------------------------------------------------------------
; Call main()
; ---------------------------------------------------------------------------

          JSR     _main

; ---------------------------------------------------------------------------
; Back from main (this is also the _exit entry):  force a software break
; ---------------------------------------------------------------------------

_exit:    JSR     donelib              ; Run destructors
          RTS
```

## Step 2: Create I/O Header

This header declares a function pointer to the system's ROM-based string printing routine at address `$FFE8`. This lets us call system functions from C.

```c
#ifndef _IO_H
#define _IO_H

#include <stdint.h>

// ByteCradle OS: Print null-terminated string with newline (ROM $FFE8)
void (*putstrnl)(const uint8_t*) = (void (*)(const uint8_t*))0xFFE8;

#endif // _IO_H
```

## Step 3: Write the Main C Program

This is a simple "Hello World" program that prints to the screen using `putstrnl`.

```c
#include "io.h"

int main() {
    putstrnl("Hello World!");
    return 0;
}
```

## Step 4: Configure Memory Layout

The linker configuration (`prog.cfg`) defines where various sections of the program go in memory, including a 2-byte header, zero page usage, and stack space.

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

## Step 5: Create the Makefile

The `Makefile` automates the build by assembling and linking your C and assembly
files into a `.COM` binary that can be run on ByteCradle.

```makefile
PROG = HELLOC.COM

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
	rm -v *.o *.lib main.s $(PROG)
```

## Step 6: Build the Program

From the terminal, run:

```bash
make
```


## Step 7: Run the program

Copy the resulting HELLOC.COM file to the ByteCradle's SD card or upload it
using the appropriate method. Then, on the ByteCradle shell:

```
:/> helloc
Hello World!
:/>
```

!!! tip 
    Instructions on how to deploy the program to your ByteCradle board,
    including for the TinyROM which does not have an SD-CARD, are [provided
    here](../software/building-programs.md/#bytecradle-os)

