# Installing and Running the Emulator

This guide explains how to compile and run the `bc6502emu` emulator on a modern
POSIX-compatible system. The emulator supports both the `tiny` and `mini`
variants of the ByteCradle 6502 board and is designed for fast and simple
command-line usage.

## Platform Requirements

We assume you are working in a [POSIX](https://en.wikipedia.org/wiki/POSIX) environment, such as Linux or macOS.  
For Windows users, we warmly recommend installing 
[Windows Subsystem for Linux (WSL)](https://learn.microsoft.com/en-us/windows/wsl/).
All development and testing have been done using Ubuntu, and we recommend it as the reference environment.

## Prerequisites

Before you begin, make sure your system meets the following requirements:

- A C++17-compatible compiler
- [CMake](https://cmake.org/) for managing the build process
- The [TCLAP](https://tclap.sourceforge.net/) library for command-line parsing

To install all required dependencies on Ubuntu or Debian-based systems, run:

```bash
sudo apt update && sudo apt install build-essential cmake libtclap-dev
```

After compilation, the emulator binary will be located in the `build` directory
under the name `bc6502emu`.

!!! tip "Ready to start using the emulator?"
    Go to the [Running the Emulator](./running-emulator.md)