.include "constants.inc"
.include "functions.inc"

.import optcodes
.import mnemonics
.import disassembleline
.import printhexvals

.export assemble

;-------------------------------------------------------------------------------
; ASSEMBLE routine
;-------------------------------------------------------------------------------
assemble:
    lda #>@str1
    ldx #<@str1
    jsr putstrnl
    lda #>@str2
    ldx #<@str2
    jsr putstrnl
@nextinstruction:
    stz BUF2                ; clear buffer
    stz BUF3
    stz BUF4
    jsr clearbuffer

    ; print address
    jsr puttab
    lda STARTADDR+1
    jsr puthex
    lda STARTADDR
    jsr puthex
    lda #':'
    jsr putchar
    lda #' '
    jsr putchar
    ldy #0

    ; fill the command buffer
@retr:
    jsr getchar
    beq @retr
    cmp #$0D                ; check for enter
    beq @exec
    cmp #$7F                ; check for delete key
    beq @backspace
    cpy #$10                ; check if buffer is full
    beq @retr               ; do not store
    jsr chartoupper
    sta CMDBUF,y            ; store in buffer
    iny
    jsr putchar
    inc CMDLENGTH
    jmp @retr
@backspace:
    cpy #0
    beq @retr
    lda #$08
    jsr putchar
    lda #' '
    jsr putchar
    lda #$08
    jsr putchar
    dey
    dec CMDLENGTH
    jmp @retr

    ; parse the command buffer
@exec:
    lda CMDLENGTH
    cmp #0
    beq @exit
    jsr findmnemonic
    bcs @tryagain           ; let user try again on error
    
    ; store everything
    ldy #0
    lda BUF7                ; load opt code
    sta (STARTADDR),y       ; store opt code
    lda NRCHARS             ; grab number of chars
    lsr                     ; divide by 2
    sta BUF8
    cmp #0                  ; no operands to save?
    beq @skip               ; if so, skip
    iny
    lda BUF2                ; else store BUF2
    sta (STARTADDR),y
    lda BUF8                ; load number of operands to save
    cmp #1                  ; was this all?
    beq @skip               ; if so, skip
    iny
    lda BUF3                ; else store BUF3
    sta (STARTADDR),y
@skip:
    jsr disassembleline
    jsr printhexvals

    ; increment address pointer
    lda STARTADDR
    clc
    adc BUF8
    sta STARTADDR
    lda STARTADDR+1
    adc #0
    sta STARTADDR+1

@tryagain:
    jsr newline
    jsr clearbuffer
    jmp @nextinstruction
@exit:
    rts

@str1:
    .asciiz " > Enabling INLINE ASSEMBLER. Enter assembly language instructions."
@str2:
    .asciiz " > Hit RETURN on an empty line to exit."

;-------------------------------------------------------------------------------
; FINDMNEMONIC routine
;
; Finds jump address to handle a particular mnemonic, stores mnemonic dataset
; address in BUF4:5, BUF2:3 is used as a pointer to the mnemonics dataset
;-------------------------------------------------------------------------------
findmnemonic:
    lda #<mnemonics         ; load lower byte
    sta BUF2                ; store in pointer
    lda #>mnemonics         ; load upper byte
    sta BUF3                ; store in pointer
    ldx #0                  ; mnemonic search counter
@nextmnemonic:
    ldy #0                  ; character counter
@nextchar:
    lda CMDBUF,y            ; load character from buffer
    cmp (BUF2),y            ; compare with mnemonic from table
    bne @prepnext           ; if not the same, skip to next mnemonic
    iny                     ; if the same, increment y
    cpy #3                  ; are we at the fourth character?
    bne @nextchar           ; if not, proceed

    ; perform special check for fourth character
    lda (BUF2),y
    cmp #' '                ; check if space
    bne @check              ; if not, explicitly check fourth character for match
    lda CMDBUF,y            ; if not, load character from command buffer
    cmp #' '                ; is it a space?
    beq @proceed            ; OK, proceed
    cmp #0                  ; is it unset? (for 3-char implied opt codes)
    beq @proceed            ; OK, proceed
    jmp @prepnext           ; neither, this is not the opt code we are looking for
@check:
    cmp CMDBUF,y            ; explicitly check for a match
    bne @prepnext           ; this is not the optcode we are looking for

    ; a match has been found; set the pointer to the mnemonic dataset at BUF4:5
@proceed:
    iny                     ; go to fifth byte
    lda (BUF2),y            ; load lower byte address
    sta BUF4                ; store in buffer
    iny                     ; go to sixth byte
    lda (BUF2),y            ; load upper byte address
    sta BUF5                ; store in buffer

    jsr getmode             ; mode in BUF6, optcode in BUF7
    bcs @error
    jsr grabaddress         ; grab address
    bcs @error
    jmp @exit
@exit:
    clc
    rts
@prepnext:                  ; nothing found, increment search pointer by 6
    clc
    lda BUF2
    adc #6
    sta BUF2
    lda BUF3
    adc #0
    sta BUF3
    inx
    cpx #98                 ; check whether we checked for all mnemonics
    beq @error              ; if so, throw an error
    jmp @nextmnemonic       ; if not, continue
    rts

@error:
    lda #>@errorstr         ; load lower byte
    ldx #<@errorstr         ; load upper byte
    jsr putstr
    sec
    rts
@errorstr:
    .asciiz "    Invalid entry, please try again."

;-------------------------------------------------------------------------------
; GETMODE routine
; 
; Establish addressing mode (see list below) and store result in X
; IMPORTANT: - a return value of $00 needs also be checked for with $04
;            - a return vlaue of $FF means no addressing mode could be
;              established
; This function automatically continues to getoptcode to retrieve the optcode.
; At the end of this function, the following ZP addresses are set:
; BUF6: address mode
; BUF7: opt code 
;
; List of modes (first stored in X, then in BUF6)
; $00: implicit
; $01: absolute
; $02: absolutex
; $03: absolutey
; $04: accumulator
; $05: immediate
; $06: indirectx
; $07: indirecty
; $08: indirect
; $09: relative
; $0A: zeropage
; $0B: zeropagex
; $0C: zeropagey
; $0D: indirectzeropage
; $0E: absoluteindexedindirect
; $0F: zeropagerelative
;-------------------------------------------------------------------------------
getmode:
    lda CMDLENGTH           ; check buffer length
    cmp #5                  ; check if 5 or more
    bcc @setimplied         ; if no more than 4 characters, assume implied
    ldy #3                  ; set offset
@next:                      ; first consume all spaces
    iny
    lda CMDBUF,y            ; read next character from command buffer
    cmp #' '                ; check if space
    beq @next
    cmp #0                  ; check if there is no non-zero byte
    beq @setimplied         ; if so, assume implied addressing
    cmp #'#'                ; check for '#' sign
    beq @setimmediate       ; if so, immediate addressing
    cmp #'('                ; check for one of the indirect modes
    beq @checkindirect
    jmp @checkabsolute      ; try absolute addressing modes
@setimplied:
    ldx #$00                ; set implied
    jmp getoptcode
@setimmediate:
    ldx #$05                ; set immediate
    jmp getoptcode
@checkindirect:
    iny
    iny
    iny
    lda CMDBUF,y
    cmp #')'                ; check for indirect
    beq @checkzpindirect    ; closing parenthesis, thus indirect
    cmp #','                ; check for indexed indirect
    beq @checkindexindirect
    iny
    iny
    lda CMDBUF,y            ; check for regular indirect
    cmp #')'
    beq @setindirect        ; regular indirect
@setindirect:
    ldx #$08                ; indirect (no indexing)
    jmp getoptcode
@checkzpindirect:
    iny
    lda CMDBUF,y
    cmp #','                ; is there a comma?
    bne @error              ; if not, throw error
    iny
    lda CMDBUF,y            ; is  Y?
    cmp #'Y'
    beq @setzpindirecty
    jmp @error
@checkindexindirect:
    iny
    lda CMDBUF,y
    cmp #'X'
    bne @error
    iny
    lda CMDBUF,y
    cmp #')'
    bne @error
    ldx #$06                ; set indexed indirect
    jmp getoptcode
@setzpindirecty:
    ldx #$07                ; zeropage relative
    jmp getoptcode
@error:
    jmp @exiterror
@checkabsolute:
    iny
    iny
    lda CMDBUF,y
    cmp #0
    beq @setzp
    cmp #','
    bne @notzeropage
    iny
    lda CMDBUF,y
    cmp #'X'
    beq @setzpx
    cmp #'Y'
    beq @setzpy
    jmp @error              ; script should never get here
@setzp:
    ldx #$0A                ; zeropage
    jmp getoptcode
@setzpx:
    ldx #$0B                ; zeropage, x-indexed
    jmp getoptcode
@setzpy:
    ldx #$0C                ; zeropage, y-indexed
    jmp getoptcode
@notzeropage:
    iny
    iny
    lda CMDBUF,y
    cmp #0                  ; end of command?
    beq @setabs             ; set absolute addressing mode
    cmp #','                ; is there a comma?
    bne @exiterror          ; if not, then invalid command
    iny
    lda CMDBUF,y            ; load next character
    cmp #'X'                ; is it X?
    beq @setabsx            ; absolute mode with x-indexing
    cmp #'Y'                ; it is Y?
    beq @setabsy            ; absolute mode with y-indexing
    jmp @exiterror          ; else invalid mode
@setabs:
    ldx #$01                ; absolute addressing
    jmp getoptcode
@setabsx:
    ldx #$02                ; absolute addressing with x-indexing
    jmp getoptcode
@setabsy:
    ldx #$03                ; absolute addressing with y-indexing
    jmp getoptcode
@exiterror:
    sec
    ldx #$FF                ; could not establish addressing mode, quit
    stx BUF6
    ldx #$00
    stx BUF7
    rts

;-------------------------------------------------------------------------------
; GRABADDRESS routine
;
; Try to grab the address or value from the command buffer, store the result
; in BUF2: lower byte, BUF3: upper byte
;-------------------------------------------------------------------------------
grabaddress:
    ldy #0
    stz BUF2
    stz BUF3
    stz NRCHARS

    ; check if mode is 0 or 4; if so, early exit
    lda BUF6
    cmp #00                 ; check implied
    beq @exit               ; if so, early exit
    cmp #04                 ; check accumulator
    beq @exit               ; if so, early exit
    ; if not, try to grab characters
@findspace:                 ; search till first space is found
    iny
    lda CMDBUF,y
    cmp #' '
    bne @findspace
    iny
@next:                      ; consume all hexvalues
    lda CMDBUF,y
    cmp #0
    beq @parse
    jsr ishex
    bcs @skip
    ldx NRCHARS
    sta CHAR1,x
    inx
    stx NRCHARS
    cpx #4
    beq @parse
@skip:
    iny
    jmp @next
@parse:
    ldy #0
    lda NRCHARS
    cmp #4
    beq @parse4
    cmp #2
    beq @parse2
    jmp @error
@parse4:
    lda CHAR1,y
    iny
    ldx CHAR1,y
    iny
    jsr char2num
    sta BUF3
@parse2:
    lda CHAR1,y
    iny
    ldx CHAR1,y
    iny
    jsr char2num
    sta BUF2
    jmp @exit
@error:
    sec
    rts
@exit:
    clc
    rts

;-------------------------------------------------------------------------------
; GETOPTCODE
;
; BUF4:5 : pointer to mnemonic dataset
; X      : mode (will be stored in BUF6)
;
; Output:
; BUF6: mode
; BUF7: opt code
;-------------------------------------------------------------------------------
getoptcode:
    ldy #0
    stx BUF6                ; store mode in BUF6
    stz BUF7                ; use BUF7 as counter
@next:
    lda (BUF4),y
    cmp #$FF                ; check if end of dataset?
    beq @error
    cmp BUF6                ; check addressing mode
    beq @found
    lda BUF4                ; if not found, increment pointer by 2
    clc
    adc #2
    sta BUF4
    lda BUF5
    adc #0
    sta BUF5
    inc BUF7
    jmp @next
@found:
    iny
    lda (BUF4),y            ; load result in A
    clc                     ; clear carry
    jmp @exit
@error:
    lda BUF6
    cmp #$00                ; was addressing mode perhaps implied?
    beq @try04              ; try accumulator
    cmp #$0A                ; was addressing mode zero-page?
    beq @try09              ; try relative
    jmp @unknown
@try04:
    ldx #$04                ; try again for accumulator
    jmp @reset
@try09:
    ldx #$09
@reset:
    lda BUF7                ; grab counter
    asl                     ; multiply by 2
    sta BUF7                ; store back in 7
    sec                     ; reset buffer to initial state
    lda BUF4                ; load lower byte
    sbc BUF7                ; decrement count
    sta BUF4                ; store lower byte
    lda BUF5                ; load lower byte
    sbc #0                  ; apply any borrow
    sta BUF5                ; store upper byte
    jmp getoptcode
@unknown:
    sec                     ; set carry
    lda #00                 ; reset A
@exit:
    sta BUF7                ; store optcode (A) in BUF7
    rts

;-------------------------------------------------------------------------------
; CLEARBUFFER routine
;
; Clear the command buffer
;-------------------------------------------------------------------------------
clearbuffer:
    stz CMDLENGTH           ; zero the buffer length
    ldy #0                  ; set counter
    lda #0                  ; set value
@next:
    sta CMDBUF,y            ; write to command buffer
    iny                     ; increment
    cpy #$10                ; check whether all cells are written
    bne @next               ; if not, go to next byte
    rts

;-------------------------------------------------------------------------------
; ISHEX routine
;
; Checks whether value in register A is hex
;-------------------------------------------------------------------------------
ishex:
    cmp #$30      
    bcc @not_hex_digit
    cmp #$3A      
    bcc @is_hex_digit
    cmp #$41      
    bcc @not_hex_digit
    cmp #$47      
    bcc @is_hex_digit
@not_hex_digit:
    sec
    jmp @done
@is_hex_digit:
    clc
@done:
    rts
