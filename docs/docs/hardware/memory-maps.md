# Memory Maps

## Tiny Board

The Tiny Board uses a flat 64 KiB memory map typical of 65C02-based systems. The
first 256 bytes (`$0000–$00FF`) are Zero Page RAM, followed by the stack
at `$0100–$01FF`. The range `$0200–$03FF` is reserved for OS use, while
`$0400–$7EFF` serves as general-purpose RAM.

A small I/O region at `$7F00–$7FFF` includes only `$7F04–$7F07`, which is
connected to a 65C51 ACIA UART for serial communication. The remainder of
the I/O space is currently unused but mapped to RAM, meaning it is technically
accessible for reads and writes. However, using this area is not
recommended, as future hardware revisions may repurpose it. Users may also
reconfigure the address decoding logic by updating the ATF22V10 chip to
change or expand the I/O mapping as needed.


The upper 32 KiB (`$8000–$FFFF`) is mapped to ROM, containing system
firmware such as a monitor or BASIC interpreter.


| Address Range | Size       | Description                                    |
|:--------------|:-----------|:-----------------------------------------------|
| `$0000-$00FF` | 256 bytes  | **Zero Page RAM**                              |
| `$0100-$01FF` | 256 bytes  | **Stack**                                      |
| `$0200-$03FF` | 512 bytes  | **Reserved (OS Use)**                          |
| `$0400-$7EFF` | ~31 KiB    | **General Purpose RAM**                        |
| `$7F00-$7F03` | 4 bytes    | **Unused / Reserved**                          |
| `$7F04-$7F07` | 4 bytes    | **ACIA (UART)**                                |
| `$7F08-$7FFF` | 248 bytes  | **Unused / Reserved**                          |
| `$8000-$FFFF` | 32 KiB     | **ROM**                                        |

## Mini Board

The Mini Board features a flexible 64 KiB memory map designed to support both
fixed and bank-switched memory regions. The lower memory (`$0000–$7EFF`) is
primarily RAM, with the first 256 bytes (`$0000–$00FF`) allocated as **Zero
Page**, and the next 256 bytes (`$0100–$01FF`) serving as the stack.
Addresses `$0200–$07FF` are reserved for OS-level functionality, while the
remainder up to `$7EFF` is available as general-purpose RAM, implemented
across fixed banks 0–3.

The region `$7F00–$7FFF` is dedicated to memory-mapped I/O, divided into
four 64-byte blocks using only address lines A6 and A7. The first block
(`$7F00–$7F3F`) connects to a 65C51 ACIA for serial communication, while the
second (`$7F40–$7F7F`) maps to a 6522 VIA. The remaining two blocks
(`$7F80–$7FBF` and `$7FC0–$7FFF`) are used to write to the ROM and RAM
bank registers, respectively.

The upper half of the address space is split between banked and fixed
ROM/RAM. The ranges `$8000–$9FFF` and `$A000–$BFFF` are bank-switched RAM
and ROM windows, supporting 64 banks each. The final 16 KiB (`$C000–$FFFF`) is
mapped to fixed ROM, permanently connected to banks 0 and 1, containing 
critical system firmware.

!!! warning 
    The bank-switched ROM and RAM regions (`$A000–$BFFF` and
    `$8000–$9FFF`) share the same physical memory space as the fixed ROM
    (`$C000–$FFFF`) and fixed RAM (`$0000–$7EFF`), respectively. This means that
    selecting ROM banks 0–1 or RAM banks 0–3 will expose the **same
    physical memory** already mapped in the fixed regions. For example, if RAM
    bank 0 is selected, writes may unintentionally modify the stack or zero
    page; selecting ROM bank 0 might interfere with the interrupt vectors or
    firmware routines.  

    While overlapping ROM banks are less problematic—since ROM is typically
    read-only and cannot be written to—it can still cause confusion or redundancy if
    the same code or data appears in both fixed and banked areas. It is strongly
    recommended to begin using **RAM banks from 4 upwards** and **ROM banks from 2
    upwards** to avoid overlapping with fixed memory areas and ensure predictable
    behavior.

| Address Range | Size       | Description                                                |
|:--------------|:-----------|:-----------------------------------------------------------|
| `$0000-$00FF` | 256 bytes  | **Zero Page RAM**                                          |
| `$0100-$01FF` | 256 bytes  | **Stack**                                                  |
| `$0200-$07FF` | 512 bytes  | **Reserved** (used by BCOS)                                |
| `$0800-$7EFF` | 30 KiB     | **General Purpose RAM (Fixed, Banks 0–3)**                 |
| `$7F00-$7F3F` | 64 bytes   | **ACIA (UART)**                                            |
| `$7F40-$7F7F` | 64 bytes   | **VIA**                                                    |
| `$7F80-$7FBF` | 64 bytes   | **ROM Bank Register**                                      |
| `$7FC0-$7FFF` | 64 bytes   | **RAM Bank Register**                                      |
| `$8000-$9FFF` | 8 KiB      | **Bank-switched RAM Window (Banks 0–63)**                  |
| `$A000-$BFFF` | 8 KiB      | **Bank-switched ROM Window (Banks 0–63)**                  |
| `$C000-$FFFF` | 16 KiB     | **Fixed ROM (Banks 0–1 mapped permanently)**               |
