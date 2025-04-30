.PSC02

.include "constants.inc"
.include "functions.inc"

.export ansitest

.DEFINE COLOR_INDEX $0400
.DEFINE FRAME_INDEX $0401

.segment "CODE"

;-------------------------------------------------------------------------------
; Test some ANSI codes
;-------------------------------------------------------------------------------
ansitest:
    lda #<@strcolor
    ldx #>@strcolor
    jsr putstrnl
    jsr colortest
    jsr wait_keypress
    jsr clearscreen
    lda #<@strcursor
    ldx #>@strcursor
    jsr putstrnl
    jsr newline
    jsr diagonaltest
    jsr newline
    lda #<@strcomplete
    ldx #>@strcomplete
    jsr putstrnl
    rts

@strcolor:
    .asciiz "## TESTING COLORS ##"

@strcursor:
    .asciiz "## TESTING CURSOR POSITIONING ##"

@strcomplete:
    .asciiz "-- ANSI TESTS COMPLETED --"

;-------------------------------------------------------------------------------
; WAIT_KEYPRESS ROUTINE
;-------------------------------------------------------------------------------
wait_keypress:
    lda #<@str
    ldx #>@str
    jsr putstrnl
@wait:
    jsr getch
    cmp #0
    beq @wait
    rts

@str:
    .asciiz "Press any key to continue to next test..."

;-------------------------------------------------------------------------------
; PERFORM COLOR TEST
;-------------------------------------------------------------------------------
colortest:
    ldy #0            ; Index into the color table

@next_color:
    lda color_table_lo,y
    sta BUF4
    lda color_table_hi,y
    sta BUF4+1
    ldx BUF4+1
    lda BUF4
    phy
    jsr putstr        ; Call putstr with X:A pointer to string
    ply
    iny
    cpy #16
    bne @next_color
    jsr newline
    rts

;-------------------------------------------------------------------------------
; PRINT CHARACTERS DIAGONALLY ON THE SCREEN
;-------------------------------------------------------------------------------
diagonaltest:
    ldy #3
@next:
    phy
    tya
    tax
    jsr putcursor
    lda #'#'
    jsr putch
    ply
    iny
    cpy #11
    bne @next

    ldy #3
    ldx #10
@next2:
    phy
    phx
    tya
    jsr putcursor
    lda #'#'
    jsr putch
    plx
    ply
    iny
    dex
    cpy #11
    bne @next2
    jsr newline
    rts

.segment "DATA"

color_table_lo:
    .byte <black, <red, <green, <yellow, <blue, <magenta, <cyan, <white
    .byte <bright_black, <bright_red, <bright_green, <bright_yellow
    .byte <bright_blue, <bright_magenta, <bright_cyan, <bright_white

color_table_hi:
    .byte >black, >red, >green, >yellow, >blue, >magenta, >cyan, >white
    .byte >bright_black, >bright_red, >bright_green, >bright_yellow
    .byte >bright_blue, >bright_magenta, >bright_cyan, >bright_white

black:          .byte $1B,"[30m Black ",$1B,"[0m",10,0
red:            .byte $1B,"[31m Red ",$1B,"[0m",10,0
green:          .byte $1B,"[32m Green ",$1B,"[0m",10,0
yellow:         .byte $1B,"[33m Yellow ",$1B,"[0m",10,0
blue:           .byte $1B,"[34m Blue ",$1B,"[0m",10,0
magenta:        .byte $1B,"[35m Magenta ",$1B,"[0m",10,0
cyan:           .byte $1B,"[36m Cyan ",$1B,"[0m",10,0
white:          .byte $1B,"[37m White ",$1B,"[0m",10,0

bright_black:   .byte $1B,"[90m BrightBlack ",$1B,"[0m",10,0
bright_red:     .byte $1B,"[91m BrightRed ",$1B,"[0m",10,0
bright_green:   .byte $1B,"[92m BrightGreen ",$1B,"[0m",10,0
bright_yellow:  .byte $1B,"[93m BrightYellow ",$1B,"[0m",10,0
bright_blue:    .byte $1B,"[94m BrightBlue ",$1B,"[0m",10,0
bright_magenta: .byte $1B,"[95m BrightMagenta ",$1B,"[0m",10,0
bright_cyan:    .byte $1B,"[96m BrightCyan ",$1B,"[0m",10,0
bright_white:   .byte $1B,"[97m BrightWhite ",$1B,"[0m",10,0
