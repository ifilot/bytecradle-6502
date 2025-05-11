;
; ByteCradle OS Jump Table
;
; This jump table exposes a set of core subroutines that user programs can call
; at fixed addresses in ROM. Each entry is a `jmp` to the corresponding routine.
; By calling these jump points instead of the functions directly, compatibility
; can be preserved even if internal function addresses change.
;
; These entry points are located at the top of the address space (starting at $FFE5),
; similar to traditional system ROMs.
;

.include "functions.inc"

.segment "JUMPTABLE"

jumptable:
    jmp putstr      ; $FFE5 - Print null-terminated string (X:A = addr)
    jmp putstrnl    ; $FFE8 - Print string with newline (X:A = addr)
    jmp putch       ; $FFEB - Print a single character in A
    jmp newline     ; $FFEE - Print carriage return + line feed
    jmp puthex      ; $FFF1 - Print byte in A as two-digit hexadecimal
    jmp putdec      ; $FFF4 - Print byte in A as decimal
    jmp getch       ; $FFF7 - Get character from key buffer (A)
