.PSC02

.define ROMBANK         $7000
.define RAMBANK         $7001

.define ACIA_DATA       $7F04
.define ACIA_STAT       $7F05
.define ACIA_CMD        $7F06
.define ACIA_CTRL       $7F07
.define BREG            $7F00

; textbuffer variables
.define TBPR            $00
.define TBPL            $01
.define TB              $0200   ; store textbuffer in page 2

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

; specific ZP addresses for the hexdump routine of the monitor
.define STRLB           $08     ; string low byte
.define STRHB           $09     ; string high byte
