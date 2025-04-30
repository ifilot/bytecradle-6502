# Emulator Overview

Developing software for the ByteCradle 6502 platform without an emulator
involves a tedious and repetitive workflow: you would need to cross-assemble or
cross-compile your source code, flash it onto a ROM, physically insert that ROM
into the board, and then run the board to test your code. Each cycle can take
several minutes and is prone to errors, making rapid development and testing
difficult.

The `bc6502emu` emulator removes these barriers by allowing you to run and test
your 6502 code directly on a modern computer. It integrates cleanly into your
development workflow and enables fast iteration without the need for physical
hardware during the early stages of development.

## Benefits of Using an Emulator

- **Rapid testing and iteration**: Instantly test code changes without flashing or hardware interaction, dramatically reducing development time.
- **Safe and controlled environment**: Reproducible and isolated, ideal for debugging, testing edge cases, and avoiding hardware wear or damage.
- **Simplified debugging**: Observe program behavior, simulate input, and analyze results using standard tools on your development machine.
- **Development without hardware**: Start writing and validating software even before hardware is available or finalized.
- **Automation and integration**: Easily integrate into build systems and CI pipelines for automated testing and validation.

## Introducing `bc6502emu`

`bc6502emu` is a lightweight emulator designed specifically for the ByteCradle
6502 platform. It supports the two board variants:

- **tiny** – a minimal configuration without SD card storage.
- **mini** – includes SD card image support for simulating file I/O and the 65C22 versatile interface adapter.

With `bc6502emu`, you can:

- Run 6502 binaries directly from your development environment.
- Simulate SD card behavior (mini variant).
- Configure the emulated CPU clock speed.
- Provide terminal input for programs that rely on user interaction.

!!! tip "Ready to get started?"
    Go to the [Installing Emulator](./installing-emulator.md) page to compile and run the emulator.