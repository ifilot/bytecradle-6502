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
    jsr clear_color
main_loop:
    jsr draw_frame
    jsr delay
    jsr next_frame
    jmp main_loop

;-----------------------------------------------
; draw_frame: draw one '#' at perimeter with color
;-----------------------------------------------
draw_frame:
    lda FRAME_INDEX
    asl         ; *2 (each coord = 2 bytes)
    tax

    lda perim_coords,x
    tay         ; row in Y
    lda perim_coords+1,x
    tax         ; col in X

    tya         ; A = row
    jsr set_cursor

    ldx COLOR_INDEX
    jsr set_color

    lda #'#'
    jsr putch
    rts

; set_cursor: A=row, X=col => move to ESC[row;colH]
set_cursor:
    ; Save values
    pha             ; save A (row)
    txa             ; col to A
    pha             ; save column on stack

    ; Send ESC + '['
    lda #ESC
    jsr putch
    lda #'['
    jsr putch

    ; Restore row/col and print row number
    pla             ; column from stack → A
    jsr printdec2

    lda #';'
    jsr putch

    pla             ; row from stack → A
    jsr printdec2

    lda #'H'
    jsr putch
    rts

;-----------------------------------------------
; printdec2: print decimal A using putch (0–99)
;-----------------------------------------------
printdec2:
    ldx #0              ; high digit counter

    sec                 ; set carry before sbc loop
@div_loop:
    cmp #10
    bcc @got_digits
    sbc #10
    inx
    bne @div_loop       ; always branches, just looping

@got_digits:
    cpx #0
    beq @only_ones

    txa                 ; high digit
    clc
    adc #'0'
    jsr putch

@only_ones:
    clc
    adc #'0'            ; A still holds remainder (0–9)
    jsr putch
    rts

;-----------------------------------------------
; set_color: X = 0–7 (ANSI color code)
;-----------------------------------------------
set_color:
    lda #ESC
    jsr putch
    lda #'['
    jsr putch
    lda #'3'
    jsr putch
    txa
    clc
    adc #'0'
    jsr putch
    lda #'m'
    jsr putch
    rts

;-----------------------------------------------
; next_frame: advance frame and color
;-----------------------------------------------
next_frame:
    inc FRAME_INDEX
    lda FRAME_INDEX
    cmp #16
    bne @keep
    lda #0
    sta FRAME_INDEX
@keep:
    inc COLOR_INDEX
    lda COLOR_INDEX
    cmp #8
    bne @done
    lda #0
    sta COLOR_INDEX
@done:
    rts

;-----------------------------------------------
; clear_color: reset ANSI color
;-----------------------------------------------
clear_color:
    lda #ESC
    jsr putch
    lda #'['
    jsr putch
    lda #'0'
    jsr putch
    lda #'m'
    jsr putch
    rts

;-----------------------------------------------
; delay loop: tweak as needed
;-----------------------------------------------
delay:
    ldx #$20
@outer:
    ldy #$FF
@inner:
    dey
    bne @inner
    dex
    bne @outer
    rts

;-----------------------------------------------
; Perimeter coordinates: (row, col) pairs
;-----------------------------------------------
perim_coords:
    .byte 10,20, 10,21, 10,22, 10,23, 10,24
    .byte 11,24, 12,24, 13,24, 14,24
    .byte 14,23, 14,22, 14,21, 14,20
    .byte 13,20, 12,20, 11,20
