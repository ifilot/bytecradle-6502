# Introducing the ByteCradle 6502 Platform

The **ByteCradle 6502** is a hands-on, 8-bit computing platform built around the
**WDC 65C02** microprocessor. It is designed for hobbyists, educators, and
retrocomputing enthusiasts who want to dive into **low-level system design**,
**assembly programming**, and **hardware experimentation**.

The platform intentionally keeps the **chip count low**, using **programmable
logic devices (PLDs)** and **complex programmable logic devices (CPLDs)** to
simplify circuitry while maintaining expandability and flexibility.

## Tier System Overview

The platform currently consists of two distinct tiers, each targeting different
levels of complexity:

### Tiny SBC

- **Simplified design** with a small footprint.
- **Memory**: 32 KiB RAM and 32 KiB ROM.
- **Programmable logic**: Utilizes small PLDs to minimize discrete components.
- Ideal for **learning**, **experimentation**, and **small embedded projects**.

### Mini SBC

- **Advanced design** with bank switching for greater memory capabilities.
- **Memory**: 512 KiB of RAM and 512 KiB of ROM (bank-switched).
- **Programmable logic**: Built around CPLDs for greater integration.
- Includes a **65C22 VIA** to interface with an **SD card** for **persistent
  storage** and potential peripheral expansion.
- Perfect for exploring **larger applications**, **file systems**, and
  **system-level programming**.

## Interfacing with the Board

Communication with the ByteCradle platform is exclusively handled through a
**standard RS232 serial interface**, made possible by:

- **65C51 ACIA** (Asynchronous Communications Interface Adapter)
- **MAX232** line driver

This setup provides reliable, easy-to-use serial communication at TTL/RS232
levels.

**Important notes:**

- Users can easily connect to the board using **cheap USB-to-RS232 adapters**.
- **No null-modem cable is required** — the board's RX and TX lines are already
  correctly crossed internally. A **regular straight-through RS232 cable** is
  all that is needed.

## Goals and Philosophy

The ByteCradle platform is not just about the hardware — it's about learning by
doing:

- **Assembly programming** on real 8-bit hardware.
- Understanding **system management**, **BIOS-level design**, and **memory
  architecture**.
- **Cross-platform toolchains**: Write, assemble, and flash programs using
  modern development environments.
- **Experimentation** with low-level computing concepts such as:
- Direct memory access
- Peripheral interfacing
- Bank switching
- Bootloader/BIOS customization
- SD card file systems (Mini SBC)