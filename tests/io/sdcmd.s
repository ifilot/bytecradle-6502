.include "constants.inc"
.include "functions.inc"

.export sdtest

.segment "CODE"
.PSC02

; define base address of SD-card interface
.define SERIAL      $7F20
.define CLKSTART    $7F21
.define DESELECT    $7F22
.define SELECT      $7F23

.define LONGBUF     $0300

;-------------------------------------------------------------------------------
; Test interfacing with the SD-card
;-------------------------------------------------------------------------------
sdtest:
@retry:
    ; wake up SD card
    jsr close_sd
    jsr init_sd

    ; cmd00
    lda #<@str00
    ldx #>@str00
    jsr putstr
    jsr sdcmd00
    jsr puthex
    jsr newline
    cmp #$01
    bne @retry

    ; cmd08
    lda #<@str08
    ldx #>@str08
    jsr putstr
    lda #<LONGBUF           ; set storage address
    ldx #>LONGBUF
    jsr sdcmd08             ; result is stored in A
    jsr puthex
    jsr newline
    cmp #$01
    bne @retry

    ; show response
    ldy #0
@next08:
    phy
    lda LONGBUF,y
    jsr puthex
    lda #' '
    jsr putch
    ply
    iny
    cpy #5
    bne @next08
    jsr newline

    ; sdcmd58
@try:
    lda #<@str41
    ldx #>@str41
    jsr putstr
    jsr sdacmd41
    jsr puthex
    jsr newline
    cmp #0
    bne @try                ; if response is not 0, try again
    lda #<@str58
    ldx #>@str58
    jsr putstr
    lda #<LONGBUF           ; set storage address
    ldx #>LONGBUF
    jsr sdcmd58
    jsr puthex
    jsr newline
    cmp #0
    bne @try

    ; show response
    ldy #0
@next58:
    phy
    lda LONGBUF,y
    jsr puthex
    lda #' '
    jsr putch
    ply
    iny
    cpy #5
    bne @next58
    jsr newline

    jsr close_sd

    rts

@str00:
    .asciiz "CMD00: "
@str08:
    .asciiz "CMD08: "
@str41:
    .asciiz "ACMD41: "
@str58:
    .asciiz "CMD58: "

;-------------------------------------------------------------------------------
; INIT_SD ROUTINE
;
; Initialize the SD-card
;-------------------------------------------------------------------------------
init_sd:
    lda SELECT
    sta SELECT
    jsr sdpulse
    rts

;-------------------------------------------------------------------------------
; CLOSE_SD ROUTINE
;
; Close the connectionn to the SD-card
;-------------------------------------------------------------------------------
close_sd:
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
sdcmd00:
    jsr open_command
    lda #<cmd00
    sta BUF2
    lda #>cmd00
    sta BUF3
    jsr send_command
    jsr receive_r1          ; receive response
    jsr close_command       ; conserves A
    rts

;-------------------------------------------------------------------------------
; SDCMD08 routine
;
; Send CMD08 command to the SD-card and retrieve the result. The place to store
; the R7 response is provided via a pointer stored in AX upon function entry.
; This pointer is stored in BUF4:5.
;-------------------------------------------------------------------------------
sdcmd08:
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
sdacmd41:
    ldx #0              ; set attempt counter
@loop:
    phx                 ; push attempt counter to stack
    jsr open_command
    lda #<cmd55         ; load CMD55
    sta BUF2
    lda #>cmd55
    sta BUF3
    jsr send_command    ; send command
    jsr receive_r1      ; receive response, prints response byte to screen
    jsr close_command   ; close (garbles x)
    jsr open_command    ; open again, now for ACMD41
    lda #<acmd41
    sta BUF2
    lda #>acmd41
    sta BUF3
    jsr send_command    ; send ACMD41 command
    jsr receive_r1      ; receive response
    jsr close_command   ; close (garbles x)
    cmp #0              ; check response byte
    beq @exit           ; if SUCCESS ($00), exit routine
    plx                 ; retrieve attempt counter from stack
    inx                 ; increment
    cpx #20             ; check if 20
    beq @fail           ; if so, fail
    jmp @loop           ; if not, restart loop
@fail:
    lda $FF
    rts
@exit:
    plx                 ; clear stack
    rts

;-------------------------------------------------------------------------------
; SDCMD58 routine
;
; Send CMD58 command to the SD-card and retrieve the result
;-------------------------------------------------------------------------------
sdcmd58:
    sei
    sta BUF4            ; store storage location for response
    stx BUF5            ; upper byte storage location
    jsr open_command
    lda #<cmd58
    sta BUF2
    lda #>cmd58
    sta BUF3
    jsr send_command
    jsr receive_r3
    jsr close_command
    cli
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
; Flush buffers after every command. Garbles x.
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