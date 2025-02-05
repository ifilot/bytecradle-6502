.export newline
.export newcmdline
.export putstr
.export char2num
.export char2nibble
.export chartoupper
.export puthex
.export putds
.export putspace
.export puttab
.export printnibble
.export putchar
.export getchar

.PSC02

.include "constants.inc"

.segment "CODE"

;-------------------------------------------------------------------------------
; GETCHAR routine
;
; retrieve a char from the key buffer
;-------------------------------------------------------------------------------
getchar:
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
    rts

;-------------------------------------------------------------------------------
; NEWLINE routine
;
; GARBLES: A,X,Y
;
; print new line to the screen
;-------------------------------------------------------------------------------
newline:
    lda #>@newlinestr   ; load lower byte
    ldx #<@newlinestr   ; load upper byte
    jsr putstr
    rts
@newlinestr:
    .byte LF,0

;-------------------------------------------------------------------------------
; PUTSPACE routine
;
; print single space
;-------------------------------------------------------------------------------
putspace:
    lda #' '
    jsr putchar
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
    jsr putchar
    lda #':'
    jsr putchar
    rts

;-------------------------------------------------------------------------------
; PUTSTR routine
; Garbles: A,X,Y
; Input A:X contains HB:LB of string pointer
;
; Loops over a string and print its characters until a zero-terminating character 
; is found. Assumes that $10 is used on the zero page to store the address of
; the string.
;-------------------------------------------------------------------------------
putstr:
    sta STRHB
    stx STRLB
    ldy #0
@nextchar:
    lda (STRLB),y   ; load character from string
    beq @exit       ; if terminating character is read, exit
    jsr putchar     ; else, print char
    iny             ; increment y
    jmp @nextchar   ; read next char
@exit:
    rts

;-------------------------------------------------------------------------------
; CHAR2NUM routine
;
; convert characters stored in a,x to a single number stored in A;
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
; print a byte loaded in A to the screen in hexadecimal formatting
; Uses: BUF1
;-------------------------------------------------------------------------------
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
    adc #'A'-10
@exit:
    jsr putchar
    rts

;-------------------------------------------------------------------------------
; putchar routine
; Garbles: A
;
; Prints a character to the ACIA; note that software delay is needed to prevent
; transmitting data to the ACIA while it is still transmitting. 
; At 12 MhZ, we need to wait 1.2E7 * 10 / 115200 / 5 = 208 clock cycles, where
; the 5 corresponds to the combination of "DEC" and "BNE" taking 5 clock cyles.
;
; 10 MHz : 174
; 12 MHz : 208
;-------------------------------------------------------------------------------
putchar:
    pha             ; preserve A
    sta ACIA_DATA   ; write the character to the ACIA data register
    lda #174        ; initialize inner loop
@inner:
    dec             ; decrement A; 2 cycles
    bne @inner      ; check if zero; 3 cycles
    pla
    rts
