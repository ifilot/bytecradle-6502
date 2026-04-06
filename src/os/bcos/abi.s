.include "jumptable.inc"

.export bcos_get_abi_major
.export bcos_get_abi_minor
.export bcos_reserved

.segment "CODE"

bcos_get_abi_major:
    lda #BCOS_ABI_MAJOR
    rts

bcos_get_abi_minor:
    lda #BCOS_ABI_MINOR
    rts

bcos_reserved:
    lda #$00
    rts
