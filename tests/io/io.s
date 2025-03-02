; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.define ACIA_DATA       $7F04
.define ACIA_STAT       $7F05
.define ACIA_CMD        $7F06
.define ACIA_CTRL       $7F07

.define STRLB           $00
.define STRHB           $01

.define LF              $0A     ; LF character (line feed)
.define ESC             $1B     ; VT100 escape character

;-------------------------------------------------------------------------------
; PROGRAM HEADER
;-------------------------------------------------------------------------------

.segment "CODE"

;-------------------------------------------------------------------------------
; Start sequence
;-------------------------------------------------------------------------------
boot:                              ; reset vector points here
    sei
    ldx #$FF
    txs
    jsr init_system
    jmp main

main:
    lda #<@str                     ; load lower byte
    ldx #>@str                     ; load upper byte
    jsr putstr
    lda #LF
    jsr putch
    rts

@str:
    .asciiz "Hello World!"

;-------------------------------------------------------------------------------
; Initialize the system
;-------------------------------------------------------------------------------
init_system:
    jsr clear_zp
    jsr init_acia
    jsr init_screen
    cli                 ; enable interrupts
    rts

;-------------------------------------------------------------------------------
; Clear the lower part of the zero page which is used by the BIOS
;-------------------------------------------------------------------------------
clear_zp:
    ldx #0
@next:
    stz $00,x
    inx
    bne @next
    rts

;-------------------------------------------------------------------------------
; Initialize screen
;-------------------------------------------------------------------------------
init_screen:
    lda #<@resetscroll
    ldx #>@resetscroll
    jsr putstr
    rts

@resetscroll:
    .byte ESC,"[2J",ESC,"[r",0

;-------------------------------------------------------------------------------
; Initialize I/O
;-------------------------------------------------------------------------------
init_acia:
    lda #$10		; use 8N1 with a 115200 baud
    sta ACIA_CTRL	; write to ACIA control register
    lda #%00001001  ; No parity, no echo, no interrupts.
    sta ACIA_CMD	; write to ACIA command register
    rts

;-------------------------------------------------------------------------------
; PUTSTR routine
; Garbles: A,X,Y
; Input X:A contains HB:LB of string pointer
;
; Loops over a string and print its characters until a zero-terminating character 
; is found. Assumes that $10 is used on the zero page to store the address of
; the string.
;-------------------------------------------------------------------------------
putstr:
    stx STRHB
    sta STRLB
@skip:
    ldy #0
@nextchar:
    lda (STRLB),y       ; load character from string
    beq @exit           ; if terminating character is read, exit
    jsr putch           ; else, print char
    iny                 ; increment y
    jmp @nextchar       ; read next char
@exit:
    rts

;-------------------------------------------------------------------------------
; putchar routine
;
; Converves A
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting.
; At 12 MhZ, we need to wait 1.4318E7 * 10 / 115200 / 5 = 208 clock cycles,
; where the 5 corresponds to the combination of "DEC" and "BNE" taking 5 clock
; cyles.
;
;  4.000 MHz    :  69
;  5.120 MHz    :  89
; 10.000 MHz    : 174
; 12.000 MHz    : 208 -> does not work
; 14.310 MHz    : 249 -> does not work
;-------------------------------------------------------------------------------
putch:
    pha             ; preserve A
    sta ACIA_DATA   ; write the character to the ACIA data register
    lda #89         ; initialize inner loop
@inner:
    dec             ; decrement A; 2 cycles
    bne @inner      ; check if zero; 3 cycles
    pla             ; retrieve A from stack
    rts

;-------------------------------------------------------------------------------
; Interrupt Service Routine
;
; Checks whether a character is available over the UART and stores it in the
; key buffer to be parsed later.
;-------------------------------------------------------------------------------
isr:
    pha             ; put A on stack
    lda ACIA_STAT   ; check status
    and #$08        ; check for bit 3
    beq isr_exit    ; if not set, exit isr
    lda ACIA_DATA   ; load byte
    jsr putch
isr_exit:
    pla             ; recover A
    rti

.segment "VECTORS"
    .word boot          ; reset / $FFFA
    .word boot          ; nmi / $FFFC
    .word isr           ; irq/brk / $FFFE
