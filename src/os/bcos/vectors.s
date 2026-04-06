.include "constants.inc"
.import _init
.import isr

;-------------------------------------------------------------------------------
; Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
    .word _init         ; reset / $FFFA
    .word _init         ; nmi / $FFFC
    .word isr           ; irq/brk / $FFFE
