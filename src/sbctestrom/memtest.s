.include "constants.inc"
.include "functions.inc"
.export memtest

memtest:
        lda #<$0300
        sta BUF2
        lda #>$0300
        sta BUF3
        stz BUF4

test_loop:
        lda BUF2
        and #$3F
        bne skipaddr

        lda BUF3
        jsr puthex
        lda BUF2
        jsr puthex
        lda #':'
        jsr putch
        lda #' '
        jsr putch

skipaddr:
        ; Write pattern 1 ($AA)
        lda #$AA
        ldy #0
        sta (BUF2),y

        ; Verify pattern 1
        cmp (BUF2),y
        bne report_error

        ; Write pattern 2 ($55)
        lda #$55
        sta (BUF2),y

        ; Verify pattern 2
        cmp (BUF2),y
        bne report_error

        ; Passed this byte
        lda #'.'
        jsr putch

        ; Every 64 bytes, print newline
        inc BUF4
        lda BUF4
        and #$3F                ; 64-byte wrap
        bne skip_newline
        lda #CR
        jsr putch
        lda #LF
        jsr putch
skip_newline:

        ; Increment pointer
        inc BUF2
        bne no_carry
        inc BUF3
no_carry:
        lda BUF2
        cmp #<$7F00
        bne test_loop
        lda BUF3
        cmp #>$7F00
        bne test_loop

        jsr newline
        lda #<@str
        ldx #>@str
        jsr putstr
        jsr newline
        jsr newline
        jmp done

@str:
    .asciiz "Memory test $0300-$7EFF completed"

report_error:
        lda #'E'
        jsr putch
        jmp skip_newline        ; continue testing

done:
        rts