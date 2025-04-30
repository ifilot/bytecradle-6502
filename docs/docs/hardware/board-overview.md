# Board Overview

## Tier System Overview

The platform currently consists of two distinct tiers, each targeting different
levels of complexity:

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

## Feature Comparison

| Feature               | Tiny SBC                         | Mini SBC                             |
|------------------------|----------------------------------|--------------------------------------|
| **RAM**                | 32 KiB                           | 512 KiB (bank switched)              |
| **ROM**                | 32 KiB                           | 512 KiB (bank switched)              |
| **Bank Switching**     | ❌                               | ✅ (64 × 8 KiB banks)                |
| **SD Card Support**    | ❌                               | ✅ (via 65C22 VIA)                   |
| **I/O Interface**      | 65C51 ACIA                       | 65C51 ACIA                           |
| **Expansion Options**  | Exposes system bus               | Exposes system bus and VIA bus       |