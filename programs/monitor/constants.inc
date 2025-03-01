.PSC02

; textbuffer variables
.define CMDBUF          $80     ; position of command buffer
.define CMDLENGTH       $90     ; number of bytes in buffer, max 16

.define LF              $0A     ; LF character (line feed)
.define ESC             $1B     ; VT100 escape character

; general buffer addresses (ZP), these can be used by a number of programs
; in the monitor
.define TBPL            $60
.define TBPR            $61
.define BUF1            $62
.define BUF2            $63
.define BUF3            $64
.define BUF4            $65
.define BUF5            $66
.define BUF6            $67
.define BUF7            $68
.define BUF8            $69
.define BUF9            $6A
.define BUF10           $6B

; specific ZP addresses for the hexdump routine of the monitor
.define STARTADDR       $6C
.define ENDADDR         $6E
.define MALB            $70     ; monitor address low byte
.define MAHB            $71     ; monitor address high byte
.define NRLINES         $72     ; number of lines to print by hexdump routine

; additional ZP addresses for assembler
.define CHAR1           $73
.define CHAR2           $74
.define CHAR3           $75
.define CHAR4           $76
.define NRCHARS         $77
