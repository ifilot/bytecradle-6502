.segment "CODE"

.include "functions.inc"

.export numbertest

numbertest:
    ldy #0
@next:
    tya
    jsr puthex
    lda #' '
    jsr putch
    tya
    iny
    cpy #$10
    bne @next

    jsr newline
numbertestdec:
    lda #10
    jsr putdec
    lda #' '
    jsr putch
    lda #11
    jsr putdec
    lda #' '
    jsr putch
    lda #12
    jsr putdec
    lda #' '
    jsr putch
    lda #101
    jsr putdec
    lda #' '
    jsr putch
    lda #111
    jsr putdec
    lda #' '
    jsr putch
    lda #131
    jsr putdec
    lda #' '
    jsr putch
    lda #201
    jsr putdec
    lda #' '
    jsr putch
    lda #211
    jsr putdec
    lda #' '
    jsr putch
    lda #255
    jsr putdec
    lda #' '
    jsr putch

    jsr newline
numbertestdecword:
    rts