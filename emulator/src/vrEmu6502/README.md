# vrEmu6502 (Modified)

The W65C02 emulation core was originally developed by **Troy Schrapel** and
obtained from  
[https://github.com/visrealm/vrEmu6502](https://github.com/visrealm/vrEmu6502).

This version has been **modified by Ivo Filot** for the **ByteCradle 6502**
project to support passing a user-defined context pointer (`userData`) to the
memory access callbacks (`memRead` and `memWrite`).  
These modifications allow easier integration of vrEmu6502 into object-oriented
emulator designs.

All original credits and licenses are retained.
