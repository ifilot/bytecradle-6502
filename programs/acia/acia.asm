;
; this simple program interfaces with the ACIA chip; it echoes the characters
; typed in over the UART back to the user
;

.PSC02

.define ACIA_DATA       $9F04
.define ACIA_STAT       $9F05
.define ACIA_CMD        $9F06
.define ACIA_CTRL       $9F07

.define ESC		$1B		; VT100 escape character

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
    lda #<termbootstr   ; load lower byte
    sta $10
    lda #>termbootstr   ; load upper byte
    sta $11
    jsr stringout
    jsr nlout
    rts

termbootstr:
    .byte ESC,"[2J",ESC,"[HByteCradle 6502",ESC,"[B",ESC,"[1G","ACIA echo test",0
newlinestr:
    .byte ESC,"[B",ESC,"[1G@:",0
        
;-------------------------------------------------------------------------------
; MAIN routine
;-------------------------------------------------------------------------------
main:
    jmp main


;-------------------------------------------------------------------------------
; NLOUT routine
; Garbles: X,y
;
; Moves the cursor to the next line
;-------------------------------------------------------------------------------
nlout:
    lda #<newlinestr	; load lower byte
    sta $10
    lda #>newlinestr	; load upper byte
    sta $11
    jsr stringout
    rts

;-------------------------------------------------------------------------------
; STRINGOUT routine
; Garbles: A, Y
;
; Loops over a string and print its characters until a zero-terminating character 
; is found. Assumes that $10 is used on the zero page to store the address of
; the string.
;-------------------------------------------------------------------------------
stringout:
    ldy #0
@nextchar:
    lda ($10),y		; load character from string
    beq @exit		; if terminating character is read, exit
    jsr charout		; else, print char
    iny			; increment y
    jmp @nextchar	; read next char
@exit:
    rts

;-------------------------------------------------------------------------------
; CHAROUT routine
; Garbles: A
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting. At 10 MhZ, we
; need to wait 1E7 * 10 / 19200 = 5208 clock cycles. The inner loop consumes
; 256 * 5 = 1280 cycles. Thus, we take 5 outer loops and have some margin.
;-------------------------------------------------------------------------------
charout:
    phx			; preserve X
    sta ACIA_DATA    	; write the character to the ACIA data register
    ldx #5              ; number of outer loops, see description above 
delay_outer:
    lda #$FF        	; initialize inner loop
delay_inner:        
    dec                 ; decrement A; 2 cycles
    bne delay_inner     ; check if zero; 3 cycles
    dex                 ; decrement X
    bne delay_outer
    plx
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
    cmp #$0D		; check for CR
    beq newline         ; print newline
    cmp #$7F            ; check for delete
    beq backspace	; run backspace routine
    jsr charout 	; else do normal print of character
isr_exit:
    pla			; recover A
    rti

newline:
    jsr nlout
    jmp isr_exit
   
backspace:
    lda #$08
    jsr charout
    lda #' '
    jsr charout
    lda #$08
    jsr charout
    jmp isr_exit	; exit interrupt

bsstr:
    .byte ESC,"[D ",ESC,"[D",0

;-------------------------------------------------------------------------------
; Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
    .word boot          ; reset
    .word boot          ; nmi
    .word isr           ; irq/brk
