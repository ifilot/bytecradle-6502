.segment "CODE"

.include "functions.inc"

.export numbertest

numbertest:
    ldy #0
@next:
    tya
    jsr puthex
    jsr putspace
    tya
    iny
    cpy #$10
    bne @next

    jsr newline
numbertestdec:
    lda #10
    jsr putdec
    jsr putspace
    lda #11
    jsr putdec
    jsr putspace
    lda #12
    jsr putdec
    jsr putspace
    lda #101
    jsr putdec
    jsr putspace
    lda #111
    jsr putdec
    jsr putspace
    lda #131
    jsr putdec
    jsr putspace
    lda #201
    jsr putdec
    jsr putspace
    lda #211
    jsr putdec
    jsr putspace
    lda #255
    jsr putdec
    jsr putspace

    jsr newline
numbertestdecword:
    lda #<12345
    ldx #>12345
    jsr putdecword
    jsr putspace
    lda #<42
    ldx #>42
    jsr putdecword
    jsr putspace
    lda #<$FFFF
    ldx #>$FFFF
    jsr putdecword
    jsr putspace
    lda #0
    ldx #0
    jsr putdecword
    jsr putspace
    jsr newline
    rts