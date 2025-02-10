.export init_sd
.export sdcmd00
.export sdcmd08

.include "constants.inc"
.include "functions.inc"

; define base address of SD-card interface
.define SERIAL      $7F20
.define CLKSTART    $7F21
.define DESELECT    $7F22
.define SELECT      $7F23

;-------------------------------------------------------------------------------
; INIT_SD ROUTINE
;
; Initialize the SD-card
;-------------------------------------------------------------------------------
init_sd:
    lda DESELECT
    sta DESELECT
    jsr sdpulse
    rts

;-------------------------------------------------------------------------------
; SDPULSE
;
; Send 96 pulses to the SD-card to reset it
;-------------------------------------------------------------------------------
sdpulse:
    lda #$FF
    ldx #12
@nextpulse:
    sta CLKSTART
    jsr wait
    dex
    bne @nextpulse
    rts

;-------------------------------------------------------------------------------
; SDCMD00 routine
;
; Send CMD00 command to the SD-card and retrieve the result
;-------------------------------------------------------------------------------
sdcmd00:
    lda #>@str
    ldx #<@str
    jsr putstr
    jsr open_command
    lda #<cmd00
    sta BUF2
    lda #>cmd00
    sta BUF3
    jsr send_command
    jsr receive_r1
    jsr close_command
    jsr newline
    rts
@str:
    .asciiz "Sending CMD00. Response: "

;-------------------------------------------------------------------------------
; SDCMD08 routine
;
; Send CMD08 command to the SD-card and retrieve the result
;-------------------------------------------------------------------------------
sdcmd08:
    lda #>@str
    ldx #<@str
    jsr putstr
    jsr open_command
    lda #<cmd08
    sta BUF2
    lda #>cmd08
    sta BUF3
    jsr send_command
    jsr receive_r7
    jsr close_command
    jsr newline
    rts
@str:
    .asciiz "Sending CMD08. Response: "

;-------------------------------------------------------------------------------
; SEND_COMMAND routine
;
; Helper routine that shifts out a command to the SD-card. Pointer to command
; should be loaded in BUF2:BUF3. Assumes that command is always 5 bytes in
; length. This function does not require additional wait routines when using
; a 16 MHz clock for the SD-card interface.
;-------------------------------------------------------------------------------
send_command:
    ldy #00
@next:
    lda (BUF2),y
    sta SERIAL
    sta CLKSTART
    iny
    cpy #06
    bne @next
    rts

;-------------------------------------------------------------------------------
; Command instructions
;-------------------------------------------------------------------------------
cmd00:
    .byte 00|$40,$00,$00,$00,$00,$94|$01
cmd08:
    .byte 08|$40,$00,$00,$01,$AA,$86|$01
cmd55:
    .byte 55|$40,$00,$00,$00,$00,$00|$01
cmd58:
    .byte 58|$40,$00,$00,$00,$00,$00|$01
acmd41:
    .byte 41|$40,$40,$00,$00,$00,$00|$01

;-------------------------------------------------------------------------------
; RECEIVE_R1 routine
;
; Receives a R1 type of response. Keeps on polling the SD-card until a non-$FF
; byte is received. If more than 128 attempts are required, the function errors
; by setting the carry bit high.
;-------------------------------------------------------------------------------
receive_r1:
    jsr poll_card
    bcs @exit           ; if carry set, then fail
    jsr puthex          ; if not, print the result
@exit:
    rts

;-------------------------------------------------------------------------------
; RECEIVE_R7 routine
;
; Receives a R7 type of response. Keeps on polling the SD-card until a non-$FF
; byte is received. If more than 128 attempts are required, the function errors
; by setting the carry bit high.
;-------------------------------------------------------------------------------
receive_r7:
    jsr poll_card
    bcs @exit
    jsr puthex
    ldx #4              ; retrieve four more bytes
@next:
    lda #$FF            ; load in ones in shift register
    sta SERIAL          ; latch onto shift register
    sta CLKSTART        ; start transfer
    jsr wait            ; small delay before reading out result
    lda SERIAL          ; read result
    jsr puthex          ; print result
    dex                 ; decrement x
    bne @next           ; complete? if not, grab next byte
@exit:
    rts

;-------------------------------------------------------------------------------
; POLL_CARD routine
;
; Keep on polling SD-card until a non-$FF is received. Keep track on the number
; of attempts. If this exceeds 128, throw an error by setting the carry bit
; high.
;-------------------------------------------------------------------------------
poll_card:
    ldx #00             ; attempt counter
@tryagain:
    lda #$FF            ; load all ones
    sta SERIAL          ; put in shift register
    sta CLKSTART        ; send to SD-card
    jsr wait            ; wait is strictly necessary for 16 MHz clock
    lda SERIAL          ; read result
    cmp #$FF            ; equal to $FF?
    bne @done           ; not equal to $FF, then done
    inx                 ; else, increment counter
    cpx #128            ; threshodl reached?
    beq @fail           ; upon 128 attempts, fail
    jmp @tryagain
@done:
    clc                 ; cleared carry on succes
    rts
@fail:
    sec                 ; set carry on fail
    rts

open_command:
    lda #$FF
    sta SERIAL
    sta CLKSTART
    jsr wait
    sta SELECT
    sta CLKSTART
    jsr wait
    rts

close_command:
    ldx #$FF
    stx SERIAL
    stx CLKSTART
    jsr wait
    stx DESELECT
    stx CLKSTART
    jsr wait
    rts

;-------------------------------------------------------------------------------
; WAIT routine
;
; Used to add a small delay for shifting out bits when interfacing with the
; SD-card. Basically calling this routine and returning from it already provides
; a sufficient amount of delay that the shift register is emptied.
;-------------------------------------------------------------------------------
wait:
    rts
