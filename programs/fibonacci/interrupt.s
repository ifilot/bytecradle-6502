.import _stop
.export _irq_int, _nmi_int

.PSC02

.define ACIA_DATA       $9F04
.define ACIA_STAT       $9F05
.define ACIA_CMD        $9F06
.define ACIA_CTRL       $9F07

; textbuffer variables
.define TBPR		$02
.define TBPL		$03
.define TB              $0200		; store textbuffer in page 2
.define CMDBUF          $0300           ; position of command buffer
.define CMDLENGTH       $0310           ; number of bytes in buffer, max 16

.segment "CODE"

;-------------------------------------------------------------------------------
; interrupt service routine
;-------------------------------------------------------------------------------
_irq_int:
    pha			; put A on stack
    lda ACIA_STAT	; check status
    and #$08		; check for bit 3
    beq isr_exit	; if not set, exit isr
    lda ACIA_DATA	; load byte
    phx
    ldx TBPR		; load pointer index
    sta TB,x            ; store character
    inc TBPR
    plx			; recover X
isr_exit:
    pla			; recover A
    rti

_nmi_int:
    rti

break:
    jmp _stop
