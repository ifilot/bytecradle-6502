; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.include "constants.inc"
.include "functions.inc"
.export boot

;-------------------------------------------------------------------------------
; PROGRAM HEADER
;-------------------------------------------------------------------------------

.segment "CODE"

;-------------------------------------------------------------------------------
; Start sequence
;-------------------------------------------------------------------------------
boot:                              ; reset vector points here
    sei
    ldx #$FF
    txs
    jsr init_system
    jmp main

;-------------------------------------------------------------------------------
; Main routine
;-------------------------------------------------------------------------------
main:
    ldx #0
@next:
    lda @str,x
    jsr putch
    inx
    cpx #3
    bne @next
@loop:
    jsr getch
    cmp #0
    beq @loop
    jsr putch
    jmp @loop

@str:
    .byte '@', ':', ' '

;-------------------------------------------------------------------------------
; Initialize the system
;-------------------------------------------------------------------------------
init_system:
    jsr clear_zp
    jsr init_acia
    cli                 ; enable interrupts
    rts

;-------------------------------------------------------------------------------
; Clear the lower part of the zero page which is used by the BIOS
;-------------------------------------------------------------------------------
clear_zp:
    ldx #0
@next:
    stz $00,x
    inx
    bne @next
    rts

;-------------------------------------------------------------------------------
; Initialize I/O
;-------------------------------------------------------------------------------
init_acia:
    lda #$10		; use 8N1 with a 115200 baud
    sta ACIA_CTRL	; write to ACIA control register
    lda #%00001001  ; No parity, no echo, no interrupts.
    sta ACIA_CMD	; write to ACIA command register
    rts