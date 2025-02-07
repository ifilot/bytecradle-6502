.include "constants.inc"
.import boot
.import isr

;-------------------------------------------------------------------------------
; Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
    .word boot          ; reset / $FFFA
    .word boot          ; nmi / $FFFC
    .word isr           ; irq/brk / $FFFE