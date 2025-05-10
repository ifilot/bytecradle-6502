# Kernel functions

The system exposes a set of core kernel functions at fixed memory addresses
located just below the 6502 vector table. This area is referred to as the **jump
table**.

Each jump table entry is a 3-byte `JMP` instruction that redirects to the actual
implementation of a function. This design allows system programs and user
applications to call kernel routines via **stable, absolute addresses**,
regardless of where the underlying code is actually located.

## How It Works

The jump table starts at address `$FFE5`, with each function occupying 3 bytes
(the size of a `JMP` absolute instruction). For example:

```assembly
jsr $FFE5  ; call putstr
```

This instruction jumps to the putstr routine, allowing the user to print a
string without needing to know where putstr is implemented in memory. This makes
the jump table a forward-compatible interface to the kernel.

## Overview jump table

Below is an overview of currently available jump table entries:

| Label      | Address | Description                                             | Input Registers                    | Garbled Registers    |
|------------|---------|---------------------------------------------------------|------------------------------------|----------------------|
| `putstr`   | `$FFE5` | Prints a null-terminated string.                        | `X:A` = High:Low pointer to string | `A`, `X`, `Y`        |
| `putstrnl` | `$FFE8` | Prints a null-terminated string followed by a CRLF.     | `X:A` = High:Low pointer to string | `A`, `X`, `Y`        |
| `putch`    | `$FFEB` | Outputs a single character to ACIA.                     | `A` = Character                    | *None*               |
| `newline`  | `$FFEE` | Prints carriage return and line feed.                   | -                                  | *None*               |
| `puthex`   | `$FFF1` | Prints a byte in hexadecimal format.                    | `A` = Byte to print                | *None*               |
| `putdec`   | `$FFF4` | Prints a byte in decimal format.                        | `A` = Byte to print                | `X`, `Y`             |
| `getch`    | `$FFF7` | Retrieves a character from input buffer.                | —                                  | `A`                  |

!!! note 
    The jump table is exactly the same for both the :material-chip: **TINY**
    and :material-chip: **MINI** boards.

!!! warning 
    *Garbled* refers to CPU registers whose contents
    are **modified or overwritten** by a routine and are **not restored** before
    returning. This means the calling code **should not rely on the original
    values** of these registers after the routine executes.

    For example, if a function garbles register `X`, then any value that was in 
    `X` before the function call may be lost and should not be assumed valid 
    afterward. To preserve important register values across such calls, the 
    caller is responsible for saving and restoring them (e.g., using `PHA`, 
    `PHX`, `PHY` and their corresponding pull instructions).