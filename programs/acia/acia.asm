;
; This code initializes PORTA and alternates the pins twice per second. This
; is achieved by setting a timer that produces an interrupt every 10ms. A TIMER
; counter is used to count 50 of these interrupts upon which the pins on PORTA
; are XOR'ed with $FF.
;

.PSC02

.define ACIA_DATA       $9F04
.define ACIA_ST         $9F05
.define ACIA_CMD        $9F06
.define ACIA_CTRL       $9F07

.segment "CODE"

;-------------------------------------------------------------------------------
; Boot sequence
;-------------------------------------------------------------------------------
boot:                   ; reset vector points here
    sei                 ; disable interrupts
    cld                 ; clear decimal mode 
    ldx #$ff            ; initialize stack pointer to top of stack
    txs                 ; transfer x to stack pointer (sp)
    ldx #$00            ; prepare to clear the zero page
    lda #$00            ; clear a register
clear_zp:
    sta $00,x           ; clear zero page by storing 0
    inx                 ; increment y
    bne clear_zp        ; loop until x overflows back to 0

    jsr init            ; initialize VIAs
    jmp main

;-------------------------------------------------------------------------------
; Initialize I/O
;-------------------------------------------------------------------------------
init:
    lda #%00011110
    sta ACIA_CTRL 	; Write to ACIA control register
    lda #%11001010      ; No parity, no echo, no interrupts.
    sta ACIA_CMD
    rts
        
;-------------------------------------------------------------------------------
; MAIN routine
;-------------------------------------------------------------------------------
main:
    ldx #00
nextchar:
    lda string,x     	; Load the current character from the string
    beq exit         	; if character is null (end of string), exit
    jsr transmit        ; transmit byte over serial
    inx              	; increment X to point to the next character
    jmp nextchar  	; repeat for the next character

transmit:
    pha
    sta ACIA_DATA    	; Write the character to the ACIA data register
    lda #$FF        	; Initialize delay loop.
txdelay:        
    dec                 ; decrement A.
    bne txdelay         ; until A gets to 0.
    pla                 ; restore A.
    rts

exit:
    jmp loop

    string:
        .byte $1B, $5B, $31, $3B, $31, $3B, $34, $6D, "The Quick Brown Fox Jumps Over The Lazy Dog!", 0  ; Null-terminated string

;-------------------------------------------------------------------------------
; Infinite loop
;-------------------------------------------------------------------------------
loop:
    jmp loop

;-------------------------------------------------------------------------------
; Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
    .word boot          ; reset
    .word boot          ; nmi
    .word boot          ; irq/brk
