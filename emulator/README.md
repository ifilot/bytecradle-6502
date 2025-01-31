# ByteCradle 6502 Emulator

## Compilation instructions

```bash
mkdir build
cd build
cmake ../src
make -j
```

## Running

In order to run the emulator, you have to provide a path to the ROM file. The
emulator assumes that the ROM file is exactly 16 KiB in size.

```bash
./bc6502emu monitor.bin
```