; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.include "constants.inc"
.include "functions.inc"
.export boot
.import memtest
.import numbertest
.import sieve
.import startchess
.import monitor

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
    lda #<@str
    ldx #>@str
    jsr putstr
    jmp loop

@str:
    .asciiz "Hello World!"

loop:
    jsr getch
    cmp #0
    beq loop
    jsr putch
    jmp loop

;-------------------------------------------------------------------------------
; Initialize the system
;-------------------------------------------------------------------------------
init_system:
    jsr clear_zp
    jsr init_acia
    jsr init_screen
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
; Initialize screen
;-------------------------------------------------------------------------------
init_screen:
    lda #<@resetscroll
    ldx #>@resetscroll
    jsr putstr
    rts

@resetscroll:
    .byte ESC,"[2J",ESC,"[r",0

;-------------------------------------------------------------------------------
; Initialize I/O
;-------------------------------------------------------------------------------
init_acia:
    lda #$10		; use 8N1 with a 115200 baud
    sta ACIA_CTRL	; write to ACIA control register
    lda #%00001001  ; No parity, no echo, no interrupts.
    sta ACIA_CMD	; write to ACIA command register
    rts