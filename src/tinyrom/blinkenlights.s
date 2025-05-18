.PSC02

.include "constants.inc"
.include "functions.inc"

.segment "CODE"

.export blinkenlights
.export strobe

blinkenlights:
    lda #<@str
    ldx #>@str
    jsr putstrnl
@repeat:
    lda #<@l1
    ldx #>@l1
    jsr putstr
    lda #$55
    sta CTRLB1
    lda #50
    jsr delayms10

    jsr getch
    cmp #0
    bne @done

    lda #<@l2
    ldx #>@l2
    jsr putstr
    lda #$AA
    sta CTRLB1
    lda #50
    jsr delayms10
    
    jsr getch
    cmp #0
    bne @done
    jmp @repeat

@done:
    lda #CR
    jsr putch
    lda #<@strdone
    ldx #>@strdone
    jsr putstrnl
    lda #0
    sta CTRLB1
    rts

@str:
    .asciiz "Blinkenlights running: press any key to stop..."

@strdone:
    .asciiz "Keypress detected, stopping."

@l1:
    .byte CR, '#', ' ', 0
@l2:
    .byte CR, ' ', '#', 0

strobe:
    lda #<@str
    ldx #>@str
    jsr putstrnl
@start:
    lda #1
    ldx #7
@left:
    sta CTRLB1
    jsr @checkloop
    bcs @done

    asl                     ; shift left
    dex
    bne @left

    ldx #7
    lda #$80
@right:
    sta CTRLB1
    jsr @checkloop
    bcs @done

    lsr                     ; shift right
    dex
    bne @right
    jmp @start
@done:
    lda #CR
    jsr putch
    lda #<@strdone
    ldx #>@strdone
    jsr putstrnl
    lda #0
    sta CTRLB1
    rts
@checkloop:
    pha
    lda #10
    phx
    jsr delayms10
    plx
    jsr getch
    cmp #0
    bne @break
    lda #CR
    jsr putch
    pla
    jsr puthex
    clc
    rts
@break:
    pla
    sec
    rts

@str:
    .asciiz "Strobe running: press any key to stop..."

@strdone:
    .asciiz "Keypress detected, stopping."