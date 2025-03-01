.export putstr
.export putstrnl
.export putch
.export newline
.export puthex
.export putdec
.export getch

getch:
    jmp $FFE5
newline:
    jmp $FFE8
puthex:
    jmp $FFEB
putdec:
    jmp $FFEE
putch:
    jmp $FFF1
putstrnl:
    jmp $FFF4
putstr:
    jmp $FFF7

;    .byte $4C           ; $FFE8
;    .word newline
;    .byte $4C           ; $FFEB
;    .word puthex
;    .byte $4C           ; $FFEE
;    .word putdec
;    .byte $4C           ; $FFF1
;    .word putchar
;    .byte $4C           ; FFFF4
;    .word putstrnl
;    .byte $4C           ; $FFF7
;    .word putstr