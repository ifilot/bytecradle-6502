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
    LDA #%00011110
    STA ACIA_CTRL    ; Write to ACIA control register
    LDA #%11001010         ; No parity, no echo, no interrupts.
    STA ACIA_CMD
    rts
        
;-------------------------------------------------------------------------------
; MAIN routine
;-------------------------------------------------------------------------------
main:
    ldx #00
SEND_STRING:
    LDA STRING,X     ; Load the current character from the string
    BEQ exit         ; If character is null (end of string), exit
    jsr transmit
    INX              ; Increment X to point to the next character
    JMP SEND_STRING  ; Repeat for the next character

transmit:
    pha
    STA ACIA_DATA    ; Write the character to the ACIA data register
    LDA     #$FF           ; Initialize delay loop.
TXDELAY:        
    DEC                    ; Decrement A.
    BNE     TXDELAY        ; Until A gets to 0.
    PLA                    ; Restore A.
    RTS                    ; Return.

exit:
    jmp loop

    STRING:
        .BYTE "Hello World", 0  ; Null-terminated string

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