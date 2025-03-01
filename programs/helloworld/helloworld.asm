; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.import __HEADER_LOAD__             ; will be grabbed from the .cfg file

.define PUTSTRNL            $FFF4   ; print string routine

;-------------------------------------------------------------------------------
; PROGRAM HEADER
;-------------------------------------------------------------------------------

.segment "HEADER"

.word __HEADER_LOAD__               ; program location

.segment "CODE"

;-------------------------------------------------------------------------------
; Start sequence
;-------------------------------------------------------------------------------
start:                              ; reset vector points here
    lda #<hwstr		                ; load lower byte
    ldx #>hwstr		                ; load upper byte
    jsr PUTSTRNL
    rts

hwstr:
    .asciiz "Hello World!"