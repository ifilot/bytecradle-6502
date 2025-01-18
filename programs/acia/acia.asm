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
    lda #$1F	        ; use 8N1 with a 19200 baud
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


;-------------------------------------------------------------------------------
; CHAROUT routine
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting. At 10 MhZ, we
; need to wait 1E7 * 10 / 19200 = 5208 clock cycles. The inner loop consumes
; 256 * 5 = 1280 cycles. Thus, we take 5 outer loops and have some margin.
;-------------------------------------------------------------------------------
charout:
    sta ACIA_DATA    	; write the character to the ACIA data register
    ldx #5              ; number of outer loops, see description above 
delay_outer:
    lda #$FF        	; initialize inner loop
delay_inner:        
    dec                 ; decrement A; 2 cycles
    bne delay_inner     ; check if zero; 3 cycles
    dex                 ; decrement X
    bne delay_outer
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
