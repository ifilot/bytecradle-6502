# Welcome to ByteCradle 6502 Documentation

The **ByteCradle 6502** is a **single-board computer (SBC)** platform built
around the **WDC 65C02** microprocessor.   It is designed for learning and
experimenting with **simple operating systems** on **8-bit hardware**. Whether
you are new to 8-bit computers or an experienced hardware tinkerer, ByteCradle
offers an accessible and expandable environment to explore these topics.

## Tier System

ByteCradle offers two tiers of SBCs, catering to different project scopes:

- **Tiny SBC**: A minimalistic, compact system ideal for education and small embedded applications.
- **Mini SBC**: A feature-rich version with bank switching, SD card storage, and an expansion bus through the 65C22 VIA.

## Feature Comparison

| Feature               | Tiny SBC                         | Mini SBC                             |
|------------------------|----------------------------------|--------------------------------------|
| **RAM**                | 32 KiB                           | 512 KiB (bank switched)              |
| **ROM**                | 32 KiB                           | 512 KiB (bank switched)              |
| **Bank Switching**     | ❌                               | ✅ (64 × 8 KiB banks)                |
| **SD Card Support**    | ❌                               | ✅ (via 65C22 VIA)                   |
| **I/O Interface**      | 65C51 ACIA                       | 65C51 ACIA                           |
| **Expansion Options**  | Exposes system bus               | Exposes system bus and VIA bus       |