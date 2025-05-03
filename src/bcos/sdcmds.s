.include "constants.inc"
.include "functions.inc"
.include "zeropage.inc"

.segment "CODE"

.PSC02

.export _sdinit
.export _sdpulse
.export _sdcmd00
.export _sdcmd08
.export _sdacmd41
.export _sdcmd58
.export _sdcmd17
.export _read_sector

.import incsp4
.import pushax

; bit masks
.define SD_MISO         #%00000001  ; PA0 input
.define SD_MOSI         #%00000010  ; PA1
.define SD_CLK          #%00000100  ; PA2
.define SD_CS           #%00001000  ; PA3

.define NOT_SD_MISO     #%11111110  ; clears PB0
.define NOT_SD_MOSI     #%11111101  ; clears PB1
.define NOT_SD_CLK      #%11111011  ; clears PB2
.define NOT_SD_CS       #%11110111  ; clears PB3

;-------------------------------------------------------------------------------
; Initialize SD interface
;-------------------------------------------------------------------------------
_sdinit:
    lda NOT_SD_MISO         ; set pb1–pb3 as output, pb0 (miso) as input
    sta VIA_DDRA
    lda SD_CS               ; set cs high, sck low, mosi low
    sta VIA_PORTA
    rts

;-------------------------------------------------------------------------------
; Send idle clocks
;-------------------------------------------------------------------------------
_sdpulse:
    ldx #10                 ; 10 bytes = 80 clocks
idle_loop:
    lda #$ff
    phx
    jsr spi_send
    plx
    dex
    bne idle_loop
    rts

;-------------------------------------------------------------------------------
; Send CMD00 – "GO_IDLE_STATE"
;
; Uses: 
;   BUF1 to store response
;   BUF3:BUF2: Command pointer
;-------------------------------------------------------------------------------
_sdcmd00:
    lda #<@cmd00
    sta BUF2
    lda #>@cmd00
    sta BUF3
    jsr sdopen
    jsr sd_send_cmd
    jsr sd_recv_byte
    sta BUF1
    jsr sdclose
    lda BUF1
    rts

@cmd00:
    .byte $40, $00, $00, $00, $00, $95

;-----------------------------------------------------------------------------
; Send CMD08 - "SEND_IF_COND"
;
; Uses: 
;   BUF5:BUF4: Response pointer
;   BUF3:BUF2: Command pointer
;-----------------------------------------------------------------------------
_sdcmd08:
    sta BUF4                    ; lower byte pointer
    stx BUF5                    ; upper byte pointer
    lda #<@cmd08                ; lower byte of SD command
    sta BUF2
    lda #>@cmd08                ; upper byte of SD command
    sta BUF3
    jsr sdopen                  ; open SD card
    jsr sd_send_cmd             ; send SD command
    jsr sd_recv_byte            ; read byte
    jsr sd_recv_r5
    jsr sdclose                 ; close SD card
    lda (BUF4)                  ; load response byte
    rts

@cmd08:
    .byte $48, $00, $00, $01, $AA, $87

;------------------------------------------------------------------------------
; Send ACMD41 – "SD_SEND_OP_COND"
; Must be preceded by CMD55
; Loops until response = 0x00 (card ready)
;
; Response: A - $00 if success, else $FF
;           Y - trial counter
;
; Uses:
;   BUF1" 
;   BUF3:BUF2: Command pointer
;   BUF4: Attempts counter
;------------------------------------------------------------------------------
_sdacmd41:
    stz BUF4                ; attempts counter
@loop:
    inc BUF4
    lda #<@cmd55            ; lower byte
    sta BUF2
    lda #>@cmd55            ; upper byte
    sta BUF3
    jsr sdopen
    jsr sd_send_cmd
    jsr sd_recv_byte
    sta BUF1                ; store result in BUF1
    jsr sdclose             ; close SD-card
    lda BUF1                ; load result
    cmp #$01                ; expecting 'idle' state
    bne @fail55             ; if not, something went wrong

    ; Send ACMD41
    lda #<@acmd41
    sta BUF2                ; lower byte
    lda #>@acmd41
    sta BUF3                ; upper byte
    jsr sdopen
    jsr sd_send_cmd
    jsr sd_recv_byte
    sta BUF1                ; store result in BUF1
    jsr sdclose             ; close SD-card
    lda BUF1                ; load result
    beq @done               ; exit loop if ready (A == 0)
    jmp @loop               ; try again

@fail:
    lda #$FF                ; return error
    ldy BUF4
    rts

@fail55:
    lda #$FE                ; return error
    ldy BUF4
    rts

@done:
    lda BUF1
    ldy BUF4
    rts

@cmd55:
    .byte $77, $00, $00, $00, $00, $65 ; CMD55 with dummy CRC

@acmd41:
    .byte $69, $40, $00, $00, $00, $77 ; ACMD41 with HCS bit set

;------------------------------------------------------------------------------
; Send CMD58 – "READ_OCR"
; Response is 5 bytes: R1 + 4-byte OCR
;
; Uses: 
;   BUF5:BUF4: Response pointer
;   BUF3:BUF2: Command pointer
;------------------------------------------------------------------------------
_sdcmd58:
    sta BUF4                    ; lower byte pointer
    stx BUF5                    ; upper byte pointer
    lda #<@cmd58
    sta BUF2
    lda #>@cmd58
    sta BUF3
    jsr sdopen
    jsr sd_send_cmd
    jsr sd_recv_byte
    jsr sd_recv_r5
    jsr sdclose                 ; close SD card
    lda (BUF4)                  ; load response byte
    jsr sdclose
    lda (BUF4)
    rts

@cmd58:
    .byte 58|$40,$00,$00,$00,$00,$00|$01

;------------------------------------------------------------------------------
; Read Boot Sector (Block 0) into $1000 using CMD17
;------------------------------------------------------------------------------
_read_sector:
_sdcmd17:
    ; ensure correct RAM bank is loaded
    lda #63                     ; SD-CARD bank (#63)
    sta RAMBANKREGISTER

    ; store first byte of command in memory
    lda #(17|$40)               ; byte 0
    sta RAMBANK

    ; set pointer to softstack
    lda sp
    sta BUF2
    lda sp+1
    sta BUF3

    ; copy address
    ldy #4
    ldx #0
@nextcmd:
    dey
    inx
    lda (BUF2),y
    sta RAMBANK,x
    cpy #0
    bne @nextcmd

    ; store closing byte
    lda #$01
    sta RAMBANK+5

    ; set newly formed address
    lda #<RAMBANK
    sta BUF2
    lda #>RAMBANK
    sta BUF3
    jsr sdopen
    jsr sd_send_cmd
    jsr sd_recv_byte
    cmp #$00
    bne @fail                       ; If not 0, read failed

    ; Wait for data token 0xFE
@wait_data_token:
    jsr spi_recv
    cmp #$FE
    bne @wait_data_token

    ; Read 512 bytes into RAMBANK
    lda #<RAMBANK
    sta BUF2
    lda #>RAMBANK
    sta BUF3
@read_loop:
    jsr spi_recv
    sta (BUF2)
    inc BUF2
    bne @skiphb
    inc BUF3
@skiphb:
    lda BUF3
    cmp #(>RAMBANK+3)
    bne @read_loop                  ; Continue until X wraps (256 bytes)

    ; Skip CRC (2 bytes)
    jsr spi_recv
    jsr spi_recv

    jsr sdclose
    jsr incsp4		                ; remove function arguments from the stack
    lda BUF2                        ; low byte in A
    ldx BUF3                        ; high byte in X
    rts

@fail:
    jsr sdclose
    jsr incsp4
    ldx #$FF                        ; error
    lda #$FF                        ; error
    rts

;-------------------------------------------------------------------------------
; Send an 6-byte command to the SD card, command is stored in BUF3:BUF2
;
; Garbles: A,X,Y
;-------------------------------------------------------------------------------
sd_send_cmd:
    ldy #0
@next:
    lda (BUF2),y
    jsr spi_send        ; garbles X
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
sd_recv_byte:
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
; Specialty routine to receive 5 bytes; stores 5 bytes at pointer
; set at BUF5:BUF4
;-------------------------------------------------------------------------------
sd_recv_r5:
    sta (BUF4)                  ; store R1 response
    ldy #1
@next:
    jsr spi_recv
    sta (BUF4),y                ; store remaining parts of the response
    iny
    cpy #5
    bne @next
    rts

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
    lda VIA_PORTA
    and #%11111001                 ; clear mosi & sck
    bcc no_mosi
    ora SD_MOSI
no_mosi:
    sta VIA_PORTA       ; set mosi
    ora SD_CLK
    sta VIA_PORTA       ; clock high
    and NOT_SD_CLK
    sta VIA_PORTA       ; clock low
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
; Garbles: X
; Result: A
; Uses: BUF1 to store result
;-------------------------------------------------------------------------------
spi_recv:
    phy
    ldy #8
    stz BUF1            ; use ZP buffer to store result
recv_loop:
    asl BUF1            ; create vacancy for bit
    lda VIA_PORTA
    ora SD_CLK
    sta VIA_PORTA       ; clock high
    lda VIA_PORTA
    and SD_MISO         ; extract MISO
    beq no_bit          ; acc has zero
    lda #1              ; set bit 1
no_bit:
    ora BUF1            ; merge result with BUF1
    sta BUF1            ; store in BUF1
    lda VIA_PORTA
    and NOT_SD_CLK
    sta VIA_PORTA       ; clock low
    dey
    bne recv_loop
    lda BUF1
    ply
    rts

;-------------------------------------------------------------------------------
; Open SD-CARD before command
;
; Garbles: A
;-------------------------------------------------------------------------------
sdopen:
    lda #$FF
    jsr spi_send
    lda VIA_PORTA
    and NOT_SD_CS            ; put CS high
    sta VIA_PORTA
    rts

;-------------------------------------------------------------------------------
; Close SD-CARD after command
;
; Garbles: A
;-------------------------------------------------------------------------------
sdclose:
    lda #$ff
    jsr spi_send
    lda VIA_PORTA
    ora SD_CS            ; put CS high
    sta VIA_PORTA
    rts