.include "constants.inc"

.export makecrctable
.export _crc16_xmodem_sdsector

;-------------------------------------------------------------------------------
; Code inspired from:
; https://web.archive.org/web/20250323022422/https://6502.org/source/integers/crc.htm
;-------------------------------------------------------------------------------

.define CRCLO     $9E00       ; two 256-byte tables for quick lookup
.define CRCHI     $9F00       ; (should be page-aligned for speed)

;-------------------------------------------------------------------------------
; generate crc lookup table
;-------------------------------------------------------------------------------
makecrctable:
    ; make sure the table is stored in SD-CARD RAMBANK
    lda #63
    sta RAMBANKREGISTER

    ldx #0                  ; x counts from 0 to 255
@byteloop: 
    lda #0                  ; a contains the low 8 bits of the crc-16
    stx BUF2                ; and crc contains the high 8 bits
    ldy #8                  ; y counts bits in a byte
@bitloop:
    asl
    rol BUF2                ; shift crc left
    bcc @noadd              ; do nothing if no overflow
    eor #$21                ; else add crc-16 polynomial $1021
    pha                     ; save low byte
    lda BUF2                ; do high byte
    eor #$10
    sta BUF2
    pla                     ; restore low byte
@noadd:
    dey
    bne @bitloop            ; do next bit
    sta CRCLO,x             ; save crc into table, low byte
    lda BUF2                ; then high byte
    sta CRCHI,x
    inx
    bne @byteloop           ; do next byte
    rts

;-------------------------------------------------------------------------------
; update crc using lookup table
;-------------------------------------------------------------------------------
updcrc:
    eor BUF3                ; quick crc computation with lookup tables
    tax
    lda BUF2
    eor CRCHI,x
    sta BUF3
    lda CRCLO,x
    sta BUF2
    rts

;-------------------------------------------------------------------------------
; calculate crc16 (xmodem) for sd sector
;-------------------------------------------------------------------------------
_crc16_xmodem_sdsector:
    stz BUF2
    stz BUF3
    ldy #0
@loop1:
    lda $8000,y
    jsr updcrc
    iny
    bne @loop1
    ldy #0
@loop2:  
    lda $8100,y
    jsr updcrc
    iny
    bne @loop2
    lda BUF2
    ldx BUF3
    rts