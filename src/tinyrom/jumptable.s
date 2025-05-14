.include "functions.inc"

.segment "JUMPTABLE"

jumptable:
    jmp delayms10   ; $FFE2
    jmp putstr      ; $FFE5
    jmp putstrnl    ; $FFE8
    jmp putch       ; $FFEB
    jmp newline     ; $FFEE
    jmp puthex      ; $FFF1
    jmp putdec      ; $FFF4
    jmp getch       ; $FFF7