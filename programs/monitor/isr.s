;-------------------------------------------------------------------------------
; INTERRUPT SERVICE ROUTINES
;-------------------------------------------------------------------------------

.include "constants.inc"

.export isr

.segment "CODE"

;-------------------------------------------------------------------------------
; Interrupt Service Routine
;
; Checks whether a character is available over the UART and stores it in the
; key buffer to be parsed later.
;-------------------------------------------------------------------------------
isr:
    pha			    ; put A on stack
    lda ACIA_STAT	; check status
    and #$08		; check for bit 3
    beq isr_exit	; if not set, exit isr
    lda ACIA_DATA	; load byte
    phx
    ldx TBPR		; load pointer index
    sta TB,x        ; store character
    inc TBPR
    plx			    ; recover X
isr_exit:
    pla			    ; recover A
    rti