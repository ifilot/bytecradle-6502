# First Power-Up and Testing

## Hooking up the Power Supply

The ByteCradle board requires a **5V power supply** capable of delivering at
least **500 mA** of current. Power is supplied through a **USB-B connector**.
The ByteCradle **does not** have any on-board power regulation. It is critical
to use a **reliable and regulated 5V power source** to avoid damaging the board.
Recommended options include:
    
- A direct connection to a **computer USB port**
- A **certified USB wall adapter** rated for 5V output

!!! warning "Power Supply Safety"    
    Avoid using low-quality or unregulated power adapters, as unstable voltages can cause erratic behavior or permanent damage to the board.

!!! note "Power-Up Sequence"
    Before powering up the board, make sure the **serial communication cable** (see next section) is connected and a **serial port** has been opened on your computer. This ensures you will see the header information that the board outputs upon boot. If you power on the board before setting up the serial connection, you can still communicate with it, but you will miss the initial startup messages. In that case, simply press the **reset button** on the board to perform a cold boot and re-trigger the startup sequence.

## Setting Up Serial Communication

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

## Boot screen

If everything is working correctly, you should see the following boot screens
as shown below.

For the :material-chip: **TINY** board:

```
+----------------------------------------------+
| BYTECRADLE /TINY/ ROM                        |
+----------------------------------------------+
| RAM  : 0x0000 - 0x7EFF                       |
| ROM  : 0x8000 - 0xFFFF                       |
| IO   : 0x7F00 - 0x7FFF                       |
| ACIA : 0x7F04 - 0x7F0F                       |
+----------------------------------------------+
|     SELECT CATEGORY                          |
|                                              |
| (t) Test routines                            |
| (a) Applications                             |
| (g) Games                                    |
| (m) Monitor                                  |
+----------------------------------------------+
```

and for the :material-chip: **MINI** board:

```
 ____             __           ____                      __   ___
/\  _`\          /\ \__       /\  _`\                   /\ \ /\_ \
\ \ \L\ \  __  __\ \ ,_\    __\ \ \/\_\  _ __    __     \_\ \\//\ \      __
 \ \  _ <'/\ \/\ \\ \ \/  /'__`\ \ \/_/_/\`'__\/'__`\   /'_` \ \ \ \   /'__`\
  \ \ \L\ \ \ \_\ \\ \ \_/\  __/\ \ \L\ \ \ \//\ \L\.\_/\ \L\ \ \_\ \_/\  __/
   \ \____/\/`____ \\ \__\ \____\\ \____/\ \_\\ \__/.\_\ \___,_\/\____\ \____\
    \/___/  `/___/> \\/__/\/____/ \/___/  \/_/ \/__/\/_/\/__,_ /\/____/\/____/
               /\___/
               \/__/
  ____  ______     __      ___
 /'___\/\  ___\  /'__`\  /'___`\
/\ \__/\ \ \__/ /\ \/\ \/\_\ /\ \
\ \  _``\ \___``\ \ \ \ \/_/// /__
 \ \ \L\ \/\ \L\ \ \ \_\ \ // /_\ \
  \ \____/\ \____/\ \____//\______/
   \/___/  \/___/  \/___/ \/_____/

Starting system.
Clearing user space...   [OK]
Connecting to SD-card... [OK]
:/>
```