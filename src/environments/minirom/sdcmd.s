.include "constants.inc"
.include "functions.inc"

.export sdtest

.segment "CODE"
.PSC02

; bit masks
.define SD_MISO         #%00000001  ; PA0 input
.define SD_MOSI         #%00000010  ; PA1
.define SD_CLK          #%00000100  ; PA2
.define SD_CS           #%00001000  ; PA3

.define NOT_SD_MISO     #%11111110  ; clears PB0
.define NOT_SD_MOSI     #%11111101  ; clears PB1
.define NOT_SD_CLK      #%11111011  ; clears PB2
.define NOT_SD_CS       #%11110111  ; clears PB3

.define RESP5           $80  ; zero page address to store results

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
    sta VIA_DDRA

    ; set cs high, sck low, mosi low
    lda SD_CS
    sta VIA_PORTA

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
    jsr print_r5

    lda #<@stracmd41
    ldx #>@stracmd41
    jsr putstr
    jsr newline

    jsr send_acmd41_loop
    pha
    tya
    jsr puthex
    lda #' '
    jsr putch
    pla
    jsr puthex
    jsr newline

    lda #<@strcmd58
    ldx #>@strcmd58
    jsr putstr
    jsr newline

    jsr send_cmd58
    jsr print_r5

    lda #<@strcmd17
    ldx #>@strcmd17
    jsr putstr
    jsr newline

    jsr read_boot_sector
    jsr puthex
    jsr newline

    lda #<@strrdbs
    ldx #>@strrdbs
    jsr putstr
    jsr newline
    jsr dump_boot_sector

    lda #<@stralldone
    ldx #>@stralldone
    jsr putstr
    jsr newline
    jsr newline

    cli
    rts

@str:
    .asciiz "Start SD-CARD test..."
@strcmd00:
    .asciiz "CMD00:"
@strcmd08:
    .asciiz "CMD08:"
@stracmd41:
    .asciiz "ACMD41:"
@strcmd58:
    .asciiz "CMD58:"
@strcmd17:
    .asciiz "CMD17:"
@strrdbs:
    .asciiz "Reading boot sector"
@stralldone:
    .asciiz "All done!"

;-------------------------------------------------------------------------------
; Convenience function to print the 5 response bytes
;-------------------------------------------------------------------------------
print_r5:
    ldx #0
@next:
    lda RESP5,x
    jsr puthex
    lda #' '
    jsr putch
    inx
    cpx #5
    bne @next
    jsr newline
    rts

;-------------------------------------------------------------------------------
; Send idle clocks
;-------------------------------------------------------------------------------
send_idle_clocks:
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
;-------------------------------------------------------------------------------
send_cmd0:
    lda #<@cmd00
    sta BUF2
    lda #>@cmd00
    sta BUF3
    jsr sdopen
    jsr send_command
    jsr read_response
    sta BUF1
    jsr sdclose
    lda BUF1
    rts

@cmd00:
    .byte $40, $00, $00, $00, $00, $95

;-----------------------------------------------------------------------------
; Send CMD08 - "SEND_IF_COND"
;-----------------------------------------------------------------------------
send_cmd8:
    lda #<@cmd08
    sta BUF2
    lda #>@cmd08
    sta BUF3
    jsr sdopen
    jsr send_command
    jsr read_response
    sta RESP5               ; store R1 response
    ldx #0
@read_rest:
    jsr spi_recv
    sta RESP5+1,x           ; store remaining parts of the response
    inx
    cpx #4
    bne @read_rest
    jsr sdclose
    lda RESP5
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
;------------------------------------------------------------------------------
send_acmd41_loop:
    stz BUF4                ; trial counter
@loop:
    inc BUF4
    lda #<@cmd55
    sta BUF2
    lda #>@cmd55
    sta BUF3
    jsr sdopen
    jsr send_command
    jsr read_response
    sta BUF1                ; store result in BUF1
    jsr sdclose             ; close SD-card
    lda BUF1                ; load result
    cmp #$01                ; expecting 'idle' state
    bne @fail               ; if not, something went wrong
    

    ; Send ACMD41
    lda #<@acmd41
    sta BUF2
    lda #>@acmd41
    sta BUF3
    jsr sdopen
    jsr send_command
    jsr read_response
    sta BUF1                ; store result in BUF1
    jsr sdclose             ; close SD-card
    lda BUF1                ; load result
    beq @done               ; exit loop if ready (A == 0)
    jmp @loop               ; try again

@fail:
    lda #$FF                ; return error
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
;------------------------------------------------------------------------------
send_cmd58:
    lda #<@cmd58
    sta BUF2
    lda #>@cmd58
    sta BUF3
    jsr sdopen
    jsr send_command
    jsr read_response
    sta RESP5               ; Store R1 response

    ldx #1
@next:
    jsr spi_recv
    sta RESP5,x
    inx
    cpx #5
    bne @next

    jsr sdclose
    lda RESP5               ; Return R1 in A
    rts

@cmd58:
    .byte 58|$40,$00,$00,$00,$00,$00|$01

;------------------------------------------------------------------------------
; Read Boot Sector (Block 0) into $1000 using CMD17
;------------------------------------------------------------------------------
read_boot_sector:
    lda #<@cmd17
    sta BUF2
    lda #>@cmd17
    sta BUF3
    jsr sdopen
    jsr send_command
    jsr read_response
    cmp #$00
    bne @fail               ; If not 0, read failed

    ; Wait for data token 0xFE
@wait_data_token:
    jsr spi_recv
    cmp #$FE
    bne @wait_data_token

    ; Read 512 bytes into $1000
    lda #$00
    sta BUF2
    lda #$10                ; High byte of address = $10
    sta BUF3
@read_loop:
    jsr spi_recv
    sta (BUF2)
    inc BUF2
    bne @skiphb
    inc BUF3
@skiphb:
    lda BUF3
    cmp #$13
    bne @read_loop          ; Continue until X wraps (256 bytes)

    ; Skip CRC (2 bytes)
    jsr spi_recv
    jsr spi_recv

    jsr sdclose
    lda #$00                ; success
    rts

@fail:
    jsr sdclose
    lda #$FF                ; error
    rts

;------------------------------------------------------------------------------
@cmd17:
    .byte 17|$40, $00, $00, $00, $00, $01 ; CMD17, block 0, dummy CRC

;-------------------------------------------------------------------------------
; Send an 6-byte command to the SD card, command is stored in BUF2:BUF3
;-------------------------------------------------------------------------------
send_command:
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
; Garbles: X,Y
; Result: A
;-------------------------------------------------------------------------------
spi_recv:
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
    rts

;-------------------------------------------------------------------------------
; Open SD-CARD before command
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
;-------------------------------------------------------------------------------
sdclose:
    lda #$ff
    jsr spi_send
    lda VIA_PORTA
    ora SD_CS            ; put CS high
    sta VIA_PORTA
    rts

;------------------------------------------------------------------------------
; Dump 512 bytes from $1000 to screen
; 32 bytes per line: hex + ASCII
;------------------------------------------------------------------------------
dump_boot_sector:
    lda #$00
    sta BUF2
    lda #$10                ; High byte of address = $10
    sta BUF3

    ldx #32
@next_line:
    ldy #16
@next_byte:
    lda (BUF2)
    jsr puthex
    jsr putspace
    inc BUF2
    bne @skiphb
    inc BUF3
@skiphb:
    dey
    bne @next_byte
    jsr newline
    dex
    bne @next_line

    jsr newline
    rts