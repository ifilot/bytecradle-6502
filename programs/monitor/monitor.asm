; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.define ACIA_DATA       $9F04
.define ACIA_STAT       $9F05
.define ACIA_CMD        $9F06
.define ACIA_CTRL       $9F07

; textbuffer variables
.define TBPR		$12
.define TBPL		$13
.define TB              $0200		; store textbuffer in page 2

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
@nextbyte:
    stz $00,x           ; clear zero page by storing 0
    stz TB,x            ; clear textbuffer by storing 0
    inx                 ; increment x
    bne @nextbyte       ; loop until x overflows back to 0
    stz TBPL            ; reset textbuffer left pointer
    stz TBPR		; reset textbuffer right pointer

    jsr init            ; initialize UART
    cli                 ; enable interrupts
    jmp main		; go to main routine

;-------------------------------------------------------------------------------
; Initialize I/O
;-------------------------------------------------------------------------------
init:
    lda #$1F	        ; use 8N1 with a 19200 baud
    sta ACIA_CTRL 	; write to ACIA control register
    lda #%00001001      ; No parity, no echo, no interrupts.
    sta ACIA_CMD	; write to ACIA command register
    rts

termbootstr:
    .byte ESC,"[2J",ESC,"[HByteCradle 6502",ESC,"[B",ESC,"[1G","ACIA echo test",0
newlinestr:
    .byte ESC,"[B",ESC,"[1G@:",0
        
;-------------------------------------------------------------------------------
; MAIN routine
;-------------------------------------------------------------------------------
main:
    lda #<termbootstr   ; load lower byte
    sta $10
    lda #>termbootstr   ; load upper byte
    sta $11
    jsr stringout
    jsr nlout

loop:
    lda TBPL		; load textbuffer left pointer
    cmp TBPR            ; load textbuffer right pointer
    beq loop            ; if the same, do nothing
    ldx TBPL		; else, load left pointer
    lda TB,x		; load value stored in text buffer
    ;cmp #$0D		; check for carriage return
    ;beq exec
    jsr charout		; if not, simply print character
    inc TBPL            ; increment left pointer
    jmp loop

exec:
    jmp loop

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
; interrupt service routine
;-------------------------------------------------------------------------------
isr:
    pha			; put A on stack
    lda ACIA_STAT	; check status
    and #$08		; check for bit 3
    beq isr_exit	; if not set, exit isr
    lda ACIA_DATA	; load byte
    phx
    ldx TBPR		; load pointer index
    sta TB,x            ; store character
    inc TBPR
    plx			; recover X
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
