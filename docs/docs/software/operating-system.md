# Operating Systems

This page describes two minimalist operating systems: TINYROM, a ROM-based OS
for the TINY board featuring a menu-driven interface without disk storage, and
BCOS, a lightweight disk operating system for the MINI board providing basic
file management and serial communication using familiar Linux-style commands.

## TINYROM operating system (TINY board)

### Overview

TINYROM is a minimalist ROM-based operating system and runtime environment for
the :material-chip: **TINY** board. It is designed to be as small and simple as
possible, offering a bare-metal interface that boots directly into a menu-driven
selector for launching built-in programs, test routines, and games — all stored
within a compact 32 KiB ROM image.

Unlike more complex operating systems that manage filesystems or dynamic storage
(see below), TINYROM does not interface with disks or SD cards. Instead, it
provides a tiny kernel consisting solely of 
[low-level I/O routines](kernel-functions.md) for
communicating with the 65C51 ACIA serial interface. These routines allow basic
input and output over a serial terminal and form the foundation for user
interaction and debugging.

Upon startup, TINYROM presents a static selection menu through the serial
interface, enabling users to choose from a set of preloaded software — typically
small utilities, diagnostics, or simple games.

## ByteCradle Operating System (MINI board)

### Overview

The :material-chip: **MINI** board runs on BCOS (ByteCradle Operating System), a
minimalist, single-user disk operating system (SUDOS) purpose-built for the
MINI. Designed with clarity, compactness, and practical utility in mind, BCOS
offers essential functionality for persistent storage access and serial
communication, without the complexity of multitasking or modern OS abstractions.

At its core, BCOS presents a simple, navigable view of the SD card’s contents,
supporting basic file operations such as directory listing, file reading,
writing, and — critically — the ability to load and execute binary programs
directly from the SD card. This capability allows BCOS to serve as a lightweight
but extensible platform for launching standalone applications with minimal
runtime overhead.

In addition to its command-line shell, BCOS exposes a set of 
[low-level I/O routines](kernel-functions.md) for working with the 
65C51 ACIA serial interface. These include
functions for reading characters, writing characters, and outputting entire
strings over the serial port, enabling user programs to easily perform serial
communication without reimplementing low-level logic.

Communication via the 65C51 ACIA serves both as the user console and as a
fundamental I/O channel, making BCOS suitable for both interactive and automated
tasks on constrained 8-bit hardware.

### Navigation

BCOS leverages common Linux-style commands for file and directory management,
offering a familiar environment to users accustomed to Linux or UNIX systems.
Below are examples of frequently used commands:

- **List directory contents (`ls`)**: To view the files and directories within
  the current directory, simply type:
  ```
  ls
  ```

- **Change directory (`cd`)**: To navigate to another directory, use:
  ```
  cd dirname
  ```
  For example, to move up one directory level:
  ```
  cd ..
  ```

- **Executing programs**: Executable files typically have a `.COM` extension. To
  run these files, type their base name (without the `.COM` extension). For
  instance, to execute a program named `MYAPP.COM`, simply type:
  ```
  myapp
  ```

!!! note 
    While BCOS internally manages file names in uppercase, users may
    conveniently enter commands and file names in lowercase.