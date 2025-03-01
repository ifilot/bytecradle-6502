.export newcmdline
.export char2num
.export char2nibble
.export chartoupper
.export putds
.export putspace
.export puttab
.export ischarvalid
.export clearline

.import putch
.import putstr

.PSC02

.include "constants.inc"

.segment "CODE"

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