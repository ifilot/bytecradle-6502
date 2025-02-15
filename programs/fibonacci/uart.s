; this code is a simple monitor class for the ByteCradle 6502

.export _charout, _stringout

.PSC02

.define ACIA_DATA       $7F04
.define ACIA_STAT       $7F05
.define ACIA_CMD        $7F06
.define ACIA_CTRL       $7F07

.define STRLB		$10
.define STRHB		$11

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

;-------------------------------------------------------------------------------
; STRINGOUT routine
; Garbles: A, Y
;
; Loops over a string and print its characters until a zero-terminating character 
; is found. Assumes that $10 is used on the zero page to store the address of
; the string.
;-------------------------------------------------------------------------------
_stringout:
    sta STRLB		; store low byte
    stx STRHB		; store high byte
    ldy #0
@nextchar:
    lda (STRLB),y       ; load character from string
    beq @exit           ; if terminating character is read, exit
    jsr _charout        ; else, print char
    iny                 ; increment y
    jmp @nextchar       ; read next char
@exit:
    rts    
