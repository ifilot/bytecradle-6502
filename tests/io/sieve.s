
.segment "CODE"

.define SIEVESTART $1000        ; has to be start of a page
.define SIEVESTOP  $7F00        ; end of sieve memory

.include "constants.inc"
.include "functions.inc"

.export sieve

;-------------------------------------------------------------------------------
; Sieve of Eratosthenes function
;-------------------------------------------------------------------------------
sieve:
    jsr clearmem
    lda #1
    sta $1000
    jsr findnextprime
    rts

findnextprime:
    lda #<SIEVESTART
    sta BUF2
    lda #>SIEVESTART
    sta BUF3
@next:
    lda (BUF2)
    beq @done
    inc BUF2
    bne @next
    inc BUF3
    lda BUF3
    cmp #>SIEVESTOP
    beq @done
    jmp @next
@done:
    rts

;-------------------------------------------------------------------------------
; Clear memory for the sieve
;-------------------------------------------------------------------------------
clearmem:
    lda #>$1000
    sta BUF2
    stz BUF3    
@nextpage:
    ldy #0
    lda #0
@next:
    sta (BUF2),y
    iny
    bne @next
    inc BUF2
    lda BUF2
    cmp #>SIEVESTOP
    bne @nextpage
    rts