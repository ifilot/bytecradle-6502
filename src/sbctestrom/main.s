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
.import sdtest

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
    jsr printheader
    jmp loop

;-------------------------------------------------------------------------------
; Menu
;-------------------------------------------------------------------------------
loop:
    jsr getch
    cmp #0
    beq loop
    cmp #'1'
    beq @runtestpattern
    cmp #'2'
    beq @runnumbers
    cmp #'3'
    beq @runmemtest
    cmp #'4'
    beq @runsieve
    cmp #'5'
    beq @runchess
    cmp #'6'
    beq @runmonitor
    cmp #'7'
    beq @runsdtest
    jmp loop
@runtestpattern:
    jsr testpattern
    jmp main
@runnumbers:
    jsr numbertest
    jmp main
@runmemtest:
    jsr memtest
    jmp main
@runsieve:
    jsr sieve
    jmp main
@runchess:
    jsr startchess
    jmp main
@runmonitor:
    jsr monitor
    jmp main
@runsdtest:
    jsr sdtest
    jmp main

;-------------------------------------------------------------------------------
; Print a header
;-------------------------------------------------------------------------------
printheader:
    ldy #0
@next_line:
    phy
    lda @lines_lsb,y        ; load LSB of address
    sta BUF2                ; store in buffer
    lda @lines_msb,y        ; load MSB of address
    sta BUF2+1              ; store in buffer
    ora BUF2                ; or with BUF2
    beq @done               ; check if equal to zero, if so, done

    lda BUF2
    ldx BUF2+1
    jsr putstr

    lda #LF
    jsr putch
    lda #CR
    jsr putch
    ply
    iny
    jmp @next_line
@done:
    ply                     ; clean stack
    rts

; pointer table (low/high interleaved)
@lines_lsb:
    .byte <@str2, <@str1, <@str2
    .byte <@strram, <@strrom, <@strio, <@stracia, <@str2
    .byte <@str3, <@str4, <@str5
    .byte <@str6, <@str7, <@str8, <@str9, <@str10, <@str2, 0
@lines_msb:
    .byte >@str2, >@str1, >@str2
    .byte >@strram, >@strrom, >@strio, >@stracia, >@str2
    .byte >@str3, >@str4, >@str5
    .byte >@str6, >@str7, >@str8, >@str9, >@str10, >@str2, 0

@str1:
    .asciiz "|      BYTECRADLE /TINY/ ROM        |"
@str2:
    .asciiz "+-----------------------------------+"
@strram:
    .asciiz "| RAM  : 0x0000 - 0xFEFF            |"
@strrom:
    .asciiz "| RAM  : 0xC000 - 0xFFFF            |"
@strio:
    .asciiz "| IO   : 0x7F00 - 0x7FFF            |"
@stracia:
    .asciiz "| ACIA : 0x7F04 - 0x7F0F            |"
@str3:
    .asciiz "| Menu options:                     |"
@str4:
    .asciiz "| (1) Show test pattern             |"
@str5:
    .asciiz "| (2) Perform number display test   |"
@str6:
    .asciiz "| (3) Memory test $0300-$7EFF       |"
@str7:
    .asciiz "| (4) Sieve of Eratosthenes         |"
@str8:
    .asciiz "| (5) Microchess                    |"
@str9:
    .asciiz "| (6) Monitor                       |"
@str10:
    .asciiz "| (7) SD-card test                  |"
@str11:
    .asciiz "-------------------------------------"

;-------------------------------------------------------------------------------
; Print a test pattern on the screen
;-------------------------------------------------------------------------------
testpattern:
    jsr newline
    ldx #$20                ; start with ASCII 32 (' ')
    ldy #0                  ; line character counter
@print_loop:
    txa                     ; copy current ASCII value to A
    jsr putch               ; print character
    iny
    cpy #16                 ; check if 16 chars have been printed
    bne @skip_linebreak
    jsr newline
    ldy #0                  ; reset line counter

@skip_linebreak:
    inx                     ; go to next character
    cpx #$7F                ; stop after ASCII 126
    bne @print_loop
    jsr newline

@done:
    jsr newline
    rts

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