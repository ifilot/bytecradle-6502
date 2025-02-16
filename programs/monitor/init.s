.include "constants.inc"

.import putstr
.import newcmdline
.import putchar

.export init

;-------------------------------------------------------------------------------
; Initialize the system
;-------------------------------------------------------------------------------
init:
    jsr init_zp_tb
    jsr init_romstart
    jsr init_acia
    jsr init_screen
    jsr printtitle
    rts

;-------------------------------------------------------------------------------
; Clear the zero page, text and command buffer
;-------------------------------------------------------------------------------
init_zp_tb:
    ldx #$00            ; prepare to clear the zero page
@nextbyte:
    stz $00,x           ; clear zero page by storing 0
    stz TB,x            ; clear textbuffer by storing 0
    inx                 ; increment x
    bne @nextbyte       ; loop until x overflows back to 0
    stz TBPL            ; reset textbuffer left pointer
    stz TBPR		    ; reset textbuffer right pointer
    stz CMDLENGTH       ; clear command length size
    rts
    
;-------------------------------------------------------------------------------
; Initialize screen
;-------------------------------------------------------------------------------
init_screen:
    lda #>@resetscroll
    ldx #<@resetscroll
    jsr putstr
    rts

@resetscroll:
    .byte ESC,"[r",0

;-------------------------------------------------------------------------------
; Initialize I/O
;-------------------------------------------------------------------------------
init_acia:
    lda #$10		; use 8N1 with a 115200 baud
    sta ACIA_CTRL	; write to ACIA control register
    lda #%00001001  ; No parity, no echo, no interrupts.
    sta ACIA_CMD	; write to ACIA command register
    rts

;-------------------------------------------------------------------------------
; Copy romstart routine from ROM to RAM
;-------------------------------------------------------------------------------
init_romstart:
    ldx #0
@next:
    lda romstart,x
    sta ROMSTART,x
    inx
    cpx #$20
    bne @next

    lda #$FE
    sta JUMPSTART
    lda #$FF
    sta JUMPSTART+1
    lda #$6C		; optcode for indirect jump
    sta JUMPSTART-1
    rts

romstart:
    lda #2
    sta BREG
    jsr JUMPSTART-1
    lda #0
    sta BREG
    rts

;-------------------------------------------------------------------------------
; Print start-up title to screen
;-------------------------------------------------------------------------------
printtitle:
    lda #<termbootstr   ; load lower byte
    sta STRLB
    lda #>termbootstr   ; load upper byte
    sta STRHB
@next:
    ldy #0
    lda (STRLB),y
    cmp #0
    beq @exit
    jsr putchar
    clc
    lda STRLB
    adc #1
    sta STRLB
    lda STRHB
    adc #0
    sta STRHB
    jmp @next
@exit:
    jsr newcmdline
    rts

termbootstr:
    .byte ESC,"[2J",ESC,"[H"		; reset terminal
    .byte " ____             __           ____                      __   ___             ", LF
    .byte "/\  _`\          /\ \__       /\  _`\                   /\ \ /\_ \            ", LF
    .byte "\ \ \L\ \  __  __\ \ ,_\    __\ \ \/\_\  _ __    __     \_\ \\//\ \      __   ", LF
    .byte " \ \  _ <'/\ \/\ \\ \ \/  /'__`\ \ \/_/_/\`'__\/'__`\   /'_` \ \ \ \   /'__`\ ", LF
    .byte "  \ \ \L\ \ \ \_\ \\ \ \_/\  __/\ \ \L\ \ \ \//\ \L\.\_/\ \L\ \ \_\ \_/\  __/ ", LF
    .byte "   \ \____/\/`____ \\ \__\ \____\\ \____/\ \_\\ \__/.\_\ \___,_\/\____\ \____\", LF
    .byte "    \/___/  `/___/> \\/__/\/____/ \/___/  \/_/ \/__/\/_/\/__,_ /\/____/\/____/", LF
    .byte "               /\___/                                                          ", LF
    .byte "               \/__/                                                           ", LF
    .byte "  ____  ______     __      ___                                                 ", LF
    .byte " /'___\/\  ___\  /'__`\  /'___`\      BYTECRADLE 6502                          ", LF
    .byte "/\ \__/\ \ \__/ /\ \/\ \/\_\ /\ \     ---------------                          ", LF
    .byte "\ \  _``\ \___``\ \ \ \ \/_/// /__    MONITOR PROGRAM                          ", LF
    .byte " \ \ \L\ \/\ \L\ \ \ \_\ \ // /_\ \   VERSION 0.1.0                            ", LF
    .byte "  \ \____/\ \____/\ \____//\______/                                            ", LF
    .byte "   \/___/  \/___/  \/___/ \/_____/    https://github.com/ifilot/bytecradle-6502", LF
    .byte LF
    .byte "Press -M- to see a menu",LF
    .byte 0				; terminating char