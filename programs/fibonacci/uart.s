; this code is a simple monitor class for the ByteCradle 6502

.export _charout

.PSC02

.define ACIA_DATA       $9F04
.define ACIA_STAT       $9F05
.define ACIA_CMD        $9F06
.define ACIA_CTRL       $9F07

.segment "CODE"

;-------------------------------------------------------------------------------
; CHAROUT routine
; Garbles: A
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting. At 10 MhZ, we
; need to wait 1E7 * 10 / 115200 = 868 clock cycles. The combination of "DEC"
; and "BNE" both take 3 clock cyles, so we need about 173 iterations of these.
;-------------------------------------------------------------------------------
_charout:
    pha			; preserve A
    sta ACIA_DATA    	; write the character to the ACIA data register
    lda #173		; initialize inner loop
@inner:
    dec                 ; decrement A; 2 cycles
    bne @inner		; check if zero; 3 cycles
    pla
    rts
