# Firmware

This folder contains the firmware for the [Parallax Propeller](https://www.parallax.com/) microcontroller, 
which was originally designed to emulate a ANSI / VT-100 serial terminal for the
[RC2014](http://rc2014.co.uk/). Like the ByteCradle 6502, the main interface
proceeds via the UART and by simply connecting the primary UART of the ByteCradle
6502 with the Parallax Propeller, the same functionality can be achieved.

All files are obtained from [this source](https://github.com/maccasoft/propeller-vt100-terminal).

## Compilation

Download [Openspin](https://www.maccasoft.com/downloads/) from here and compile
the source code via

```bash
openspin -b -u vt100.spin
```

The resulting file, `vt100.binary` can be flashed to the 24LC256 eeprom.