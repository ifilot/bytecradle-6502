# Tutorial: Hello World in Assembly

This tutorial walks you through writing, building, and running a simple "Hello
World" program in 6502 assembly for the **ByteCradle OS**. The example uses the
`cc65` toolchain, a widely used suite for 6502-based development.

## Step 1: Writing the Assembly Code

Create a new file called `helloworld.asm` and enter the following code:

```assembly
;------------------------------------------------------------------------------
; Hello World Example for ByteCradle 6502
;
; This program prints "Hello World!" to the screen using the ByteCradle OS's
; built-in output routine located at $FFE8.
;------------------------------------------------------------------------------

.PSC02                              ; Assembly for the 65C02 CPU

.import __HEADER_LOAD__             ; Provided by the linker (.cfg) as load address

.define PUTSTRNL $FFE8              ; Routine to print a null-terminated string with newline

;------------------------------------------------------------------------------
; Program Header (used by ByteCradle OS to determine deployment address)
;------------------------------------------------------------------------------
.segment "HEADER"
.word __HEADER_LOAD__               ; Deployment address (typically $0800), little-endian

;------------------------------------------------------------------------------
; Main Code Segment
;------------------------------------------------------------------------------
.segment "CODE"

start:                              ; Entry point
    lda #<hwstr                     ; Load low byte of string address
    ldx #>hwstr                     ; Load high byte of string address
    jsr PUTSTRNL                    ; Call OS routine to print string with newline
    rts                             ; Return to OS

hwstr:
    .asciiz "Hello World!"          ; Null-terminated string
```

**How it works:**

* The program starts at the label start, which is called by the OS.
* It loads the address of a null-terminated string and calls 
  [the OS function](../software/kernel-functions.md) at
  `$FFE8`, which prints the string followed by a newline.
* The .segment "HEADER" section includes a 2-byte deployment address required by
  ByteCradle OS .COM files.
* The program ends with rts (return from subroutine), allowing the OS to regain
  control.

## Step 2: Writing the Makefile

Create a file called Makefile in the same directory:

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

This Makefile automates the build process:

* Assembles the source using `ca65`
* Links the program using `ld65` with a linker configuration file (`rom.cfg`)
* Produces an output file named `HELLO.COM`

## Step 3: Linker Configuration (rom.cfg)

You will also need a linker configuration file called `rom.cfg`. This tells the
linker how to place the code in memory:

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

This layout matches the expectations of the ByteCradle OS, which reads the first
two bytes of a .COM file to determine where to load it into memory.

## Step 4: Building the Program

To compile and link your program, simply run:

```bash
make
```

This will produce a file called `HELLO.COM`, ready for deployment.

!!! note
    The resulting `HELLO.COM` file is only 23 bytes in size, very small. This
    is because the program basically only contains an instruction for a kernel
    function and nothing more.

## Step 5: Running the Program

Copy `HELLO.COM` to the SD card used by the ByteCradle system.

From the ByteCradle OS shell:

* Navigate to the folder containing the file using `cd`.
* Type the base name of the file (without the .COM extension):

```bash
hello
```

You should see:

```
Hello World!
```