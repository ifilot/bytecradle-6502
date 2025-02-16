.include "constants.inc"
.include "functions.inc"

.export _init_sd
.export _close_sd
.export _sdcmd00
.export _sdcmd08
.export _sdacmd41
.export _sdcmd58
.export _sdcmd17

.import incsp4, pushax

.segment "CODE"
.PSC02

; define base address of SD-card interface
.define SERIAL      $7F20
.define CLKSTART    $7F21
.define DESELECT    $7F22
.define SELECT      $7F23

.include "zeropage.inc" ; required for sp

;-------------------------------------------------------------------------------
; INIT_SD ROUTINE
;
; Initialize the SD-card
;-------------------------------------------------------------------------------
_init_sd:
    lda DESELECT
    sta DESELECT
    jsr sdpulse
    rts

;-------------------------------------------------------------------------------
; CLOSE_SD ROUTINE
;
; Close the connectionn to the SD-card
;-------------------------------------------------------------------------------
_close_sd:
    lda SELECT
    sta SELECT
    jsr sdpulse
    rts

;-------------------------------------------------------------------------------
; SDPULSE
;
; Send 24x8 pulses to the SD-card to reset it
;-------------------------------------------------------------------------------
sdpulse:
    lda #$FF
    ldx #24
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
_sdcmd00:
    jsr open_command
    lda #<cmd00
    sta BUF2
    lda #>cmd00
    sta BUF3
    jsr send_command
    jsr receive_r1          ; receive response
    jsr close_command       ; conserves A
    jsr newline             ; conserves A
    rts

;-------------------------------------------------------------------------------
; SDCMD08 routine
;
; Send CMD08 command to the SD-card and retrieve the result. The place to store
; the R7 response is provided via a pointer stored in AX upon function entry.
; This pointer is stored in BUF4:5.
;-------------------------------------------------------------------------------
_sdcmd08:
    sta BUF4
    stx BUF5
    jsr open_command
    lda #<cmd08
    sta BUF2
    lda #>cmd08
    sta BUF3
    jsr send_command
    jsr receive_r7
    jsr close_command
    lda (BUF4)			; ensure return byte is present in A
    rts

;-------------------------------------------------------------------------------
; SDACMD41 routine
;
; Send CMD55 command followed by ACMD41 to the SD-card and retrieve the result
;-------------------------------------------------------------------------------
_sdacmd41:
    ldx #0              ; set attempt counter
@loop:
    phx
    jsr open_command
    lda #<cmd55         ; load CMD55
    sta BUF2
    lda #>cmd55
    sta BUF3
    jsr send_command    ; send command
    jsr receive_r1      ; receive response, prints response byte to screen
    jsr close_command   ; close
    jsr open_command    ; open again, now for ACMD41
    lda #<acmd41
    sta BUF2
    lda #>acmd41
    sta BUF3
    jsr send_command    ; send ACMD41 command
    jsr receive_r1      ; receive response
    jsr close_command
    cmp #0              ; check response byte
    beq @exit           ; if SUCCESS ($00), exit routine
    plx                 ; retrieve attempt counter from stack
    inx                 ; increment
    cpx #20             ; check if 20
    beq @fail           ; if so, fail
    jmp @loop           ; if not, restart loop
@fail:
    lda $FF
@exit:
    rts

;-------------------------------------------------------------------------------
; SDCMD58 routine
;
; Send CMD58 command to the SD-card and retrieve the result
;-------------------------------------------------------------------------------
_sdcmd58:
    lda #>@str
    ldx #<@str
    jsr putstr
    jsr open_command
    lda #<cmd58
    sta BUF2
    lda #>cmd58
    sta BUF3
    jsr send_command
    jsr receive_r3
    jsr close_command
    jsr newline
    rts
@str:
    .asciiz "Sending SDCMD58. Response: "

;-------------------------------------------------------------------------------
; SDCMD17 routine
;
; Send CMD17 command to the SD-card and retrieve the result.
;
; This function is provided as a C-routine using __cdecl__, before returning
; the soft stack needs to be cleaned by calling incsp4 as a 4-byte argument
; is provided. The return value is stored in AX.
;-------------------------------------------------------------------------------
_sdcmd17:
    jsr open_command

    ; load command byte
    lda #17|$40
    sta SERIAL
    sta CLKSTART

    ; set pointer to softstack
    lda sp
    sta BUF2
    lda sp+1
    sta BUF3

    ; retrieve address and send to SD-card
    ldy #4
@next:                  ; loop over bytes
    dey
    lda (BUF2),y
    sta SERIAL
    sta CLKSTART
    cpy #0
    bne @next

    ; closing command byte
    lda #$01
    sta SERIAL
    sta CLKSTART

    jsr receive_r1      ; receive response
    jsr newline
    lda #$FF            ; flush with ones
    sta SERIAL
    ldx #0              ; set inner poll counter
    ldy #0              ; set outer poll counter
@tryagain:
    sta CLKSTART        ; send pulses
    jsr wait            ; small delay
    lda SERIAL          ; read result
    cmp #$FE            ; check if 0xFE
    beq @continue       ; if so, done polling and continue
    inx                 ; if not, increment poll counter
    beq @inccounter
    jsr wait            ; add small delay
    jmp @tryagain       ; if not, try again
@inccounter:
    ldx #0              ; reset inner poll counter
    iny
    jmp @tryagain
@continue:
    jsr putdec          ; print value
    jsr newline
    jsr readblock       ; read block, which will also output checksum
    jsr close_command   ; close interface
@exit:
    jsr incsp4		; remove function arguments from the stack
    lda BUF2
    ldx BUF3
    rts

;-------------------------------------------------------------------------------
; READBLOCK routine
;
; Read a 512 byte block, including the checksum, from the SD-card
; Store the checksum in BUF2 and BUF3
;-------------------------------------------------------------------------------
readblock:
    lda #$00
    sta BUF2
    lda #$80
    sta BUF3
    ldx #2              ; set counter for 256 bytes
@outer:
    ldy #0              ; set byte counter for inner loop
@inner:
    sta CLKSTART        ; pulse clock, does not care about value of ACC
    jsr wait            ; wait a bit
    lda SERIAL          ; read byte from SD-card
    sta (BUF2),y        ; store in upper RAM
    iny                 ; increment byte counter
    bne @inner          ; read 256 bytes? if so, continue
    lda #$81            ; increment address
    sta BUF3
    dex
    bne @outer          ; if not zero, go for another 256 bytes

    ; retrieve checksum and store it
    sta CLKSTART        ; pulse clock for checksum, lower byte
    jsr wait
    lda SERIAL
    sta BUF2
    sta CLKSTART        ; pulse clock for checksum, lower byte
    jsr wait
    lda SERIAL
    sta BUF3
    rts

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
; byte is received. If more than 128 attempts are required, the function puts
; $FF in BUF2, else the return value is placed in BUF2.
;-------------------------------------------------------------------------------
receive_r1:
    jsr poll_card
    sta BUF2
@exit:
    rts

;-------------------------------------------------------------------------------
; RECEIVE_R3 or RECEIVE R7 routine
;
; Receives a R7 type of response. Keeps on polling the SD-card until a non-$FF
; byte is received. If more than 128 attempts are required, the function errors
; by setting the carry bit high.
;-------------------------------------------------------------------------------
receive_r3:
receive_r7:
    jsr poll_card
    ldy #0              ; retrieve four more bytes
    sta (BUF4),y
    iny
@next:
    lda #$FF            ; load in ones in shift register
    sta SERIAL          ; latch onto shift register
    sta CLKSTART        ; start transfer
    jsr wait            ; small delay before reading out result
    lda SERIAL          ; read result
    sta (BUF4),y
    iny
    cpy #5
    bne @next
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
    cpx #128            ; threshold reached?
    beq @fail           ; upon 128 attempts, fail
    jmp @tryagain
@fail:
    lda #$FF
@done:
    rts

;-------------------------------------------------------------------------------
; OPEN_COMMAND routine
;
; Flush buffers before every command
;-------------------------------------------------------------------------------
open_command:
    lda #$FF
    sta SERIAL
    sta CLKSTART
    jsr wait
    sta SELECT
    sta CLKSTART
    jsr wait
    rts

;-------------------------------------------------------------------------------
; CLOSE_COMMAND routine
;
; Flush buffers after every command
;-------------------------------------------------------------------------------
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
