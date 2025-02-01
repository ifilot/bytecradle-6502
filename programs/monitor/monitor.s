;-------------------------------------------------------------------------------
; MAIN MONITOR
;-------------------------------------------------------------------------------

.include "constants.inc"

.include "functions.inc"

.segment "CODE"

;-------------------------------------------------------------------------------
; Boot sequence
;-------------------------------------------------------------------------------
boot:                   ; reset vector points here
    sei                 ; disable interrupts
    cld                 ; clear decimal mode 

    ldx #$ff            ; initialize stack pointer to top of stack
    txs                 ; transfer x to stack pointer (sp)

    cli                 ; enable interrupts and fall to main
        
;-------------------------------------------------------------------------------
; MAIN routine
;
; Consumes the text buffer and executes commands when a RETURN is entered.
; Previous text can be removed using BACKSPACE
;-------------------------------------------------------------------------------
main:
    jsr init            ; initialize system and fall to loop

loop:
    lda TBPL		    ; load textbuffer left pointer
    cmp TBPR            ; load textbuffer right pointer
    beq loop            ; if the same, do nothing
    ldx TBPL		    ; else, load left pointer
    lda TB,x		    ; load value stored in text buffer
    jsr chartoupper	    ; always convert character to upper case
    cmp #$0D		    ; check for carriage return
    beq exec
    cmp #$7F		    ; check for delete key
    beq backspace

    ldx CMDLENGTH       ; load command length
    cpx #$10
    beq exitloop        ; refuse to store when maxbuffer
    sta CMDBUF,x        ; store in position
    jsr charout		    ; if not, simply print character
    inc CMDLENGTH	    ; increment command length
exitloop:
    inc TBPL		    ; increment text buffer left pointer
    jmp loop

; user has pressed RETURN: try to interpret command execute it
exec:
    jsr parsecmd	    ; parse the command
    stz TBPL            ; reset text buffer
    stz TBPR
    stz CMDLENGTH	    ; reset command length
    jsr newcmdline	    ; provide new command line
    jmp loop

; user has pressed backspace: remove character from command buffer
backspace:
    lda CMDLENGTH	    ; skip if buffer is empty
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
    cmp #'B'
    beq cmdchrambank	; change ram bank?
    cmp #'M'
    beq cmdshowmenu	; show the menu?
    cmp #'R'
    beq cmdrunfar	; run program?
    jsr hex4
    lda BUF2		; load high byte
    sta STARTADDR+1	; store in memory
    lda BUF3		; load low byte
    sta STARTADDR	; store in memory
    bcs errorhex	; try to parse the first four chars as 16-byte hex
    lda CMDBUF,X
    cmp #'.'
    beq cmdreadfar
    cmp #':'
    beq cmdwritefar
    jmp errorhex
    rts

errorhex:
    jsr newline
    lda #<@errorstr
    sta STRLB
    lda #>@errorstr
    sta STRHB
    jsr stringout
    rts

@errorstr:
    .asciiz "Error parsing hex address"

; jump table because instructions lie further in memory than +/- 128 bytes
cmdrunfar:
    jmp cmdrun

cmdreadfar:
    jmp cmdread

cmdwritefar:
    jmp cmdwrite

; change ram bank
cmdchrambank:
    rts

@str:
    .asciiz "Changing RAM bank to: "

; show a menu to the user
cmdshowmenu:
    jsr newline
    lda #<@str
    sta STRLB
    lda #>@str
    sta STRHB
    jsr stringout
    rts

@str:
    .byte LF,"Commands:",LF,LF
    .byte "  XXXX.[XXXX]         list memory contents",LF
    .byte "  XXXX: XX [XX]       change memory contents ",LF
    .byte "  R XXXX              run from address",LF
    .byte "  B XX                change RAM bank",LF
    .byte "  M                   show this menu",LF
    .byte 0

; run program starting at address
cmdrun:
    rts

cmdread:
    inx
    jsr hex4
    lda BUF2		; load high byte
    sta ENDADDR+1	; store in memory
    lda BUF3		; load low byte
    sta ENDADDR		; store in memory
    bcs @error
    jsr hexdump
    rts

@error:
    jmp errorhex

cmdwrite:
    rts

;-------------------------------------------------------------------------------
; HEX4 routine
;
; Try to convert 4 characters to a 16 bit hexadecimal address
; Store high byte in BUF2 and low byte in BUF3
;
;-------------------------------------------------------------------------------
hex4:
    jsr hex42
    bcs @exit
    sta BUF2
    inx
    inx
    jsr hex42
    bcs @exit
    sta BUF3
    inx
    inx
@exit:
    rts

hex42:
    phx
    lda CMDBUF,x	; load high byte
    tay
    inx
    lda CMDBUF,x	; load low byte
    tax
    tya
    jsr char2num
    plx
    rts

;-------------------------------------------------------------------------------
; HEXDUMP routine
;
;-------------------------------------------------------------------------------
hexdump:
    ; setup variables
    lda STARTADDR	; set start address
    sta MALB
    lda STARTADDR+1
    sta MAHB
    
    ; calculate the number of lines to be printed
    sec			; clear carry flag before starting subtraction
    lda ENDADDR		; load low byte of end address
    sbc STARTADDR	; subtract low byte of end address
    sta NRLINES
    lda ENDADDR+1	; load high byte
    sbc	STARTADDR+1	; subtract low byte
    sta NRLINES+1

    ; divide the result by 16, which is the number of lines that are going
    ; to be printed
    and #$0F		; take low nibble to transfer to low byte
    asl			; shift left by 4
    asl
    asl
    asl
    sta BUF1		; store temporarily
    lda NRLINES		; load low nibble
    lsr
    lsr
    lsr
    lsr
    ora BUF1		; place upper nibble
    sta NRLINES		; store in low byte
    lda NRLINES+1
    lsr
    lsr
    lsr
    lsr
    sta NRLINES+1	; store
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
    cmp #$7F		; check if value is greater than or equal to $7F
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
    lda NRLINES
    ora NRLINES+1
    beq @exit		; if zero, then exit, else decrement
    lda NRLINES
    sec			; set carry flag for subtraction
    sbc #1		; subtract 1 from low byte of NRLINES
    sta NRLINES		; store
    bcs @nextlinefar	; if carry set, no borrow and continue
    dec NRLINES+1
@nextlinefar:
    jmp @nextline
@exit:
    rts

;-------------------------------------------------------------------------------
; Vectors
;-------------------------------------------------------------------------------
.segment "VECTORS"
    .word boot          ; reset
    .word boot          ; nmi
    .word isr           ; irq/brk
