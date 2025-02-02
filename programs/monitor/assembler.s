.include "constants.inc"
.include "functions.inc"

.export assemble

assemble:
@nextoptcode:
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

    rts