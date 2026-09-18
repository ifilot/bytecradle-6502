.include "functions.inc"
.include "constants.inc"

.export testvia

;-------------------------------------------------------------------------------
; Test VIA functionality
;-------------------------------------------------------------------------------
testvia:
    sei                 ; disable interrupts

    ; set pb0–pb3 as outputs (lower nibble)
    lda #%00001111
    sta VIA_DDRB

loop:
    lda #%00001010      ; turn on pb1 and pb3
    sta VIA_PORTB
    jsr delay
    lda #%00000101      ; turn on pb0 and pb2
    sta VIA_PORTB
    jsr delay
    jmp loop

; simple delay routine
delay:
    ldy #$ff
delay_y:
    ldx #$ff
delay_x:
    dex
    bne delay_x
    dey
    bne delay_y
    rts