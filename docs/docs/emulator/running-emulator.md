# Running the Emulator

Once compiled, you can run the emulator with the following syntax (adjust
accordingly for your paths):

```bash
./bc6502emu --board <tiny|mini> \
--rom <path_to_rom> \
[--sdcard <path_to_sdcard>] \
[--clock <mhz>]
```

## Arguments

| Argument          | Description                                    | Required |
|:------------------|:-----------------------------------------------|:---------|
| `-b, --board`     | Select the board type: `tiny` or `mini`.       | Yes      |
| `-r, --rom`       | Path to the ROM file to load.                  | Yes      |
| `-s, --sdcard`    | Path to the SD card image (only for `mini`).   | No       |
| `-c, --clock`     | CPU clock speed in MHz (default: 16.0 MHz).    | No       |

## Example Usage

To run the emulator with the `tiny` board:

```bash
./bc6502emu --board tiny --rom ../../src/tinyrom/tinyrom.bin
```

To run the emulator with the `mini` board and an SD card image:

```bash
./bc6502emu --board mini --rom ../../src/minirom.bin --sdcard ../scripts/sdcard.img --clock 12.0
```

!!! info 
    For running the `/MINI/` board, besides the ROM file, you will also need
    an SD-card image. This SD-card image can be generated using the
    `create_sd.sh` script found in the `emulator/script` folder.

!!! tip 
    For compiling the ROMs, we make use of a `Makefile`. These `Makefile`
    files contain the `make run` instruction which automatically launches the
    ROM in the emulator using the right settings. It does assume that the
    emulator has been compiled in the `build` folder as explained above.