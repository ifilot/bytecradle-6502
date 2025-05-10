# Board Overview

## Tier System Overview

ByteCradle’s hardware platform is designed with flexibility and accessibility in
mind, offering a scalable ecosystem for retro computing enthusiasts, embedded
developers, and educational environments. It features a tiered architecture to
accommodate both minimalistic setups and more capable systems, ensuring a smooth
learning curve while supporting increasingly complex applications. Each tier is
carefully engineered to balance performance, expandability, and simplicity,
making it easy to dive into 65xx-based system design, from first experiments to
advanced custom builds.

### Tiny SBC

- Simplified design with a small footprint.
- Memory: 32 KiB RAM and 32 KiB ROM.
- Programmable logic: Utilizes small PLDs to minimize discrete components.
- Ideal for learning, experimentation, and small embedded projects.

[🔍 View schematic](schematics-layout.md#tiny)

<p align="center">
  <img src="/assets/img/bytecradle-tinyboard-render-top.png" width="80%">
</p>

### Mini SBC

- Advanced design with bank switching for greater memory capabilities.
- Memory: 512 KiB of RAM and 512 KiB of ROM (bank-switched).
- Programmable logic: Built around CPLDs for greater integration.
- Includes a 65C22 VIA to interface with an SD card for persistent
  storage and potential peripheral expansion.
- Perfect for exploring larger applications, file systems, and
  system-level programming.

[🔍 View schematic](schematics-layout.md#tiny)

<p align="center">
  <img src="/assets/img/bytecradle-miniboard-render-top.png" width="100%">
</p>

## Feature Comparison

| Feature                | Tiny SBC                         | Mini SBC                             |
|------------------------|----------------------------------|--------------------------------------|
| **Frequency**          | 16 MHz                           | 12 MHz                               |
| **RAM**                | 32 KiB                           | 512 KiB (bank switched)              |
| **ROM**                | 32 KiB                           | 512 KiB (bank switched)              |
| **Bank Switching**     | ❌                               | ✅ (64 × 8 KiB banks)                |
| **SD Card Support**    | ❌                               | ✅ (via 65C22 VIA)                   |
| **Serial Interface**   | 65C51 ACIA                       | 65C51 ACIA                           |
| **I/O mapping**        | ATF22V10                         | ATF1502                              |
| **Expansion Options**  | Exposes system bus               | Exposes system bus and VIA bus       |

## Programmable logic

Both ByteCradle boards use programmable logic devices, a ATF22V10 PLD in the
:material-chip: **TINY** board and a ATF1502 CPLD for the :material-chip:
**MINI** board. These chips handle essential control logic like address
decoding, chip selects, and bank switching. These devices replace traditional
discrete logic chips (such as 74-series TTL), resulting in faster, more compact,
and more reliable designs.

### Tiny Board - ATF22V10

The :material-chip: **TINY** Board uses an ATF22V10 PLD to implement address
decoding and I/O mapping for RAM, ROM, and the ACIA serial interface. This chip
allows tight integration of logic without chaining multiple discrete components,
which reduces propagation delays. Its internal logic can respond in under 10 ns,
enabling the system to run stably at 16 MHz—much faster than typical retro
systems.

### Mini Board - ATF1502

The :material-chip: **MINI** Board uses an ATF1502 CPLD, which offers
significantly more logic resources. It handles complex tasks like dynamic RAM
and ROM bank switching, peripheral selection, and reading/writing to the bank
registers. Updates can be made through JTAG without changing hardware. The
CPLD's deterministic timing is critical for maintaining stability at 12 MHz.
