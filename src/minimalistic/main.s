.PSC02

.segment "CODE"

.define ACIA_DATA       $7F00  ; Transmit/Receive Data Register
.define ACIA_STAT       $7F01  ; Status Register (read) - flags like TDRE, RDRF, DCD, etc.
.define ACIA_CMD        $7F02  ; Command Register (write) - controls RTS, DTR, IRQs, etc.
.define ACIA_CTRL       $7F03  ; Control Register - sets baud rate, word length, stop bits, parity

.define ROMBANK         $7F80

; general buffer addresses (ZP), these can be used by a number of programs
; in the monitor
.define BUF1            $02
.define BUF2            $03
.define BUF3            $04
.define BUF4            $05
.define BUF5            $06
.define BUF6            $07
.define BUF7            $08
.define BUF8            $09
.define BUF9            $0A

; keyboard buffer variables
.define TBPR            $00
.define TBPL            $01
.define TB              $0200   ; store textbuffer in page 2

;-------------------------------------------------------------------------------
; Start sequence
;-------------------------------------------------------------------------------
boot:                              ; reset vector points here
    jsr init_system
    lda #'@'
    jsr putch
    lda ROMBANK
    jsr puthex
    lda #01
    sta ROMBANK
    lda ROMBANK
    jsr puthex
@loop:
    jsr getch
    cmp #0
    beq @loop
    jsr putch
    jmp @loop

;-------------------------------------------------------------------------------
; Initialize the system
;-------------------------------------------------------------------------------
init_system:
    jsr clear_zp
    jsr init_acia
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
; Initialize I/O
;-------------------------------------------------------------------------------
init_acia:
    lda #$10		; use 8N1 with a 115200 baud
    sta ACIA_CTRL	; write to ACIA control register
    lda #%00001001  ; No parity, no echo, no interrupts.
    sta ACIA_CMD	; write to ACIA command register
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
    phx
    ldx TBPR        ; load pointer index
    sta TB,x        ; store character
    inc TBPR
    plx             ; recover X
isr_exit:
    pla             ; recover A
    rti

;-------------------------------------------------------------------------------
; GETCHAR routine
;
; retrieve a char from the key buffer in the accumulator
; Garbles: A,X
;-------------------------------------------------------------------------------
getch:
    phx
    lda TBPL            ; load textbuffer left pointer
    cmp TBPR            ; load textbuffer right pointer
    beq @nokey          ; if the same, exit routine
    ldx TBPL            ; else, load left pointer
    lda TB,x            ; load value stored in text buffer
    inc TBPL
    jmp @exit
@nokey:
    lda #0
@exit:
    plx
    rts

;-------------------------------------------------------------------------------
; putchar routine
;
; Converves A
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting.
; At 12 MhZ, we need to wait 10e6 * 10 / 115200 / 7 = 124 clock cycles,
; where the 5 corresponds to the combination of "DEC" and "BNE" taking 5 clock
; cyles.
;
;  4.000 MHz    :  50
;  5.120 MHz    :  64
; 10.000 MHz    : 124
; 12.000 MHz    : 149 (works on Tiny)
; 14.310 MHz    : 177 (works on Tiny)
; 16.000 MHz    : 198 (works on Tiny)
;-------------------------------------------------------------------------------
putch:
    pha             ; preserve A
    sta ACIA_DATA   ; write the character to the ACIA data register
    lda #198        ; initialize inner loop
@inner:
    nop             ; NOP; 2 cycles
    dec             ; decrement A; 2 cycles
    bne @inner      ; check if zero; 3 cycles
    pla             ; retrieve A from stack
    rts

;-------------------------------------------------------------------------------
; PUTHEX routine
;
; Print a byte loaded in A to the screen in hexadecimal formatting
;
; Conserves:    A,X,Y
; Uses:         BUF1
;-------------------------------------------------------------------------------
puthex:
    sta BUF1
    lsr a           ; shift right; MSB is always set to 0
    lsr a
    lsr a
    lsr a
    jsr printnibble
    lda BUF1
    and #$0F
    jsr printnibble
    lda BUF1
    rts

;-------------------------------------------------------------------------------
; PRINTNIBBLE routine
;
; Print the four LSB of the value in A to the screen; assumess that the four MSB
; of A are already reset
;
; Garbles: A
;-------------------------------------------------------------------------------
printnibble:
    cmp #10
    bcs @alpha
    adc #'0'
    jmp @exit
@alpha:
    clc
    adc #'A'-10
@exit:
    jsr putch
    rts

.segment "VECTORS"
    .word boot         ; reset / $FFFA
    .word boot         ; nmi / $FFFC
    .word isr          ; irq/brk / $FFFE