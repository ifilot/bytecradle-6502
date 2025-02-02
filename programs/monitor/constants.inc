.PSC02

.define ACIA_DATA       $9F04
.define ACIA_STAT       $9F05
.define ACIA_CMD        $9F06
.define ACIA_CTRL       $9F07
.define BREG		    $9F00

; textbuffer variables
.define TBPR		    $02
.define TBPL		    $03
.define TB              $0200	; store textbuffer in page 2
.define CMDBUF          $0300   ; position of command buffer
.define CMDLENGTH       $0310   ; number of bytes in buffer, max 16
.define JUMPSTART       $0312
.define ROMSTART        $0400	; custom code to start a program on a different rom

.define LF		        $0A		; LF character (line feed)
.define ESC		        $1B		; VT100 escape character

; buffer addresses (ZP)
.define BUF1		    $04
.define BUF2		    $05
.define BUF3		    $06
.define BUF4		    $07
.define	BUF5		    $08
.define BUF6		    $09
.define BUF7		    $0A
.define BUF8		    $0B

; specific ZP addresses for the hexdump routine of the monitor
.define STARTADDR	    $0C
.define ENDADDR		    $0E
.define STRLB		    $10		; string low byte
.define STRHB		    $11		; string high byte
.define MALB		    $14		; monitor address low byte
.define MAHB		    $15		; monitor address high byte
.define NRLINES		    $16		; number of lines to print by hexdump routine