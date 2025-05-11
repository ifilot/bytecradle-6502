# Assembling the Board

## Soldering Components

When assembling the board, it's best to solder components in order of increasing height. This helps keep parts steady and ensures easier access during soldering. Follow the sequence below to make the process smooth and efficient.

### Tiny Board Assembly Guide

1. **Begin with the resistors**: Solder R1 through R6. These are flat and
   easiest to place first.

2. **Socket for CAN oscillator (X1)**: If you plan to socket the CAN oscillator,
   install its socket now before moving on.

3. **Install the DIP sockets**: Proceed with U1, U2, and U4 through U7. Note
   that U3 does not need a socket.  
   If your ceramic capacitors are taller than the DIP sockets, consider
   soldering the capacitors first (see next step) to avoid height conflicts.

4. **Add the ceramic capacitors**: Solder C1, C3, and C5 through C10. Also add
   C11.  
   Be careful with C12 — it should be a **30pF capacitor**, while the others are
   **100nF** and usually don’t have markings on the silkscreen.

5. **Place the DS1813 component**: This goes at U3 and should be inserted
   carefully.

6. **Install the tactile switches**: Mount SW2 and SW3. These are 6mm tall.

7. **Solder the LED**: Install the 5mm LED at D1, making sure the orientation is
   correct.

8. **Attach the pin header**: Solder the 2x20 male pin header at J2.

9. **Install the USB connector**: Solder the USB type B connector at J1.

10. **Add the serial connector**: Install the 9-pin SUBD serial port.

11. **Install the 10µF electrolytic capacitors**: Place C2 and C12 through C15.  
    Watch the polarity — these capacitors are polarized.

12. **Install the 100µF electrolytic capacitor**: Solder C4, also making sure to
    observe polarity.

13. **Place the oscillator**: Insert the 1.8432 MHz crystal oscillator at Y1.

14. **Finish with the toggle switch**: Finally, install SW1 — the tallest
    component — to complete the board.

Once all components are soldered, the only remaining task is to **insert the
chips into their sockets**. Be sure to align the chips correctly according to
the notch or dot marking on each IC and the corresponding silkscreen indicator
on the board.

## Flashing the ROM

Before powering up your ByteCradle board for the first time, it is essential to
flash the appropriate ROM image onto the onboard memory chip. The required ROM
chip and image depend on the variant of the board:

- **ByteCradle Tiny**: Uses an **SST39SF010** (1 Mbit) chip.
- **ByteCradle Mini**: Uses an **SST39SF040** (4 Mbit) chip.

Each board requires a specific ROM file that matches its hardware configuration.

### Required Tools

To flash the ROM, you'll need a compatible **EPROM/Flash programmer**. Options include:

- **Commercial Programmers**:
    * [TL866II Plus](https://www.autoelectric.cn/en/tl866_main.html): A popular, affordable universal programmer.
    * [XGecu T48](https://www.xgecu.com/EN/): A more advanced model supporting a wide range of devices.
- **Open Source and DIY Alternatives**:
    * [Pico-SST39SF0x0 Programmer](https://github.com/ifilot/pico-sst39sf0x0-programmer): A lightweight and affordable programmer using a Raspberry Pi Pico.
    * **Arduino-based Flashers**: Utilize an Arduino (e.g., Uno) with community firmware for programming simple parallel flash devices.

!!! note "Choosing a Flasher"
    Commercial programmers offer ready-to-use software and broad device support. However, open-source solutions like the Pico-SST39SF0x0 Programmer are cost-effective and excellent for DIY enthusiasts.

### Flashing Process Overview

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

4. **Install the ROM**:
    - After successful flashing, insert the ROM chip carefully into its socket, **ensuring correct orientation**.

---

[:material-arrow-right: Next: Proceed to the first power up](first-power-up.md)