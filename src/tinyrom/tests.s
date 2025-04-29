.PSC02

.include "constants.inc"
.include "functions.inc"

.export testpattern

;-------------------------------------------------------------------------------
; Print a test pattern on the screen
;-------------------------------------------------------------------------------
testpattern:
    jsr newline
    ldx #$20                ; start with ASCII 32 (' ')
    ldy #0                  ; line character counter
@print_loop:
    txa                     ; copy current ASCII value to A
    jsr putch               ; print character
    iny
    cpy #16                 ; check if 16 chars have been printed
    bne @skip_linebreak
    jsr newline
    ldy #0                  ; reset line counter

@skip_linebreak:
    inx                     ; go to next character
    cpx #$7F                ; stop after ASCII 126
    bne @print_loop
    jsr newline

@done:
    jsr newline
    rts