; this code is a simple monitor class for the ByteCradle 6502

.PSC02

.define ACIA_DATA       $9F04
.define ACIA_STAT       $9F05
.define ACIA_CMD        $9F06
.define ACIA_CTRL       $9F07

; textbuffer variables
.define TBPR		$02
.define TBPL		$03
.define TB              $0200		; store textbuffer in page 2
.define CMDBUF          $0300           ; position of command buffer
.define CMDLENGTH       $0310           ; number of bytes in buffer, max 16

.define LF		$0A		; LF character (line feed)
.define ESC		$1B		; VT100 escape character

; buffer addresses (ZP)
.define BUF1		$04
.define BUF2		$05
.define BUF3		$06
.define BUF4		$07
.define	BUF5		$08
.define BUF6		$09
.define STRLB  		$10		; string low byte
.define STRHB		$11		; string high byte
.define MALB		$14		; monitor address low byte
.define MAHB		$15		; monitor address high byte

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
    stz CMDLENGTH       ; clear command length size

    jsr init_acia       ; initialize UART
    lda #<resetscroll
    sta STRLB
    lda #>resetscroll
    sta STRHB
    jsr stringout
    cli                 ; enable interrupts
    jmp main		; go to main routine

;-------------------------------------------------------------------------------
; Initialize I/O
;-------------------------------------------------------------------------------
init_acia:
    lda #$1F	        ; use 8N1 with a 19200 baud
    sta ACIA_CTRL 	; write to ACIA control register
    lda #%00001001      ; No parity, no echo, no interrupts.
    sta ACIA_CMD	; write to ACIA command register
    rts

termbootstr:
    .byte ESC,"[2J",ESC,"[H"		; reset terminal
    .byte "*******************",LF
    .byte "  ByteCradle 6502  ",LF
    .byte "  ---------------  ",LF
    .byte "  MONITOR PROGRAM  ",LF
    .byte "*******************",LF
    .byte 0				; terminating char
newlinestr:
    .byte LF,0
resetscroll:
    .byte ESC,"[r",0
        
;-------------------------------------------------------------------------------
; MAIN routine
;-------------------------------------------------------------------------------
main:
    lda #<termbootstr   ; load lower byte
    sta STRLB
    lda #>termbootstr   ; load upper byte
    sta STRHB
    jsr stringout
    jsr newcmdline

loop:
    lda TBPL		; load textbuffer left pointer
    cmp TBPR            ; load textbuffer right pointer
    beq loop            ; if the same, do nothing
    ldx TBPL		; else, load left pointer
    lda TB,x		; load value stored in text buffer
    cmp #$0D		; check for carriage return
    beq exec
    cmp #$7F		; check for delete key
    beq backspace

    ldx CMDLENGTH       ; load command length
    cpx #$10
    beq exitloop        ; refuse to store when maxbuffer
    sta CMDBUF,x        ; store in position
    jsr charout		; if not, simply print character
    inc CMDLENGTH	; increment command length
exitloop:
    inc TBPL		; increment text buffer left pointer
    jmp loop

; user has pressed RETURN: try to interpret command execute it
exec:
    jsr parsecmd	; parse the command
    stz TBPL            ; reset text buffer
    stz TBPR
    stz CMDLENGTH	; reset command length
    jsr newcmdline	; provide new command line
    jmp loop

; user has pressed backspace: remove character from command buffer
backspace:
    lda CMDLENGTH	; skip if buffer is empty
    beq exitbp
    lda #$08
    jsr charout
    lda #' '
    jsr charout
    lda #$08
    jsr charout
    dec CMDLENGTH
exitbp:
    inc TBPL
    jmp loop

;-------------------------------------------------------------------------------
; PARSECMD routine
;
; Parses the command buffer and executes the command based on the buffer
;-------------------------------------------------------------------------------
parsecmd:
    ldx #00
    lda CMDBUF,x
    cmp #'H'
    beq cmdhelloworld
    cmp #'R'
    beq cmdhexdump
    rts

cmdhelloworld:
    jsr newline
    lda #<helloworldstr
    sta STRLB
    lda #>helloworldstr
    sta STRHB
    jsr stringout
    rts

; perform a hexdump of 256 bytes to the screen starting at position indicated
; by the user
cmdhexdump:
    lda #$00
    sta MALB		; load lower byte
    lda #$C0
    sta MAHB		; load upper byte
    stz BUF2		; line counter
@nextline:
    jsr newline		; start with a new line (first segment: addr)
    lda MAHB		; load high byte of memory address
    jsr printhex	; print it
    lda MALB		; load low byte of memory address
    jsr printhex	; print it
    lda #' '		; load space
    jsr charout		; print it twice
    jsr charout
    ldy #0		; number of bytes to print (second segment)
@nextbyte:
    phy			; put y on stack as printhex garbles it
    lda (MALB),y	; load byte
    jsr printhex	; print byte in hex format, garbles y
    lda #' '		; add space
    jsr charout
    ply			; restore y from stack
    iny
    cpy #8		; check if halfway
    bne @skip		; if not, skip
    lda #' '		; print two spaces to seperate 8 bit segments
    jsr charout
    jsr charout
@skip:
    cpy #16		; check if 16 bytes are printed
    bne @nextbyte	; if not, next byte
    lda #' '		; else space
    jsr charout
    lda #'|'		; add nice delimeter
    jsr charout
    ldy #0		; number of bytes to print (third segment)
@nextchar:
    phy			; y will be garbed in charout routine
    lda (MALB),y	; load byte again
    cmp #$1F		; check if value is less than $20
    bcc @printdot	; if so, print a dot
    cmp #$7F 		; check if value is greater than or equal to $7F
    bcs @printdot	; if so, print a dot
    jmp @next
@printdot:
    lda #'.'		; load dot character
@next:
    jsr charout		; print character
    ply			; restore y
    iny
    cpy #16		; check if 16 characters have been consumed
    bne @nextchar	; if not, next character
    lda #'|'		; else print terminating char
    jsr charout
    lda MALB		; load low byte of monitor address
    clc			; prepare for add (clear carry)
    adc #16		; add 16
    sta MALB		; store in low byte
    lda MAHB		; load high byte
    adc #0		; add with carry (if there is a carry)
    sta MAHB		; store back in high byte
    inc BUF2
    lda BUF2		; load line counter
    cmp #16		; check whether 16 lines are printed
    bne @nextline	; if not, next line
    rts

helloworldstr:
    .byte "Hello World!", 0

;-------------------------------------------------------------------------------
; NEWLINE routine
;
; print new line to the screen
;-------------------------------------------------------------------------------
newline:
    lda #<newlinestr	; load lower byte
    sta STRLB
    lda #>newlinestr	; load upper byte
    sta STRHB
    jsr stringout
    rts

;-------------------------------------------------------------------------------
; NEWCMDLINE routine
; Garbles: X,y
;
; Moves the cursor to the next line
;-------------------------------------------------------------------------------
newcmdline:
    jsr newline
    lda #'@'
    jsr charout
    lda #':'
    jsr charout
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
    lda (STRLB),y	; load character from string
    beq @exit		; if terminating character is read, exit
    jsr charout		; else, print char
    iny			; increment y
    jmp @nextchar	; read next char
@exit:
    rts

;-------------------------------------------------------------------------------
; PRINTHEX routine
;
; print a byte loaded in A to the screen in hexadecimal formatting
;-------------------------------------------------------------------------------
printhex:
    sta BUF1
    lsr	a		; shift right; MSB is always set to 0
    lsr a
    lsr a
    lsr a
    jsr printnibble
    lda BUF1
    and #$0F
    jsr printnibble
    rts

;-------------------------------------------------------------------------------
; PRINTNIBBLE routine
;
; print the four LSB of the value in A to the screen; assumess that the four MSB
; of A are already reset
;-------------------------------------------------------------------------------
printnibble:
    cmp #10
    bcs @alpha
    adc #'0'
    jmp @exit
@alpha:
    clc
    adc #'a'-10
@exit:
    jsr charout
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
