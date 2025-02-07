# BYTECRADLE 6502

[![Documentation](https://github.com/ifilot/bytecradle-6502/actions/workflows/docs.yml/badge.svg)](https://github.com/ifilot/bytecradle-6502/actions/workflows/docs.yml)

The **ByteCradle 6502** is a compact and efficient **Single-Board Computer
(SBC)** powered by the **Western Design Center (WDC) 65C02** microprocessor.
Designed for retro-computing enthusiasts, hobbyists, and embedded system
developers, this SBC retains full compatibility with the classic 6502
architecture while benefiting from the 65C02's enhanced instruction set. The
ByteCradle 6502 features 544 KiB RAM, 512 KiB ROM, serial communication, and
expansion interfaces, providing a versatile platform for software development,
embedded applications, and educational purposes. With support for assembly
language programming and a custom 6502-based operating systems, this SBC is an
excellent choice for those looking to explore classic computing principles in a
modern(-ish) environment.

> [!tip]
> Detailed documentation on the ByteCradle 6502 can be found 
> [here](https://ifilot.github.io/bytecradle-6502/).

## Features

* CPU: 65C02
* Clock frequency: 10 MHz
* RAM: 544 KiB: 32 KiB base RAM + 512 KiB bankable RAM
* ROM: 512 KiB (32 x 16 KiB banks)
* UART: 115200 BAUD using 65C51