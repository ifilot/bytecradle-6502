# First Power-Up

## Interfacing with the Board

Communication with the ByteCradle platform is handled via a **standard RS232
serial interface**, implemented using the onboard **65C51 ACIA** (Asynchronous
Communications Interface Adapter) and a **MAX232** line driver. This setup
ensures reliable and straightforward serial communication, supporting both TTL
and RS232 voltage levels.

The default communication settings are:

- **Baud Rate**: 115200
- **Data Bits**: 8
- **Parity**: None
- **Stop Bits**: 1

(commonly referred to as **8N1** configuration).

Several tools are available to interface with the board over RS232:

- **Windows**: [PuTTY](https://www.putty.org/), [Tera
  Term](https://osdn.net/projects/ttssh2/)
- **MacOS**: [CoolTerm](https://freeware.the-meiers.org/), or the built-in
  `screen` command
- **Linux**: [Minicom](https://help.ubuntu.com/community/Minicom), `screen`, or
  [picocom](https://linux.die.net/man/1/picocom)

!!! tip "Finding the correct serial port" 
    - **On Windows**: Open **Device
      Manager** and look under **Ports (COM & LPT)**. Your device will appear as
      something like `COM3`, `COM4`, etc. 
    - **On MacOS**: Use the command `ls
    /dev/tty.*` in Terminal. Look for entries like `/dev/tty.usbserial-XXXXX`. 
    - **On Linux**: Use `ls /dev/ttyUSB*` or `ls /dev/ttyACM*` depending on your
      USB-to-serial adapter. Common examples include `/dev/ttyUSB0`.

!!! note "Connection Tip" 
    After identifying the correct port, configure your
    terminal program with the settings above and open the connection. Upon
    powering up the ByteCradle, you should see output from the board if the
    connection is established correctly.
