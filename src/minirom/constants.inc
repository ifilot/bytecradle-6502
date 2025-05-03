.PSC02

; 65C51 ACIA
.define ACIA_DATA       $7F04  ; Transmit/Receive Data Register
.define ACIA_STAT       $7F05  ; Status Register (read) - flags like TDRE, RDRF, DCD, etc.
.define ACIA_CMD        $7F06  ; Command Register (write) - controls RTS, DTR, IRQs, etc.
.define ACIA_CTRL       $7F07  ; Control Register - sets baud rate, word length, stop bits, parity

; 65C22 VIA Register Definitions (Base = $7F10)
.define VIA_PORTB        $7F40  ; Register 0: I/O Port B
.define VIA_PORTA        $7F41  ; Register 1: I/O Port A
.define VIA_DDRB         $7F42  ; Register 2: Data Direction Register B
.define VIA_DDRA         $7F43  ; Register 3: Data Direction Register A
.define VIA_T1CL         $7F44  ; Register 4: Timer 1 Counter Low
.define VIA_T1CH         $7F45  ; Register 5: Timer 1 Counter High
.define VIA_T1LL         $7F46  ; Register 6: Timer 1 Latch Low
.define VIA_T1LH         $7F47  ; Register 7: Timer 1 Latch High
.define VIA_T2CL         $7F48  ; Register 8: Timer 2 Counter Low
.define VIA_T2CH         $7F49  ; Register 9: Timer 2 Counter High
.define VIA_SR           $7F4A  ; Register 10: Shift Register
.define VIA_ACR          $7F4B  ; Register 11: Auxiliary Control Register
.define VIA_PCR          $7F4C  ; Register 12: Peripheral Control Register
.define VIA_IFR          $7F4D  ; Register 13: Interrupt Flag Register
.define VIA_IER          $7F4E  ; Register 14: Interrupt Enable Register
.define VIA_PORTA_NOHS   $7F4F  ; Register 15: Port A w/o Handshake (alias of Reg 1)

; keyboard buffer variables
.define TBPR            $00
.define TBPL            $01
.define TB              $0200   ; store textbuffer in page 2

; general buffer addresses (ZP), these can be used by a number of programs
; in the monitor
.define BUF1            $02
.define BUF2            $03
.define BUF3            $04
.define BUF4            $05
.define BUF5            $06
.define BUF6            $07
.define BUF7            $08
.define BUF8            $09
.define BUF9            $0A

; zero-page addresses for the monitor
.define CHAR1           $10
.define CHAR2           $11
.define CHAR3           $12
.define CHAR4           $13
.define NRCHARS         $14
.define STARTADDR       $16
.define ENDADDR         $18
.define MALB            $1A     ; monitor address low byte
.define MAHB            $1B     ; monitor address high byte
.define NRLINES         $1C     ; number of lines (word) to print by hexdump routine

; specific ZP addresses for the hexdump routine of the monitor
.define STRLB           $1E     ; string low byte
.define STRHB           $1F     ; string high byte

; textbuffer variables
.define CMDLENGTH       $20     ; number of bytes in buffer, max 16
.define CMDBUF          $30     ; position of command buffer

; print characters
.define LF              $0A     ; LF character (line feed)
.define CR              $0D     ; CR character (carriage return)
.define ESC             $1B     ; VT100 escape character