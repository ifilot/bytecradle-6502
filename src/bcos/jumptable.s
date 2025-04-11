.import getch
.import newline
.import puthex
.import putdec
.import putch
.import putstrnl
.import putstr

;-------------------------------------------------------------------------------
; JUMP TABLE
;-------------------------------------------------------------------------------
.segment "JUMPTABLE"
    .byte $4C           ; $FFE5
    .word getch
    .byte $4C           ; $FFE8
    .word newline
    .byte $4C           ; $FFEB
    .word puthex
    .byte $4C           ; $FFEE
    .word putdec
    .byte $4C           ; $FFF1
    .word putch
    .byte $4C           ; FFFF4
    .word putstrnl
    .byte $4C           ; $FFF7
    .word putstr 