.PSC02

.define ACIA_DATA       $7F04
.define ACIA_STAT       $7F05
.define ACIA_CMD        $7F06
.define ACIA_CTRL       $7F07
.define BREG            $7F00

; textbuffer variables
.define TBPR            $00
.define TBPL            $01
.define TB              $0200   ; store textbuffer in page 2
.define CMDBUF          $0300   ; position of command buffer
.define CMDLENGTH       $0310   ; number of bytes in buffer, max 16
.define JUMPSTART       $0312
.define ROMSTART        $0400   ; custom code to start a program on a different rom

.define LF              $0A     ; LF character (line feed)
.define ESC             $1B     ; VT100 escape character

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
.define BUF10           $0B

; specific ZP addresses for the hexdump routine of the monitor
.define STARTADDR       $0C
.define ENDADDR         $0E
.define STRLB           $10     ; string low byte
.define STRHB           $11     ; string high byte
.define MALB            $14     ; monitor address low byte
.define MAHB            $15     ; monitor address high byte
.define NRLINES         $16     ; number of lines to print by hexdump routine

; additional ZP addresses for assembler
.define CHAR1           $17
.define CHAR2           $18
.define CHAR3           $19
.define CHAR4           $1A
.define NRCHARS         $1B
