.export newline
.export putstr
.export getch
.export putch
.export putstrnl
.export char2num
.export char2nibble
.export chartoupper
.export puthex
.export puthexword
.export putdec
.export putdecword
.export putds
.export putspace
.export puttab
.export putbackspace
.export printnibble
.export ischarvalid
.export ischarnum
.export clearline
.export clearscreen
.export putcursor
.export strlen
.export putrepch
.export delayms10
.export clearcmdbuf

.PSC02

.include "constants.inc"

.segment "CODE"

;-------------------------------------------------------------------------------
; CLEANCMDBUF routine
;
; Clean the command buffer
;-------------------------------------------------------------------------------
clearcmdbuf:
    ldx #0
@next:
    stz CMDBUF,x
    inx
    cpx #10
    bne @next
    stz CMDLENGTH
    stz TBPL            ; reset text buffer
    stz TBPR
    rts

;-------------------------------------------------------------------------------
; GETCHAR routine
;
; retrieve a char from the key buffer in the accumulator
; Garbles: A
;-------------------------------------------------------------------------------
getch:
    phx                 ; put X on stack
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
    plx                 ; restore X
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
    lda #CR
    jsr putch
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
; PUTSTR routine
; Garbles: A,X,Y
; Input X:A contains HB:LB of string pointer
;
; Loops over a string and print its characters until a zero-terminating character 
; is found. Assumes that STRLB is used on the zero page to store the address of
; the string.
;-------------------------------------------------------------------------------
putstr:
    stx STRHB
    sta STRLB
@skip:
    ldy #0
@nextchar:
    lda (STRLB),y   ; load character from string
    beq @exit       ; if terminating character is read, exit
    jsr putch       ; else, print char
    iny             ; increment y
    jmp @nextchar   ; read next char
@exit:
    rts

;-------------------------------------------------------------------------------
; STRLEN routine
; Garbles: A,X,Y
; Input X:A contains HB:LB of string pointer
;
; Assumes that the string is smaller than 256 bytes
;
; Counts the number of bytes in a string and stores this in A
; Use BUF1 and BUF2 as temporary variables
;-------------------------------------------------------------------------------
strlen:
    sta BUF1                ; store low byte into temp pointer
    stx BUF2                ; store high byte into temp pointer
    ldy #0                  ; start index at 0
@count_loop:
    lda (BUF1),y            ; load (pointer),Y
    beq @done               ; if zero, end of string
    iny                     ; next character
    bne @count_loop         ; loop (max 255 characters)
@done:
    tya                     ; move count to A
    rts

;-------------------------------------------------------------------------------
; PUTREPCH routine
; Garbles: X
; Input: A - character to repeat
;        X - number of times to repeat character
;-------------------------------------------------------------------------------
putrepch:
    jsr putch
    dex
    cpx #0
    bne putrepch
    rts

;-------------------------------------------------------------------------------
; PUTSTRNL routine
; Garbles: A,X,Y
; Input X:A contains HB:LB of string pointer
;
; Same as PUTSTR function, but puts a newline character at the end of the 
; string.
;-------------------------------------------------------------------------------
putstrnl:
    jsr putstr
    lda #CR
    jsr putch
    lda #LF
    jsr putch
    rts

;-------------------------------------------------------------------------------
; DELAYMS10 routine
;
; Input A - Delay in increments of 10ms, i.e. A=50 -> 500ms delay
; Garbles: A,X,Y
; Uses: BUF1 to store delay value
;
; Note: actual delay per value of A is 9.9796 ms (~0.2% error)
;-------------------------------------------------------------------------------
delayms10:
    sta BUF1            ; store delay value in BUF1
@delayouter:
    ldx #125
@delay_x:
    ldy #$FF
@delay_y:
    dey
    bne @delay_y
    dex
    bne @delay_x
    dec BUF1            ; decrement delay value
    bne @delayouter
    rts

;-------------------------------------------------------------------------------
; PUTBACKSPACE routine
; 
; places the cursor one position back and wipes existing character
;-------------------------------------------------------------------------------
putbackspace:
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
; ISCHARNUM routine
;
; Assess whether character stored in A is a decimal numerical value, i.e., lies between $'0' and 
; $'9' (inclusive, $':' is character after $'9'). If so, clear carry, else set the carry.
;
; Conserves: A, X, Y
;-------------------------------------------------------------------------------
ischarnum:
    cmp #'0'               ; if less than $'0', set carry flag and exit
    bcc @invalid
    cmp #':'               ; compare with $':', comparison yields desired result
    rts
@invalid:
    sec
    rts

;-------------------------------------------------------------------------------
; CLEARLINE routine
;
; Clears the current line on the terminal
;
; Garbles: A, X, Y
;-------------------------------------------------------------------------------
clearline:
    lda #<@str
    ldx #>@str
    jsr putstr
    rts
@str:
    .byte ESC, "[2K", $0D, $00      ; ANSI code for clear line

;-------------------------------------------------------------------------------
; CLEARSCREEN routine
;
; Clears the screen
;
; Garbles: A, X, Y
;-------------------------------------------------------------------------------
clearscreen:
    lda #<@str
    ldx #>@str
    jsr putstr
    rts
@str:
    .byte ESC,"[2J", $1B,"[H", 0

;-------------------------------------------------------------------------------
; PUTCURSOR routine
;
; Sets the cursor at row A and column X
;
; BUF3: column
; BUF4: row
;-------------------------------------------------------------------------------
putcursor:
    sta BUF3
    stx BUF4
    lda #ESC
    jsr putch
    lda #'['
    jsr putch
    lda BUF3
    jsr putdec
    lda #';'
    jsr putch
    lda BUF4
    jsr putdec
    lda #'H'
    jsr putch
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
; Print a byte loaded in A to the screen in hexadecimal formatting
;
; Conserves:    A,X,Y
; Uses:         BUF1
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
    lda BUF1
    rts

;-------------------------------------------------------------------------------
; PUTHEXWORD routine
;
; Prints hexword to screen
;-------------------------------------------------------------------------------
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
; PUTDECWORD routine
;
; Print a word loaded in A,X to the screen in decimal formatting. Do not prepend
; the number with any spaces nor with any zeros. A should contain lower byte,
; X contains upper byte
;
; Conserves:    A
; Garbles:      X,Y
; Uses:         BUF1,BUF2,BUF3,BUF4,BUF5,BUF6,BUF7
;-------------------------------------------------------------------------------
putdecword:
    sta BUF2
    stx BUF3
    ora BUF3
    beq @printzero      ; early exit if value is zero
    sed                 ; enable decimal mode
    stz BUF4
    stz BUF5
    stz BUF6
    ldx #16
@loop:
    asl BUF2
    rol BUF3
    lda BUF4
    adc BUF4
    sta BUF4
    lda BUF5
    adc BUF5
    sta BUF5
    lda BUF6
    adc BUF6
    sta BUF6
    dex
    bne @loop
    cld                     ; revert back to hexadecimal mode
    stz BUF2                ; re-purpose BUF2 for clear prepend-0 flag
    lda BUF6
    jsr @printdecbyte
    lda BUF5
    jsr @printdecbyte
    lda BUF4
    jsr @printdecbyte
    rts

@printzero:
    lda #'0'
    jsr putch
    rts

@printdecbyte:
    pha                     ; store digit
    lsr a
    lsr a
    lsr a
    lsr a
    jsr @printdecnibble     ; print upper nibble if not prepending zero
    pla
    and #$0F
    jsr @printdecnibble     ; print lower nibble if not prepending zero
    rts

@printdecnibble:
    tax
    ora BUF2
    beq @exit
    txa
    jsr printnibble
    lda #1
    sta BUF2
@exit:
    rts

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
; At 12 MhZ, we need to wait 12e6 * 10 / 115200 / 7 = 149 clock cycles,
; where the 5 corresponds to the combination of "DEC" and "BNE" taking 5 clock
; cyles.
;
;  4.000 MHz    :  50
;  5.120 MHz    :  64
; 10.000 MHz    : 124
; 12.000 MHz    : 149
;-------------------------------------------------------------------------------
putch:
    pha             ; preserve A
    sta ACIA_DATA   ; write the character to the ACIA data register
    lda #149        ; initialize inner loop
@inner:
    nop             ; NOP; 2 cycles
    dec             ; decrement A; 2 cycles
    bne @inner      ; check if zero; 3 cycles
    pla             ; retrieve A from stack
    rts