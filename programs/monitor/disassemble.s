.include "constants.inc"
.include "functions.inc"

.export disassemble

.import optcodes

.segment "CODE"

;-------------------------------------------------------------------------------
; DISASSEMBLE routine
;
; Uses BUF2:4 to hold data
;-------------------------------------------------------------------------------
disassemble:
    ldx #0
@nextoptcode:
    ldy #0
    stz BUF2                ; clear buffer
    stz BUF3
    stz BUF4

    ; print address
    jsr puttab
    lda STARTADDR+1
    jsr puthex
    lda STARTADDR
    jsr puthex
    lda #':'
    jsr putchar
    lda #' '
    jsr putchar

    ; calculate offset
    lda (STARTADDR),y       ; grab opt code; this also acts as index
    asl                     ; multiply by 2
    rol BUF3
    asl                     ; multiply by 4
    rol BUF3
    asl                     ; multiply by 8
    rol BUF3
    sta BUF2                ; store low byte (high byte in BUF3)

    lda #<optcodes          ; load low byte of table address
    clc
    adc BUF2                ; add offset low byte
    sta BUF2                ; store
    lda #>optcodes          ; load high byte of table address
    adc BUF3                ; add offset high byte
    sta BUF3                ; store

    ; print opt code
    ldy #0
@next:
    lda (BUF2),y
    jsr putchar
    iny
    cpy #4
    bne @next
    jsr putds

    ; check if more needs to be printed
    ldy #4
    lda (BUF2),y
    sta BUF4
    cmp #1                  ; only one byte?
    beq @nothing

    ; store address mode
    ldy #5
    lda (BUF2),y
    sta BUF5
    cmp #1                  ; absolute address mode?
    beq @op4
    cmp #2                  ; absolute, x?
    beq @absx
    cmp #3                  ; absolute, y?
    beq @absy
    cmp #5                  ; immediate?
    beq @im
    cmp #9                  ; relative?
    beq @op2
    cmp #$A                 ; zero page?
    beq @op2
    cmp #$B                 ; zero page,x
    beq @op2x
    cmp #$C                 ; zero page,y
    beq @op2y
    cmp #$D                 ; zero page indirect
    beq @op2in
    jmp @nothing

@nothing:                   ; print nothing
    jsr puttab
    jmp @printcodetab
@ind:                       ; print indirect
    jsr @putinaddr
    jsr putds
    jmp @printcode
@indx:                      ; print indirect,x
    jsr @putinaddr
    jsr @putcommax
    jmp @printcode
@indy:                      ; print indirect,y
    jsr @putinaddr
    jsr @putcommay
    jmp @printcode
@absx:                      ; print absolute,x
    jsr @putaddr
    jsr @putcommax
    jsr putds
    jmp @printcode
@absy:                      ; print absolute,y
    jsr @putaddr
    jsr @putcommay
    jsr putds
    jmp @printcode
@op4:                       ; print HEX4
    jsr @putaddr
    jmp @printcodetab
@im:
    lda #'#'
    jsr putchar
    jsr @putaddrl
    lda #' '
    jsr putchar
    jmp @printcodetab
@op2:                       ; print HEX2
    jsr @putaddrl
    jsr putds
    jmp @printcodetab
@op2in:                     ; indirect zero page
    lda #'('
    jsr putchar
    jsr @putaddrl
    lda #')'
    jsr putchar
    jmp @printcodetab
@op2x:
    jsr @putaddrl
    jsr @putcommax
    jmp @printcodetab
@op2y:
    jsr @op2
    jsr @putcommay
    jmp @printcodetab

; print opt code bytes
@printcodetab:
    jsr puttab
@printcode:
    jsr puttab
    ldy #0
@nextbyte:
    lda (STARTADDR),y
    jsr puthex
    jsr putspace
    iny
    cpy BUF4
    bne @nextbyte

    ; prepare for next optcode
    lda STARTADDR           ; load low byte
    clc
    adc BUF4
    sta STARTADDR
    lda STARTADDR+1
    adc #0
    sta STARTADDR+1
    jsr newline

    inx
    cpx #16
    bne @nextinstruction
    rts
@nextinstruction:
    jmp @nextoptcode

; print address low byte
@putaddrl:
    ldy #1
    lda (STARTADDR),y
    jsr puthex
    rts

; print address
@putaddr:
    ldy #2
    lda (STARTADDR),y
    jsr puthex
    dey
    lda (STARTADDR),y
    jsr puthex
    rts

; print address between round parentheses
@putinaddr:
    lda #'('
    jsr putchar
    jsr @putaddr
    lda #')'
    jsr putchar
    rts

; print ",X"
@putcommax:
    lda #','
    jsr putchar
    lda #'X'
    jsr putchar
    rts

; print ",Y"
@putcommay:
    lda #','
    jsr putchar
    lda #'Y'
    jsr putchar
    rts