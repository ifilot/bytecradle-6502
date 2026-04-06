.export _store_ram_upper
.export _probe_ram_upper

.PSC02

.include "constants.inc"

.segment "CODE"

;-------------------------------------------------------------------------------
; STORE_RAM_UPPER routine
;
; Probes a single RAMBANK
;-------------------------------------------------------------------------------
_store_ram_upper:
    sta BUF3
    stz BUF1
    lda #$80
    sta BUF2

@nextpage:
    lda BUF3
    ldy #$00
@next:
    sta (BUF1),y
    iny
    bne @next
    inc BUF2
    lda #$C0
    cmp BUF2
    bne @nextpage

    rts

;-------------------------------------------------------------------------------
; PROBE_RAM_UPPER routine
;
; Probes a single RAMBANK
;-------------------------------------------------------------------------------
_probe_ram_upper:
    sta BUF3
    stz BUF1
    lda #$80
    sta BUF2

@nextpage:
    lda #$AA
    ldy #$00
@next:
    lda (BUF1),y
    cmp BUF3
    bne @fail
    iny
    bne @next
    inc BUF2
    lda #$C0
    cmp BUF2
    bne @nextpage

    lda #$00
    rts
@fail:
    lda #$FF
    rts