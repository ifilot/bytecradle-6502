; rambank routines
.export set_rambank
.export _set_rambank
.export read_rambank
.export _read_rambank

.export newline
.export newcmdline
.export _putstr
.export putstr
.export getch
.export _getch
.export putch
.export _putch
.export _putbackspace
.export putstrnl
.export _putstrnl
.export char2num
.export char2nibble
.export chartoupper
.export puthex
.export _puthex
.export _jump
.export puthexword
.export _puthexword
.export putdec
.export putds
.export putspace
.export puttab
.export printnibble
.export ischarvalid
.export clearline

.PSC02

.include "constants.inc"

.segment "CODE"

;-------------------------------------------------------------------------------
; SET_RAMBANK routine
;
; Sets the rambank from A.
;-------------------------------------------------------------------------------
set_rambank:
_set_rambank:
    sta RAMBANK
    rts

;-------------------------------------------------------------------------------
; READ_RAMBANK routine
;
; Reads the rambank. Return value in A.
;-------------------------------------------------------------------------------
read_rambank:
_read_rambank:
    lda RAMBANK
    rts

;-------------------------------------------------------------------------------
; Execute function at address stored in A (low byte) and X (high byte)
; Preserves JSR behavior by fixing the return address manually
;-------------------------------------------------------------------------------
_jump:
    sta BUF2          ; Store low byte of function address
    stx BUF3          ; Store high byte of function address
    jmp (BUF2)        ; Indirect jump to function address (BUF1 contains target)

;-------------------------------------------------------------------------------
; GETCHAR routine
;
; retrieve a char from the key buffer in the accumulator
; Garbles: A,X
;-------------------------------------------------------------------------------
getch:
_getch:
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
; NEWLINE routine
;
; Conserves: A
;
; print new line to the screen
;-------------------------------------------------------------------------------
newline:
    sta BUF1
    lda #LF
    jsr putch
    lda BUF1
    rts

;-------------------------------------------------------------------------------
; PUTSPACE routine
;
; print single space
;-------------------------------------------------------------------------------
putspace:
    lda #' '
    jsr putch
    rts

;-------------------------------------------------------------------------------
; PUTDS routine
;
; print two spaces
;-------------------------------------------------------------------------------
putds:
    jsr putspace
    jsr putspace
    rts

;-------------------------------------------------------------------------------
; PUTTAB routine
;
; print four spaces
;-------------------------------------------------------------------------------
puttab:
    jsr putds
    jsr putds
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
    jsr putch
    lda #':'
    jsr putch
    rts

;-------------------------------------------------------------------------------
; PUTSTR routine
; Garbles: A,X,Y
; Input X:A contains HB:LB of string pointer
;
; Loops over a string and print its characters until a zero-terminating character 
; is found. Assumes that $10 is used on the zero page to store the address of
; the string.
;-------------------------------------------------------------------------------
_putstr:
putstr:
    stx STRHB
    sta STRLB
@skip:
    ldy #0
@nextchar:
    lda (STRLB),y   ; load character from string
    beq @exit       ; if terminating character is read, exit
    jsr putch      ; else, print char
    iny             ; increment y
    jmp @nextchar   ; read next char
@exit:
    rts

;-------------------------------------------------------------------------------
; PUTSTRNL routine
; Garbles: A,X,Y
; Input X:A contains HB:LB of string pointer
;
; Same as PUTSTR function, but puts a newline character at the end of the 
; string.
;-------------------------------------------------------------------------------
_putstrnl:
putstrnl:
    jsr putstr
    lda #LF
    jsr putch
    rts

;-------------------------------------------------------------------------------
; PUTBACKSPACE routine
; 
; places the cursor one position back and wipes existing character
;-------------------------------------------------------------------------------
_putbackspace:
    lda #$08
    jsr putch
    lda #' '
    jsr putch
    lda #$08
    jsr putch
    rts

;-------------------------------------------------------------------------------
; CHAR2NUM routine
;
; convert characters stored in A,X to a single number stored in A;
; sets C on an error, assume A contains high nibble and X contains low nibble
;-------------------------------------------------------------------------------
char2num:
    jsr char2nibble
    bcs @exit       ; error on carry set
    asl a           ; shift left 4 bits to create higher nibble
    asl a
    asl a
    asl a
    sta BUF1        ; store in buffer on ZP
    txa             ; transfer lower nibble from X to A
    jsr char2nibble ; repeat
    bcs @exit       ; error on carry set
    ora BUF1        ; combine nibbles
@exit:
    rts

;-------------------------------------------------------------------------------
; CHAR2NIBBLE routine
;
; convert hexcharacter stored in a to a numerical value
; sets C on an error
;-------------------------------------------------------------------------------
char2nibble:
    cmp #'0'        ; is >= '0'?
    bcc @error      ; if not, throw error 
    cmp #'9'+1      ; is > '9'?
    bcc @conv       ; if not, char between 0-9 -> convert
    cmp #'A'        ; is >= 'A'?
    bcc @error      ; if not, throw error
    cmp #'F'+1      ; is > 'F'?
    bcs @error      ; if so, throw error
    sec
    sbc #'A'-10     ; subtract
    jmp @exit
@conv:
    sec
    sbc #'0'
    jmp @exit
@error:
    sec             ; set carry
    rts
@exit:
    clc
    rts

;-------------------------------------------------------------------------------
; ISCHARVALID routine
;
; Assess whether character stored in A is printable, i.e., lies between $20 and 
; $7E (inclusive). If so, clear carry, else set the carry.
;
; Conserves: A, X, Y
;-------------------------------------------------------------------------------
ischarvalid:
    cmp #$20                ; if less than $20, set carry flag and exit
    bcc @invalid
    cmp #$7F                ; compare with $7F, comparison yields desired result
    rts
@invalid:
    sec
    rts

;-------------------------------------------------------------------------------
; CLEARLINE routine
;
; Clears the current line on the terminal
;-------------------------------------------------------------------------------
clearline:
    ldx #>@clearline
    lda #<@clearline
    jsr putstr
    rts
@clearline:
    .byte ESC, "[2K", $0D, $00

;-------------------------------------------------------------------------------
; CHARTOUPPER
;
; Convert a character in A, if lowercase, to uppercase
;-------------------------------------------------------------------------------
chartoupper:
    cmp #'a'
    bcc @notlower
    cmp #'z'+1
    bcs @notlower
    sec
    sbc #$20
@notlower:
    rts

;-------------------------------------------------------------------------------
; PUTHEX routine
;
; Print a byte loaded in A to the screen in hexadecimal formatting
;
; Conserves:    A,X,Y
; Uses:         BUF1
;-------------------------------------------------------------------------------
_puthex:
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
; PUTHEXWORD routine
;
; Prints hexword to screen
;-------------------------------------------------------------------------------
_puthexword:
puthexword:
    sta BUF2    ; low byte
    stx BUF3    ; high byte
    lda BUF3
    jsr puthex
    lda BUF2
    jsr puthex
    rts

;-------------------------------------------------------------------------------
; PUTDEC routine
;
; Print a byte loaded in A to the screen in decimal formatting. Do not prepend
; the number with any spaces nor with any zeros.
;
; Conserves:    A
; Garbles:      X,Y
; Uses:         BUF1,BUF2
;-------------------------------------------------------------------------------
putdec:
    pha                 ; put A on the stack
    ldx #1
    stx BUF2
    inx
    ldy #$40
@l1:
    sty BUF1
    lsr
@l2:
    rol
    bcs @l3
    cmp @vals,x
    bcc @l4
@l3:
    sbc @vals,x
    sec
@l4:
    rol BUF1
    bcc @l2
    tay
    cpx BUF2
    lda BUF1
    bcc @l5
    beq @l6
    stx BUF2
@l5:
    eor #$30
    jsr putch
@l6:
    tya
    ldy #$10
    dex
    bpl @l1
    pla                 ; retrieves A from the stack
    rts

@vals:
    .byte 128,160,200

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

;-------------------------------------------------------------------------------
; putchar routine
;
; Converves A
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting.
; At 12 MhZ, we need to wait 1.4318E7 * 10 / 115200 / 5 = 208 clock cycles,
; where the 5 corresponds to the combination of "DEC" and "BNE" taking 5 clock
; cyles.
;
;  4.000 MHz    :  69
;  5.120 MHz    :  89
; 10.000 MHz    : 174
; 12.000 MHz    : 208 -> does not work
; 14.310 MHz    : 249 -> does not work
;-------------------------------------------------------------------------------
putch:
_putch:
    pha             ; preserve A
    sta ACIA_DATA   ; write the character to the ACIA data register
    lda #89         ; initialize inner loop
@inner:
    dec             ; decrement A; 2 cycles
    bne @inner      ; check if zero; 3 cycles
    pla             ; retrieve A from stack
    rts