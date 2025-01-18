;
; This code initializes PORTA and alternates the pins twice per second. This
; is achieved by setting a timer that produces an interrupt every 10ms. A TIMER
; counter is used to count 50 of these interrupts upon which the pins on PORTA
; are XOR'ed with $FF.
;

.PSC02

.define ACIA_DATA       $9F04
.define ACIA_STAT       $9F05
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
    cli                 ; enable interrupts
    jmp main

;-------------------------------------------------------------------------------
; Initialize I/O
;-------------------------------------------------------------------------------
init:
    lda #$1E	        ; use 8N1 with a 9600 baud
    sta ACIA_CTRL 	; Write to ACIA control register
    lda #%00001001      ; No parity, no echo, no interrupts.
    sta ACIA_CMD
    lda #'@'            ; print '@' on boot
    jsr charout
    lda #':'
    jsr charout
    rts
        
;-------------------------------------------------------------------------------
; MAIN routine
;-------------------------------------------------------------------------------
main:
    jmp main

charout:
    sta ACIA_DATA    	; Write the character to the ACIA data register
    lda #$FF        	; Initialize delay loop.
txdelay:        
    dec                 ; decrement A.
    bne txdelay         ; until A gets to 0.
    rts

;-------------------------------------------------------------------------------
; Infinite loop
;-------------------------------------------------------------------------------
loop:
    jmp loop

;-------------------------------------------------------------------------------
; interrupt service routine
;-------------------------------------------------------------------------------
isr:
    pha			; put A on stack
    lda ACIA_STAT	; check status
    and #$08		; check for bit 3
    beq isr_exit	; if not set, exit isr
    lda ACIA_DATA	; else transmit the byte back
    jsr charout 
isr_exit:
    pla			; recover A
    rti

;-------------------------------------------------------------------------------
; Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
    .word boot          ; reset
    .word boot          ; nmi
    .word isr           ; irq/brk
