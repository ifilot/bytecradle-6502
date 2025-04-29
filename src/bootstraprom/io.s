.export putch
.export getch

.PSC02

.include "constants.inc"

.segment "CODE"

;-------------------------------------------------------------------------------
; GETCHAR routine
;
; retrieve a char from the key buffer in the accumulator
; Garbles: A,X
;-------------------------------------------------------------------------------
getch:
    phx
    lda TBPL            ; load textbuffer left pointer
    cmp TBPR            ; load textbuffer right pointer
    beq @nokey          ; if the same, exit routine
    ldx TBPL            ; else, load left pointer
    lda TB,x            ; load value stored in text buffer
    inc TBPL
    jmp @exit
@nokey:
    lda #0
@exit:
    plx
    rts

;-------------------------------------------------------------------------------
; putchar routine
;
; Converves A
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting.
; At 12 MhZ, we need to wait 10e6 * 10 / 115200 / 7 = 124 clock cycles,
; where the 5 corresponds to the combination of "DEC" and "BNE" taking 5 clock
; cyles.
;
;  4.000 MHz    :  50
;  5.120 MHz    :  64
; 10.000 MHz    : 124
; 12.000 MHz    : 149 (works on Tiny)
; 14.310 MHz    : 177 (works on Tiny)
; 16.000 MHz    : 198 (works on Tiny)
;-------------------------------------------------------------------------------
putch:
    pha             ; preserve A
    sta ACIA_DATA   ; write the character to the ACIA data register
    lda #198        ; initialize inner loop
@inner:
    nop             ; NOP; 2 cycles
    dec             ; decrement A; 2 cycles
    bne @inner      ; check if zero; 3 cycles
    pla             ; retrieve A from stack
    rts