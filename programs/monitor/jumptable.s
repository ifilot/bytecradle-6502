.include "functions.inc"

;-------------------------------------------------------------------------------
; JUMP TABLE
;-------------------------------------------------------------------------------
.segment "JUMPTABLE"
    .byte $4C           ; $FFE8
    .word newline
    .byte $4C           ; $FFEB
    .word puthex
    .byte $4C           ; $FFEE
    .word putdec
    .byte $4C           ; $FFF1
    .word putchar
    .byte $4C           ; FFFF4
    .word putstrnl
    .byte $4C           ; $FFF7
    .word putstr 