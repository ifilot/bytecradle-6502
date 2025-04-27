# Assembling the Board

## Flashing the ROM

Before powering up your ByteCradle board for the first time, it's essential to flash the appropriate ROM image onto the onboard memory chip. The required ROM chip and image depend on the variant of the board:

- **ByteCradle Mini**: Uses an **SST39SF040** (4 Mbit) chip.
- **ByteCradle Tiny**: Uses an **SST39SF010** (1 Mbit) chip.

Each board requires a specific ROM file that matches its hardware configuration.

## Required Tools

To flash the ROM, you'll need a compatible **EPROM/Flash programmer**. Options include:

- **Commercial Programmers**:
    * [TL866II Plus](https://www.autoelectric.cn/en/tl866_main.html): A popular, affordable universal programmer.
    * [XGecu T48](https://www.xgecu.com/EN/): A more advanced model supporting a wide range of devices.
- **Open Source and DIY Alternatives**:
    * [Pico-SST39SF0x0 Programmer](https://github.com/ifilot/pico-sst39sf0x0-programmer): A lightweight and affordable programmer using a Raspberry Pi Pico.
    * **Arduino-based Flashers**: Utilize an Arduino (e.g., Uno) with community firmware for programming simple parallel flash devices.

!!! note "Choosing a Flasher"
    Commercial programmers offer ready-to-use software and broad device support. However, open-source solutions like the Pico-SST39SF0x0 Programmer are cost-effective and excellent for DIY enthusiasts.

## Flashing Process Overview

1. **Set Up the Programmer**:
   - For the Pico-SST39SF0x0 Programmer:
     - Flash your Raspberry Pi Pico with the firmware from the [GitHub repository](https://github.com/ifilot/pico-sst39sf0x0-programmer).
     - Connect the ROM chip to the Pico according to the wiring guide provided in the repository.

2. **Load the ROM File**:
   - Open your flashing software.
   - Select the correct chip type from the supported devices list.
   - Load the appropriate ROM image for your ByteCradle board variant.

3. **Write and Verify**:
   - Erase the chip if necessary (some programmers do this automatically).
   - Write the ROM file to the flash chip.
   - Perform a verification pass to confirm the write was successful.

!!! tip "Pico-SST39SF0x0 Programmer Quick Start"
    1. Connect the Raspberry Pi Pico to your computer via USB.
    2. Use the `picoprog` command-line tool to flash the ROM:
        ```bash
        picoprog -p /dev/ttyACM0 write your_rom_file.bin
        ```
        Replace `/dev/ttyACM0` with the correct serial device path for your system.

4. **Install the ROM**:
   - After successful flashing, insert the ROM chip carefully into the ByteCradle board's socket, ensuring correct orientation.

Once the ROM is programmed and installed, you're ready to proceed with the first power-up!
