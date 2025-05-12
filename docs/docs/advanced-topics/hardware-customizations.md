# Hardware customization

ByteCradle was built from the ground up with openness and user empowerment in
mind. As an open-source single board computer, it invites users not only to
explore the software but to dive deep into the hardware itself. The system is
designed to be educational, extendable, and hackable—encouraging curiosity and
experimentation at every level.

To support this vision, we provide a number of hardware customization options
that users can implement with basic tools and an understanding of the 6502
platform.

## Upgrading Serial Communication Speed

By default, the ByteCradle board uses a **65C51 ACIA** for serial communication,
clocked by a 1.8432 MHz crystal (or resonator). With the ACIA's fixed ×16
clock divider, this yields a standard 115200 BAUD rate.

For users seeking faster serial communication, this BAUD rate can be increased
by replacing the crystal with a higher frequency one. The following
configurations have been tested and shown to provide stable operation:

| Crystal Frequency | Effective BAUD Rate |
|-------------------|---------------------|
| 1.8432 MHz        | 115200              |
| 3.6864 MHz        | 230400              |
| 7.3728 MHz        | 460800              |

!!! warning
    If you replace the crystal of the ACIA crystal, you **need** to adjust the
    software accordingly. More information is provided below.

To upgrade your board:

1. **Physically replace** the 1.8432 MHz crystal with a compatible 3.6864 MHz or
   7.3728 MHz crystal.
2. **Update your terminal or serial communication software** to match the new
   BAUD rate.
3. **Adjust the initialization script** or system configuration to reflect the
   new BAUD rate. Example code can be found below.

!!! note
    Not all USB-to-Serial adapters or operating systems handle higher
    BAUD rates reliably. Be sure to test stability under your specific setup.

The script below is the default assembly subroutine, found in `io.s` that prints
out a single character to the serial port. If you replace the crystal resonator,
you **need** to adjust the delay value. For example, if you use a Tiny Board
running at 16 MHz with a 7.3728 MHz crystal and a 460800 BAUD rate, you need a
delay of 16e6 * 10 / 460800 / 7 = 50.

```
;-------------------------------------------------------------------------------
; putchar routine
;
; Converves A
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting.
; At 12 MhZ, we need to wait 12e6 * 10 / 115200 / 7 = 149 clock cycles,
; where the 5 corresponds to the combination of "DEC" and "BNE" taking 5 clock
; cyles.
;
;  4.000 MHz    :  50
; 10.000 MHz    : 124
; 12.000 MHz    : 149 (works on Tiny; works on Mini)
; 16.000 MHz    : 198 (works on Tiny; does *not* work on Mini)
;-------------------------------------------------------------------------------
_putch
putch:
    pha             ; preserve A
    sta ACIA_DATA   ; write the character to the ACIA data register
    lda #149        ; initialize inner loop
@inner:
    nop             ; NOP; 2 cycles
    dec             ; decrement A; 2 cycles
    bne @inner      ; check if zero; 3 cycles
    pla             ; retrieve A from stack
    rts
```

For your convenience, you can consult the table as shown below.

| CPU Clock | ACIA Crystal | BAUD Rate | Delay Cycles |
|-----------|---------------|------------|---------------|
| 4.000 MHz | 1.8432 MHz    | 115200     | 50            |
|10.000 MHz | 1.8432 MHz    | 115200     | 124           |
|12.000 MHz | 1.8432 MHz    | 115200     | 149           |
|16.000 MHz | 1.8432 MHz    | 115200     | 198           |
| 4.000 MHz | 3.6864 MHz    | 230400     | 25            |
|10.000 MHz | 3.6864 MHz    | 230400     | 62            |
|12.000 MHz | 3.6864 MHz    | 230400     | 74            |
|16.000 MHz | 3.6864 MHz    | 230400     | 99            |
| 4.000 MHz | 7.3728 MHz    | 460800     | 12            |
|10.000 MHz | 7.3728 MHz    | 460800     | 31            |
|12.000 MHz | 7.3728 MHz    | 460800     | 37            |
|16.000 MHz | 7.3728 MHz    | 460800     | 50            |