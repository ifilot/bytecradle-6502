.include "constants.inc"

.import putstr
.import newcmdline
.import _putch

.export init_system

.segment "CODE"
.PSC02

;-------------------------------------------------------------------------------
; Initialize the system
;-------------------------------------------------------------------------------
init_system:
    jsr clear_zp
    jsr clear_mem
    jsr init_acia
    jsr init_screen
    jsr printtitle
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
    cpx #$20
    bne @next
    stz TBPL
    stz TBPR
    rts

;-------------------------------------------------------------------------------
; Clear OS RAM
;-------------------------------------------------------------------------------
clear_mem:
    ldx #$00        ; x register will be our low byte counter
    ldy #$02        ; y register will be our high byte counter
@next:
    stz $0200,x     ; store zero at address $0200 + x
    inx             ; increment x (low byte)
    bne @next       ; if x is not zero, continue (low byte rolls over)
    iny             ; increment y (high byte)
    cpy #$08        ; have we reached $08 (end of range)?
    bne @next       ; if not, continue
    rts             ; return from subroutine

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
    jsr _putch
    clc
    lda STRLB
    adc #1
    sta STRLB
    lda STRHB
    adc #0
    sta STRHB
    jmp @next
@exit:
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
    .byte "               /\___/", LF
    .byte "               \/__/", LF
    .byte "  ____  ______     __      ___", LF
    .byte " /'___\/\  ___\  /'__`\  /'___`\",LF
    .byte "/\ \__/\ \ \__/ /\ \/\ \/\_\ /\ \ ",LF
    .byte "\ \  _``\ \___``\ \ \ \ \/_/// /__", LF
    .byte " \ \ \L\ \/\ \L\ \ \ \_\ \ // /_\ \", LF
    .byte "  \ \____/\ \____/\ \____//\______/", LF
    .byte "   \/___/  \/___/  \/___/ \/_____/", LF
    .byte LF
    .byte 0				; terminating char
