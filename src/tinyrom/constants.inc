.PSC02

; memory mapped control lines, used for daughterboards
.define CTRLB1          $7F00  ; control line 1; active LOW
.define CTRLB2          $7F01  ; control line 2; active LOW

; 65C51 ACIA
.define ACIA_DATA       $7F04  ; Transmit/Receive Data Register
.define ACIA_STAT       $7F05  ; Status Register (read) - flags like TDRE, RDRF, DCD, etc.
.define ACIA_CMD        $7F06  ; Command Register (write) - controls RTS, DTR, IRQs, etc.
.define ACIA_CTRL       $7F07  ; Control Register - sets baud rate, word length, stop bits, parity

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
.define BS              $7F     ; BS character (backspace)
.define ESC             $1B     ; VT100 escape character