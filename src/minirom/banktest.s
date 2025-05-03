.segment "CODE"

.include "constants.inc"
.include "functions.inc"

.export banktest

banktest:
    lda #<strrombank
    ldx #>strrombank
    jsr putstrnl
    jsr rombankswap
    jsr newline

    lda #<strrambank
    ldx #>strrambank
    jsr putstrnl
    jsr rambankswap
    jsr newline

    lda #<strrombankread
    ldx #>strrombankread
    jsr putstrnl
    jsr romcheck
    jsr newline

    lda #<strrambankrw
    ldx #>strrambankrw
    jsr putstrnl
    jsr rambankwrite
    jsr rambankread
    jsr newline

    rts

strrombank:
    .asciiz "Testing reading/writing ROM bank register."
strrambank:
    .asciiz "Testing reading/writing RAM bank register."
strrombankread:
    .asciiz "Testing ROM bank swapping and reading."
strrambankrw:
    .asciiz "Testing RAM bank swapping and reading/writing."

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

rambankwrite:
    ldx #2
@next:
    stx RAMBANKREGISTER
    stx $8000
    inx
    cpx #64
    bne @next
    rts

rambankread:
    ldx #2
@next:
    stx RAMBANKREGISTER
    lda $8000
    jsr puthex
    jsr putspace
    inx
    cpx #32
    beq @newline
    cpx #64
    bne @next
    jsr newline
    jmp @done
@newline:
    jsr newline
    jmp @next
@done:
    rts