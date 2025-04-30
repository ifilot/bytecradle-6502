# Introducing the ByteCradle 6502 Platform

In the 1970s, the future of personal computing was **8-bit**. Microcomputers and
home computers of the era almost universally began with 8-bit processors. The
legacy of this era still shapes computing today — the prominence of the **byte**
as a standard unit of storage and data is a direct inheritance from these early
systems.

The **ByteCradle 6502** embraces this legacy. It is a hands-on, 8-bit computing
platform built around the **WDC 65C02** microprocessor, a modern variant of the
classic MOS 6502. Designed for hobbyists, educators, and retrocomputing
enthusiasts, the **ByteCradle 6502** offers a practical gateway into low-level
system design, assembly programming, and hardware experimentation — all in the
spirit of the early home computer revolution.

## Tier System Overview

The platform is structured into two distinct tiers, each designed to balance
functionality and cost. Lower tiers offer more affordable options, but with
reduced feature sets compared to higher tiers.

### Tiny SBC

- 65C02 processor running at 16 MHz
- Simplified design with a small footprint.
- Memory: 32 KiB RAM and 32 KiB ROM.
- I/O communication via a 65C51 ACIA.
- Programmable logic: Utilizes small PLDs to minimize discrete components.
- Ideal for learning, experimentation, and small embedded projects.

### Mini SBC

- 65C02 processor running at 8 MHz
- Advanced design with bank switching for greater memory capabilities.
- Memory: 512 KiB of RAM and 512 KiB of ROM (bank-switched).
- I/O communication via a 65C51 ACIA.
- Programmable logic: Built around CPLDs for greater integration.
- Includes a 65C22 VIA to interface with an SD card for persistent
  storage and potential peripheral expansion.
- Perfect for exploring larger applications, file systems, and
  system-level programming.