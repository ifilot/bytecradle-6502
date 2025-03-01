# BYTECRADLE 6502

![Under Construction](https://img.shields.io/badge/status-under--construction-orange?logo=github)
[![Build](https://github.com/ifilot/bytecradle-6502/actions/workflows/build.yml/badge.svg)](https://github.com/ifilot/bytecradle-6502/actions/workflows/build.yml)
[![Documentation](https://github.com/ifilot/bytecradle-6502/actions/workflows/docs.yml/badge.svg)](https://github.com/ifilot/bytecradle-6502/actions/workflows/docs.yml)

> [!tip]
> Detailed documentation on the ByteCradle 6502 can be found 
> [here](https://ifilot.github.io/bytecradle-6502/).

The **ByteCradle 6502** is a **single-board computer (SBC)** designed for
understanding and experimenting with **simple operating systems** on **8-bit
hardware**. Built around the **WDC 65C02** microprocessor, it provides a
hands-on platform for studying **system initialization, memory management,
device interfacing, and file system handling**.  

The system includes **544 KiB of RAM, bank-switched ROM, serial communication
via a 65C51 UART, and SD card support with a FAT32 file system**, allowing users
to work with a **hierarchical file structure** similar to classic microcomputer
environments. This makes it ideal for learning how **basic OS components
interact with hardware**, such as **drivers, file systems, and boot processes**.  

## Specifications  

- **CPU:** WDC 65C02  
- **Clock Speed:** 10 MHz
- **RAM:** 544 KiB (32 KiB base + 512 KiB banked)  
- **ROM:** 512 KiB (32 × 16 KiB banks)  
- **Storage:** SD card with FAT32 support  
- **Serial Communication:** 65C51 UART, 115200 BAUD  
- **Expansion:** Interfaces for peripherals and additional hardware  

The ByteCradle 6502 serves as a **practical tool for developing and testing
8-bit operating system features**, including **bootloaders, basic file
management, and low-level hardware access**, providing insight into the
foundations of classic computing.