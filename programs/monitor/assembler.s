.include "constants.inc"
.include "functions.inc"
.include "mnemonics.inc"

.export assemble

;-------------------------------------------------------------------------------
; ASSEMBLE routine
;-------------------------------------------------------------------------------
assemble:
@nextoptcode:
    stz BUF2                ; clear buffer
    stz BUF3
    stz BUF4
    stz CMDLENGTH

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
    ldy #0

    ; fill the command buffer
@retr:
    jsr getchar
    beq @retr
    cmp #$0D                ; check for enter
    beq @exec
    cmp #$7F                ; check for delete key
    beq @backspace
    cpy #$10                ; check if buffer is full
    beq @retr               ; do not store
    jsr chartoupper
    sta CMDBUF,y            ; store in buffer
    iny
    jsr putchar
    jmp @retr
@backspace:
    cpy #0
    beq @retr
    lda #$08
    jsr putchar
    lda #' '
    jsr putchar
    lda #$08
    jsr putchar
    dey
    jmp @retr

    ; parse the command buffer
@exec:
    jsr findmnemonic
    jsr newline
    jmp @nextoptcode
    rts

;-------------------------------------------------------------------------------
; FINDMNEMONIC routine
;
; Finds jump address to handle a particular mnemonic
;-------------------------------------------------------------------------------
findmnemonic:
    lda #<mnemonics         ; load lower byte
    sta BUF2                ; store in pointer
    lda #>mnemonics         ; load upper byte
    sta BUF3                ; store in pointer
    ldx #0                  ; mnemonic search counter
@nextmnemonic:
    ldy #0
@nextchar:
    lda CMDBUF,y
    cmp (BUF2),y
    bne @prepnext
    iny
    cpy #4
    bne @nextchar
    iny
    iny
    
    lda #' '
    jsr putchar
    lda BUF3
    jsr puthex
    lda BUF2
    jsr puthex
    lda #' '
    jsr putchar
    
    lda (BUF2),y
    jsr puthex
    iny
    lda (BUF2),y
    jsr puthex
    rts
@prepnext:
    clc
    lda BUF2
    adc #6
    sta BUF2
    lda BUF3
    adc #0
    sta BUF3
    inx
    cpx #98
    beq @error
    jmp @nextmnemonic
    rts

@error:
    lda #<@errorstr     ; load lower byte
    sta STRLB
    lda #>@errorstr     ; load upper byte
    sta STRHB
    jsr stringout
    rts
@errorstr:
    .asciiz "Unknown mnemonic, please try again."