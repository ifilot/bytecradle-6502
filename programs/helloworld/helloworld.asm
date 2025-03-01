; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.define PUTSTRNL            $FFF4   ; print string routine

.segment "HEADER"

.word $1000         ; location

.segment "CODE"

;-------------------------------------------------------------------------------
; Start sequence
;-------------------------------------------------------------------------------
start:              ; reset vector points here
    lda #<hwstr		; load lower byte
    ldx #>hwstr		; load upper byte
    jsr PUTSTRNL
    rts

hwstr:
    .asciiz "Hello World!"