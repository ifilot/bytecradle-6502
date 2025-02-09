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

init_sd:
    lda DESELECT
    sta DESELECT
    jsr sdpulse
    rts

sdpulse:
    lda #$FF
    ldx #12
@nextpulse:
    sta CLKSTART
    jsr wait
    dex
    bne @nextpulse
    rts

sdcmd00:
    lda #>@str
    ldx #<@str
    jsr putstr
    jsr open_command
    lda #<cmd00
    sta BUF2
    lda #>cmd00
    sta BUF3
    jsr receive_r1
    jsr close_command
    jsr newline
    rts
@str:
    .asciiz "Sending CMD00. Response: "

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

; send cmd00
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

;
; Fixed commands instructions
;
cmd00:
    .byte $40,$00,$00,$00,$00,$95
cmd08:
    .byte 8|$40,$00,$00,$01,$AA,$86|$01

; response R1
receive_r1:
    lda #$FF
    sta SERIAL
    sta CLKSTART
    jsr wait
    sta CLKSTART
    jsr wait
    lda SERIAL
    jsr puthex
    rts

; response R7
receive_r7:
    lda #$FF
    sta SERIAL
    sta CLKSTART
    jsr wait
    ldx #5
@next:
    lda #$FF
    sta SERIAL
    sta CLKSTART
    jsr wait
    lda SERIAL
    jsr puthex
    dex
    bne @next
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

wait:
    nop
    nop
    rts
