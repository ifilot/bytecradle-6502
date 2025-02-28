; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.define STRLB               $10     ; string low byte
.define STRHB               $11     ; string high byte
.define PUTSTRNL            $FFF4   ; print string routine

.segment "CODE"

.byte $00,$10       ; location

;-------------------------------------------------------------------------------
; Start sequence
;-------------------------------------------------------------------------------
start:              ; reset vector points here
    lda #<hwstr		; load lower byte
    sta STRLB
    lda #>hwstr		; load upper byte
    sta STRHB
    jsr PUTSTRNL
    rts

hwstr:
    .asciiz "Hello World!"