# Introducing the ByteCradle 6502 Platform

The ByteCradle 6502 is a hands-on, 8-bit computing platform built around the
WDC 65C02 microprocessor. It is designed for hobbyists, educators, and
retrocomputing enthusiasts who want to dive into low-level system design,
assembly programming, and hardware experimentation.

## Tier System Overview

The platform is structured into two distinct tiers, each designed to balance
functionality and cost. Lower tiers offer more affordable options, but with
reduced feature sets compared to higher tiers.

### Tiny SBC

- Simplified design with a small footprint.
- Memory: 32 KiB RAM and 32 KiB ROM.
- Programmable logic: Utilizes small PLDs to minimize discrete components.
- Ideal for learning, experimentation, and small embedded projects.

### Mini SBC

- Advanced design with bank switching for greater memory capabilities.
- Memory: 512 KiB of RAM and 512 KiB of ROM (bank-switched).
- Programmable logic: Built around CPLDs for greater integration.
- Includes a 65C22 VIA to interface with an SD card for persistent
  storage and potential peripheral expansion.
- Perfect for exploring larger applications, file systems, and
  system-level programming.