# ByteCradle 6502 Emulator

**bc6502emu** is a lightweight emulator for 6502-based systems, supporting two
board variants: **tiny** and **mini**.  
It is designed for simple and fast emulation, providing a CLI interface to load
ROMs and optional SD card images.

## Features

- Emulates ByteCradle 6502 "tiny" and "mini" boards.
- Supports loading external ROM files.
- SD card image support for the "mini" board variant.
- Configurable CPU clock speed (default: 16 MHz).
- Terminal input handling (keyboard polling every 20ms).
- Lightweight and simple C++ codebase.

## Compilation

* Make sure you have a C++17 (or newer) compiler installed and the CMake
  utilities.
* You also need the **TCLAP** library installed or available.

### Dependencies

```bash
sudo apt update && sudo apt install build-essential cmake libtclap-dev
```

### Build instructions (with CMake)

```bash
mkdir build
cd build
cmake ../src
make -j
```

This will generate an executable called `bytecradle` inside the `build/` directory.

## Usage

```bash
./bytecradle --board <tiny|mini> --rom <path_to_rom> [--sdcard <path_to_sdcard>] [--clock <mhz>]
```

### Arguments:

| Argument         | Description                                    | Required |
|:-----------------|:-----------------------------------------------|:---------|
| `-b, --board`     | Select the board type: `tiny` or `mini`.       | Yes      |
| `-r, --rom`       | Path to the ROM file to load.                  | Yes      |
| `-s, --sdcard`    | Path to the SD card image (only for `mini`).    | No       |
| `-c, --clock`     | CPU clock speed in MHz (default: 16.0 MHz).     | No       |

### Example:

```bash
./bytecradle --board tiny --rom <romfile>.bin
```

or for a mini board with an SD card image:

```bash
./bytecradle --board mini --rom <romfile>.bin --sdcard disk.img --clock 8.0
```