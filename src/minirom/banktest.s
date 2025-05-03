.segment "CODE"

.include "constants.inc"
.include "functions.inc"

.export banktest

banktest:
    jsr rombankswap
    jsr rambankswap
    jsr romcheck
    rts

rombankswap:
    ldx #0
@next:
    stx ROMBANKREGISTER
    lda ROMBANKREGISTER
    jsr puthex
    jsr putspace
    inx
    cpx #5
    bne @next
    jsr newline
    stz ROMBANKREGISTER
    rts

rambankswap:
    ldx #0
@next:
    stx RAMBANKREGISTER
    lda RAMBANKREGISTER
    jsr puthex
    jsr putspace
    inx
    cpx #5
    bne @next
    jsr newline
    stz RAMBANKREGISTER
    rts

romcheck:
    ldx #0
@next1:
    lda $C000,X
    jsr puthex
    jsr putspace
    inx
    cpx #5
    bne @next1
    
    jsr newline
    ldx #0
@next2:
    lda $A000,X
    jsr puthex
    jsr putspace
    inx
    cpx #5
    bne @next2
    jsr newline

    ldx #0
@next3:
    lda $E000,X
    jsr puthex
    jsr putspace
    inx
    cpx #5
    bne @next3
    
    lda #1
    sta ROMBANKREGISTER
    jsr newline
    ldx #0
@next4:
    lda $A000,X
    jsr puthex
    jsr putspace
    inx
    cpx #5
    bne @next4
    jsr newline
    rts