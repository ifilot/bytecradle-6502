.include "constants.inc"
.include "functions.inc"

.export sdtest

.segment "CODE"
.PSC02

; bit masks
.define SD_MISO   #%00000001  ; PB0 input
.define SD_MOSI   #%00000010  ; PB1
.define SD_CLK    #%00000100  ; PB2
.define SD_CS     #%00001000  ; PB3

; Bitwise NOT masks (for AND operations)
.define NOT_SD_MISO    #%11111110  ; clears PB0
.define NOT_SD_MOSI    #%11111101  ; clears PB1
.define NOT_SD_CLK     #%11111011  ; clears PB2
.define NOT_SD_CS      #%11110111  ; clears PB3

.define CMD8_RESP       $80  ; zero page address to store results

;-------------------------------------------------------------------------------
; Test interfacing with the SD-card
;-------------------------------------------------------------------------------
sdtest:
    sei
    lda #<@str
    ldx #>@str
    jsr putstr
    jsr newline

    lda NOT_SD_MISO        ; set pb1–pb3 as output, pb0 (miso) as input
    sta VIA_DDRB

    ; set cs high, sck low, mosi low
    lda SD_CS
    sta VIA_PORTB

    jsr send_idle_clocks

    lda #<@strcmd00
    ldx #>@strcmd00
    jsr putstr
    jsr newline

    jsr send_cmd0
    jsr puthex
    jsr newline

    lda #<@strcmd08
    ldx #>@strcmd08
    jsr putstr
    jsr newline

    jsr send_cmd8
    ldx #0
@next:
    lda CMD8_RESP,x
    jsr puthex
    inx
    cpx #5
    bne @next
    jsr newline

    cli
    rts

@str:
    .asciiz "Start SD-CARD test..."
@strcmd00:
    .asciiz "CMD00:"
@strcmd08:
    .asciiz "CMD08:"

;-------------------------------------------------------------------------------
; Send idle clocks
;-------------------------------------------------------------------------------
send_idle_clocks:
    ldx #10              ; 10 bytes = 80 clocks
idle_loop:
    lda #$ff
    phx
    jsr spi_send
    plx
    dex
    bne idle_loop
    rts

;-------------------------------------------------------------------------------
; Send CMD00
;
; Note that spi_send garbes X, so for the counter, we have to use Y
;-------------------------------------------------------------------------------
send_cmd0:
    lda #<@cmd00
    sta BUF2
    lda #>@cmd00
    sta BUF3
    jsr send_command
    jsr read_response
    sta BUF1
    jsr sdclose
    lda BUF1
    rts

@cmd00:
    .byte $40, $00, $00, $00, $00, $95

;-----------------------------------------------------------------------------
; Send CMD08
; Send CMD8 packet: 0x48 00 00 01 AA 87
;-----------------------------------------------------------------------------
send_cmd8:
    lda #<@cmd08
    sta BUF2
    lda #>@cmd08
    sta BUF3
    jsr send_command
    jsr read_response
    sta CMD8_RESP       ; store R1 response
    ldx #0
@read_rest:
    jsr spi_recv
    sta CMD8_RESP+1,x
    inx
    cpx #4
    bne @read_rest
    jsr sdclose
    lda CMD8_RESP
    rts

@cmd08:
    .byte $48, $00, $00, $01, $AA, $87

;-------------------------------------------------------------------------------
; Send an 6-byte command to the SD card, command is stored in BUF2:BUF3
;-------------------------------------------------------------------------------
send_command:
    jsr sdopen          ; open SD-card for sending command
    ldy #0
@next:
    lda (BUF2),y
    jsr spi_send
    iny
    cpy #6
    bne @next
    rts

;-------------------------------------------------------------------------------
; Read response (up to 8 retries)
;
; Garbles: X
; Result: A
;-------------------------------------------------------------------------------
read_response:
    ldx #8
wait_resp:
    jsr spi_recv
    cmp #$ff
    beq skip             ; still idle (keep waiting)
    rts                  ; got response!
skip:
    dex
    bne wait_resp
    rts                  ; timeout

;-------------------------------------------------------------------------------
; SPI send: Send byte stored in A
;
; Garbles: X
; Conserves: A
;-------------------------------------------------------------------------------
spi_send:
    pha
    ldx #8
bit_loop:
    asl                             ; shift bit into carry
    lda VIA_PORTB
    and #%11111001                 ; clear mosi & sck
    bcc no_mosi
    ora SD_MOSI
no_mosi:
    sta VIA_PORTB       ; set mosi
    ora SD_CLK
    sta VIA_PORTB       ; clock high
    and NOT_SD_CLK
    sta VIA_PORTB       ; clock low
    pla
    rol
    pha
    dex
    bne bit_loop
    pla
    rts

;-------------------------------------------------------------------------------
; SPI receive
;
; Garbles: X,Y
; Result: A
;-------------------------------------------------------------------------------
spi_recv:
    ldy #8
    stz BUF1            ; use ZP buffer to store result
recv_loop:
    asl BUF1            ; create vacancy for bit
    lda VIA_PORTB
    ora SD_CLK
    sta VIA_PORTB       ; clock high
    lda VIA_PORTB
    and SD_MISO         ; extract MISO
    beq no_bit          ; acc has zero
    lda #1              ; set bit 1
no_bit:
    ora BUF1            ; merge result with BUF1
    sta BUF1            ; store in BUF1
    lda VIA_PORTB
    and NOT_SD_CLK
    sta VIA_PORTB       ; clock low
    dey
    bne recv_loop
    lda BUF1
    rts

;-------------------------------------------------------------------------------
; Open SD-CARD before command
;-------------------------------------------------------------------------------
sdopen:
    lda #$FF
    jsr spi_send
    lda VIA_PORTB
    and NOT_SD_CS            ; put CS high
    sta VIA_PORTB
    rts

;-------------------------------------------------------------------------------
; Close SD-CARD after command
;-------------------------------------------------------------------------------
sdclose:
    lda #$ff
    jsr spi_send
    lda VIA_PORTB
    ora SD_CS            ; put CS high
    sta VIA_PORTB
    rts