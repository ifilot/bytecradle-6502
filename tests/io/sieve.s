
.segment "CODE"

.define SIEVESTART $1000        ; has to be start of a page
.define SIEVESTOP  $5000        ; end of sieve memory
.define ZPBUFFER     $80        ; define start of zero-page buffer
.define ZPBUF1       $80
.define ZPBUF2       $81
.define ZPBUF3       $82
.define ZPBUF4       $83
.define ZPBUF5       $84
.define ZPBUF6       $85
.define CPRLB        $86
.define CPRHB        $87
.define PCTRLB       $88
.define PCTRHB       $89
.define ADDRLB       $8A
.define ADDRHB       $8B
.define LINECTRLB    $8C
.define LINECTRHB    $8D
.define PREVADDRLB   $8E
.define PREVADDRHB   $8F

.include "constants.inc"
.include "functions.inc"

.export sieve

;-------------------------------------------------------------------------------
; Sieve of Eratosthenes function
;-------------------------------------------------------------------------------
sieve:
    jsr clearmem
    ldx #0
    stz LINECTRLB
    stz LINECTRHB
    lda #<SIEVESTART
    sta PREVADDRLB
    lda #>SIEVESTART
    sta PREVADDRHB
@next:
    cpx #0
    phx
    bne @skipheader
    lda LINECTRLB
    ldx LINECTRHB
    jsr putdecword
    lda #'0'
    jsr putch
    lda #':'
    jsr putch
    lda #' '
    jsr putch
@skipheader:
    jsr findnextprime       ; grab next prime
    lda CPRLB
    ora CPRHB
    beq @stop
    jsr printcurprime
    plx
    inx
    cpx #10
    bne @skip
    jsr newline
    ldx #0
    inc LINECTRLB
    bne @skip
    inc LINECTRHB
@skip:
    jsr maskprimemultiples
    jmp @next
@stop:
    plx                     ; clean stack
    jsr newline
    rts

;-------------------------------------------------------------------------------
; Print prime number stored in CPRLB:CPRHB
;-------------------------------------------------------------------------------
printcurprime:
    lda CPRLB
    ldx CPRHB
    jsr putdecword
    lda #' '
    jsr putch
    rts

;-------------------------------------------------------------------------------
; Find next prime number in sieve
;-------------------------------------------------------------------------------
findnextprime:
    lda PREVADDRLB
    sta ZPBUF1              ; lower byte
    lda PREVADDRHB
    sta ZPBUF2              ; upper byte
@next:
    lda (ZPBUF1)            ; load from pointer
    beq @done               ; check if zero; if so, prime
    inc ZPBUF1              ; if not, increment lowbyte pointer
    bne @next               ; check if highbyte needs to increment?
    inc ZPBUF2              ; increment upper byte
    lda ZPBUF2              ; check value
    cmp #>SIEVESTOP         ; end of sieve reached?
    beq @stop               ; if so, stop and set 00
    jmp @next               ; if not, next byte
@stop:
    stz ZPBUF1              ; set result to 0
    stz ZPBUF2
    stz CPRLB
    stz CPRHB
    rts
@done:
    lda ZPBUF1
    sta PREVADDRLB
    lda ZPBUF2
    sta PREVADDRHB
    jsr addr2val
    rts

;-------------------------------------------------------------------------------
; Given a prime, mask prime multiples
;-------------------------------------------------------------------------------
maskprimemultiples:
    lda CPRLB
    sta PCTRLB
    lda CPRHB
    sta PCTRHB
    jsr val2addr
    lda #2                  ; mark as prime
    sta (ADDRLB)
@next:
    clc                     ; clear carry
    lda PCTRLB
    adc CPRLB               ; add lower byte
    sta PCTRLB
    lda PCTRHB
    adc CPRHB               ; add upper byte
    sta PCTRHB

    lda PCTRLB
    and #1                  ; check if odd
    beq @next               ; if not, ignore and immediately jump

    ;lda PCTRLB
    ;ldx PCTRHB
    ;jsr putdecword
    ;jsr newline

    jsr val2addr

    ;lda ADDRHB
    ;jsr puthex
    ;lda ADDRLB
    ;jsr puthex
    ;jsr newline

    lda ADDRHB
    cmp #>SIEVESTOP
    bcs @stop
    lda #1
    sta (ADDRLB)
    jmp @next
@stop:
    rts

;-------------------------------------------------------------------------------
; Convert address to value
;-------------------------------------------------------------------------------
addr2val:
    sec                     ; set carry for subtract
    lda ZPBUF1
    sbc #<SIEVESTART        ; subtract SIEVESTART
    sta ZPBUF1
    lda ZPBUF2
    sbc #>SIEVESTART
    sta ZPBUF2
    lda ZPBUF1
    asl a                   ; shift left (multiply by 2)
    sta ZPBUF1
    lda ZPBUF2
    rol a                   ; rotate to high byte
    sta ZPBUF2
    clc
    lda ZPBUF1
    adc #3
    sta CPRLB
    lda ZPBUF2
    adc #0
    sta CPRHB
@done:
    rts

;-------------------------------------------------------------------------------
; Convert value back to address
;-------------------------------------------------------------------------------
val2addr:
    sec
    lda PCTRLB
    sbc #3
    sta ADDRLB
    lda PCTRHB
    sbc #0
    lsr a
    sta ADDRHB
    lda ADDRLB
    ror a
    sta ADDRLB
    clc
    lda ADDRLB
    adc #<SIEVESTART
    sta ADDRLB
    lda ADDRHB
    adc #>SIEVESTART
    sta ADDRHB
    rts

;-------------------------------------------------------------------------------
; Clear memory for the sieve
;-------------------------------------------------------------------------------
clearmem:
    lda #>SIEVESTART
    sta ZPBUF2              ; store upper byte
    stz ZPBUF1              ; set upper byte to zero
@nextpage:
    ldy #0
    lda #0
@next:
    sta (ZPBUF1),y
    iny
    bne @next
    inc ZPBUF2
    lda ZPBUF2
    cmp #>SIEVESTOP
    bne @nextpage
    rts