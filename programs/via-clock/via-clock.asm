;
; This code initializes PORTA and alternates the pins twice per second. This
; is achieved by setting a timer that produces an interrupt every 10ms. A TIMER
; counter is used to count 50 of these interrupts upon which the pins on PORTA
; are XOR'ed with $FF.
;

.define VIA     $3000
.define PORTB   VIA+$00
.define PORTA   VIA+$01
.define DDRB    VIA+$02
.define DDRA    VIA+$03
.define T1LL    VIA+$04
.define T1LH    VIA+$05
.define ACR     VIA+$0B
.define T1ID    VIA+$0D
.define T1IE    VIA+$0E

.define TIMER   $00
.define TINT    $4E1F

.segment "CODE"

;-------------------------------------------------------------------------------
; Boot sequence
;-------------------------------------------------------------------------------
boot:                   ; reset vector points here
    sei                 ; disable interrupts
    cld                 ; clear decimal mode (optional for 65c02, but good practice)
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
    lda #$ff
    sta DDRA            ; set data direction to output
    lda #%11000000      
    sta T1IE            ; set interrupt enable flag for T1 timer
    lda #$40
    sta ACR             ; set continuous interrupts
    lda #<TINT          ; load low byte
    sta T1LL            ; store in T1 low counter
    lda #>TINT          ; load high byte
    sta T1LH            ; store in T1 high counter
    lda #50             ; initialize timer
    sta TIMER           ; store on zero page
    cli                 ; clear interrupt flag
    rts
        
;-------------------------------------------------------------------------------
; MAIN routine
;-------------------------------------------------------------------------------
main:
    lda #$55            
    sta PORTA           ; output 0x55 on PORTA
    jmp loop            ; go to infinite loop

;-------------------------------------------------------------------------------
; Infinite loop
;-------------------------------------------------------------------------------
loop:
    jmp loop

;-------------------------------------------------------------------------------
; IRQ routine
;-------------------------------------------------------------------------------
irqhandler:
    dec TIMER           ; decrement counter timer
    bne exitirq         ; not equal to zero
    lda PORTA           ; load value on PORTA
    eor #$FF            ; XOR value
    sta PORTA           ; store back on PORTA
    lda #50             ; reset timer
    sta TIMER

exitirq:
    lda #$40            ; Load mask for T1IF (bit 6)
    sta T1ID            ; Clear T1IF in IFR
    rti

;-------------------------------------------------------------------------------
; Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
    .word boot          ; reset
    .word boot          ; nmi
    .word irqhandler    ; irq/brk