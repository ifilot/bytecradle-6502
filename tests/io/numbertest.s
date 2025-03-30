.segment "CODE"

.include "functions.inc"

.export numbertest

numbertest:
    ldy #0
@next:
    tya
    jsr puthex
    jsr printspace
    tya
    iny
    cpy #$10
    bne @next

    jsr newline
numbertestdec:
    lda #10
    jsr putdec
    jsr printspace
    lda #11
    jsr putdec
    jsr printspace
    lda #12
    jsr putdec
    jsr printspace
    lda #101
    jsr putdec
    jsr printspace
    lda #111
    jsr putdec
    jsr printspace
    lda #131
    jsr putdec
    jsr printspace
    lda #201
    jsr putdec
    jsr printspace
    lda #211
    jsr putdec
    jsr printspace
    lda #255
    jsr putdec
    jsr printspace

    jsr newline
numbertestdecword:
    lda #<12345
    ldx #>12345
    jsr putdecword
    jsr printspace
    lda #<42
    ldx #>42
    jsr putdecword
    jsr printspace
    lda #<$FFFF
    ldx #>$FFFF
    jsr putdecword
    jsr printspace
    lda #0
    ldx #0
    jsr putdecword
    jsr printspace
    jsr newline
    rts

printspace:
    lda #' '
    jsr putch
    rts