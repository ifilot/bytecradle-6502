# BCOS

BCOS is a basic operating system for the ByteCradle 6502. The OS offers simple
I/O routines for keyboard handling and terminal output. It also has the drivers
to interface with the SD-card.

## Compilation

Ensure you have [cc65](https://cc65.github.io/) installed on your system. Simply
run `make` to compile everything. The resulting `sbc.rom` needs to be flashed
to the first bank of the SST39SF040 EEPROM.