;-------------------------------------------------------------------------------
; MAIN MONITOR
;-------------------------------------------------------------------------------

.include "constants.inc"
.include "functions.inc"
.include "disassemble.inc"
.include "assemble.inc"
.include "sdcard.inc"

.export boot
.export clearcmdbuf

.segment "BOOT"

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
    jsr getchar
    cmp #0
    beq loop
    jsr chartoupper     ; always convert character to upper case
    cmp #$0D            ; check for carriage return
    beq exec
    cmp #$7F            ; check for delete key
    beq backspace

    ldx CMDLENGTH       ; load command length
    cpx #$10
    beq exitloop        ; refuse to store when maxbuffer
    jsr ischarvalid     ; check if character is an alphanumerical character
    bcs loop
    sta CMDBUF,x        ; store in position
    jsr putchar         ; if not, simply print character
    inc CMDLENGTH       ; increment command length
exitloop:
    jmp loop

; user has pressed RETURN: try to interpret command execute it
exec:
    jsr parsecmd        ; parse the command
    jsr clearcmdbuf     ; clean the command line buffer
    jsr newcmdline      ; provide new command line
    jmp loop

; user has pressed backspace: remove character from command buffer
backspace:
    lda CMDLENGTH       ; skip if buffer is empty
    beq exitbp
    lda #$08
    jsr putchar
    lda #' '
    jsr putchar
    lda #$08
    jsr putchar
    dec CMDLENGTH
exitbp:
    jmp loop

;-------------------------------------------------------------------------------
; PARSECMD routine
;
; Parses the command buffer and executes the command based on the buffer
;-------------------------------------------------------------------------------
parsecmd:
    ldx #00
    lda CMDBUF,x
    cmp #'M'
    beq cmdmenufar      ; show the menu?
    cmp #'G'
    beq cmdrunfar       ; run program?
    cmp #'W'
    beq cmdwritefar     ; write to memory?
    cmp #'R'
    beq cmdreadfar      ; read memory?
    cmp #'D'
    beq cmddisfar       ; disassemble memory?
    cmp #'A'
    beq cmdasmfar       ; disassemble memory?
    cmp #'S'
    beq cmdsdfar        ; test SD-card
    cmp #'P'
    beq cmdprintnumfar  ; test printing numbers
    rts

;-------------------------------------------------------------------------------
; ERRORHEX routine
;
; Print error message when unable to convert hex
;-------------------------------------------------------------------------------
errorhex:
    jsr newline
    lda #>@errorstr
    ldx #<@errorstr
    jsr putstr
    rts

@errorstr:
    .asciiz "Error parsing hex address"

; jump table because instructions lie further in memory than +/- 128 bytes
cmdrunfar:
    jmp cmdrun

cmdmenufar:
    jmp cmdshowmenu

cmdreadfar:
    inx
    jsr hex4tostart
    bcs exit_invalid
    jmp cmdread

cmdwritefar:
    inx
    jsr hex4tostart
    bcs exit_invalid
    jmp cmdwrite

cmddisfar:
    inx
    jsr hex4tostart
    bcs exit_invalid
    jsr newline
    jmp disassemble

cmdasmfar:
    inx
    jsr hex4tostart
    bcs exit_invalid
    jsr newline
    jmp assemble

; change ram bank
cmdchrambank:
    rts
@str:
    .asciiz "Changing RAM bank to: "

cmdsdfar:
    jmp cmdtestsdcard

cmdprintnumfar:
    jsr printnumtest
    rts

exit_invalid:
    rts

cmdtestsdcard:
    jsr newline
    lda #>@str
    ldx #<@str
    jsr putstr
    jsr newline
    ldx #0              ; attempt counter
@tryagain:
    phx                 ; push attempt counter onto stack
    jsr init_sd         ; open SD-card
    jsr sdcmd00
    bcs @fail
    jsr sdcmd08
    bcs @fail
    jsr sdacmd41
    bcs @fail
    jsr sdcmd58
    bcs @fail
    jsr sdcmd17
    jsr close_sd
    lda #>@attemptstr
    ldx #<@attemptstr
    jsr putstr
    pla                 ; retrieve attempt counter
    inc
    jsr puthex
    rts
@fail:
    plx                 ; retrieve counter
    inx                 ; increment attempt counter
    cpx #5              ; make 5 attempts to open SD-card
    bne @tryagain       ; if not 5, try again
    lda #>@errorstr
    ldx #<@errorstr
    jsr putstr          ; print error string
    jsr close_sd
    rts
@str:
    .asciiz "Testing SDCARD routines."
@errorstr:
    .asciiz "Failed to open SDCARD."
@attemptstr:
    .asciiz "Attempts required: "

cmdgetpos:
    jsr getpos
    rts

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
; HELLOWORLD routine
;
; Prints helloworld to the screen
;-------------------------------------------------------------------------------
helloworldtest:
    jsr newline
    lda #>@str
    ldx #<@str
    jsr putstrnl
    rts
@str:
    .asciiz "Hello World!"

;-------------------------------------------------------------------------------
; HEX4TOSTART routine
;
; Try to set STARTADDR by reading 4 hex characters from command buffer
;-------------------------------------------------------------------------------
hex4tostart:
    jsr hex4
    bcs @error
    lda BUF2
    sta STARTADDR+1
    lda BUF3
    sta STARTADDR
    rts
@error:
    jmp errorhex

;-------------------------------------------------------------------------------
; CMDSHOWMENU routine
;
; Print user menu
;-------------------------------------------------------------------------------
cmdshowmenu:
    jsr newline
    lda #>@str
    ldx #<@str
    jsr putstr
    rts

@str:
    .byte LF,"Commands:",LF,LF
    .byte "  R<XXXX>[:<XXXX>]    read memory ",LF
    .byte "  W<XXXX>             write to memory",LF
    .byte "  G<XXXX>             run from address",LF
    .byte "  D<XXXX>             disassemble from address",LF
    .byte "  M                   show this menu",LF
    .byte 0

;-------------------------------------------------------------------------------
; CMDRUN routine
;
; run program starting at address
;-------------------------------------------------------------------------------
cmdrun:
    inx                 ; increment read pointer
    jsr hex4
    bcs @error
    lda BUF2            ; load high byte
    sta BUF4            ; store after low byte
    jsr newline         ; print new line
    jmp (BUF3)          ; go to address

@error:
    jmp errorhex

;-------------------------------------------------------------------------------
; CMDREAD routine
;
; Read memory and print contents to the screen
;-------------------------------------------------------------------------------
cmdread:
    lda CMDBUF,x
    cmp #':'
    bne @skip
    inx
    jsr hex4
    bcs @error
    lda BUF2            ; load high byte
    sta ENDADDR+1       ; store in memory
    lda BUF3            ; load low byte
    sta ENDADDR         ; store in memory
    jmp @hexdump
@skip:
    clc
    lda STARTADDR
    adc #$0F
    sta ENDADDR
    lda STARTADDR+1
    adc #0
    sta ENDADDR+1
@hexdump:
    jsr hexdump
    rts

@error:
    jmp errorhex

;-------------------------------------------------------------------------------
; CMDWRITE routine
;
; Quasi-interactive write function
;-------------------------------------------------------------------------------
cmdwrite:
    jsr newline
    lda #>@str
    ldx #<@str
    jsr putstr
@newline:
    jsr newline
    jsr puttab
    lda STARTADDR+1     ; load high byte
    jsr puthex
    lda STARTADDR       ; load low byte
    jsr puthex
    lda #':'
    jsr putchar
    ldy #0              ; value counter; increments till 16, then newline
    jmp @nexthex
@loop:
    jsr getchar
    cmp #0
    beq @loop
    cmp #$0D            ; check for enter
    beq @exit
    jsr chartoupper
    jsr putchar
    sta BUF2,y
    iny
    cpy #2              ; check if two chars have been read
    bne @loop           ; if not, read another char
    lda BUF2            ; load upper byte in A
    ldx BUF3            ; load lower byte in X
    jsr char2num        ; try to convert value
    bcs @error          ; handle error
    ply                 ; retrieve value counter
    sta (STARTADDR),y   ; store in memory
    iny
    cpy #16             ; check if 16 values have been read
    bne @nexthex
    lda STARTADDR       ; load low byte
    clc                 ; clear carry
    adc #16
    sta STARTADDR
    lda STARTADDR+1     ; load high byte
    adc #0              ; increment
    sta STARTADDR+1
    ldy #0              ; reset counter
    jmp @newline
@nexthex:
    phy                 ; put value counter on stack
    lda #' '
    jsr putchar
    ldy #0              ; reset chararacter counter
    jmp @loop
@exit:
    ply                 ; clean stack
    rts
@error:
    ply                 ; clean stack
    jmp errorhex

@str:
    .asciiz " > Enabling WRITE MODE. Enter HEX values. Hit RETURN to quit."

;-------------------------------------------------------------------------------
; HEX4 routine
;
; Try to convert 4 characters to a 16 bit hexadecimal address
; Store high byte in BUF2 and low byte in BUF3.
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
    lda CMDBUF,x        ; load high byte
    tay
    inx
    lda CMDBUF,x        ; load low byte
    tax
    tya
    jsr char2num
    plx
    rts

;-------------------------------------------------------------------------------
; PRINTNUMTEST routine
;
; Simple test to check whether numbers are correctly printed
;-------------------------------------------------------------------------------
printnumtest:
    lda #$46
    ldx #$46
    jsr char2num
    jsr puthex
    jsr newline
    lda #0
@next:
    jsr putdec          ; a is conserved
    jsr newline
    inc                 ; increment acc
    cmp #26             ; only print until (and including) 25
    bne @next
    lda #30             ; load 30
    jsr putdec
    jsr newline
    lda #40
@next2:
    jsr putdec          ; start printing from 30 with increments of 10
    jsr newline
    clc
    adc #10
    cmp #120
    bne @next2
    rts

;-------------------------------------------------------------------------------
; HEXDUMP routine
;
; Uses BUF2, BUF1 is used by PUTHEX routine
;-------------------------------------------------------------------------------
hexdump:
    ; setup variables
    ;lda STARTADDR       ; load low byte start address (ignored)
    stz MALB            ; ignore low byte
    lda STARTADDR+1     ; load high byte
    sta MAHB            ; store high byte
    stz BUF2

    ; check if 6th command character is ":", if so, only print 16 lines
    lda CMDBUF+5
    cmp #':'
    bne @skiplinecalc

    ; check if command length is exactly 10, if not, only print 16 lines
    ; starting from the STARTADDR
    lda CMDLENGTH
    cmp #10
    bne @skiplinecalc

    ; calculate the number of lines to be printed
    sec                 ; set carry flag before starting subtraction
    lda ENDADDR         ; load low byte of end address
    sbc STARTADDR       ; subtract low byte of end address
    sta NRLINES
    lda ENDADDR+1       ; load high byte
    sbc STARTADDR+1     ; subtract low byte
    sta NRLINES+1

    ; divide the result by 16, which is the number of lines that are going
    ; to be printed
    and #$0F            ; take low nibble to transfer to low byte
    asl                 ; shift left by 4
    asl
    asl
    asl
    sta BUF1            ; store temporarily
    lda NRLINES         ; load low nibble
    lsr
    lsr
    lsr
    lsr
    ora BUF1            ; place upper nibble
    sta NRLINES         ; store in low byte
    lda NRLINES+1
    lsr
    lsr
    lsr
    lsr
    sta NRLINES+1       ; store
    jmp @nextline
@skiplinecalc:
    lda #1
    sta BUF2
    stz NRLINES+1       ; high byte
    lda #15
    sta NRLINES         ; store number of lines low byte
@nextline:
    lda MALB
    cmp #00
    bne @skipheader
    jsr printheader
@skipheader:
    lda MAHB            ; load high byte of memory address
    jsr puthex          ; print it
    lda MALB            ; load low byte of memory address
    jsr puthex          ; print it
    lda #' '            ; load space
    jsr putchar         ; print it twice
    jsr putchar
    ldy #0              ; number of bytes to print (second segment)
@nextbyte:
    phy                 ; put y on stack as puthex garbles it
    lda (MALB),y        ; load byte
    jsr puthex          ; print byte in hex format, garbles y
    lda #' '            ; add space
    jsr putchar
    ply                 ; restore y from stack
    iny
    cpy #8              ; check if halfway
    bne @skip           ; if not, skip
    lda #' '            ; print two spaces to seperate 8 bit segments
    jsr putchar
    jsr putchar
@skip:
    cpy #16             ; check if 16 bytes are printed
    bne @nextbyte       ; if not, next byte
    lda #' '            ; else space
    jsr putchar
    lda #'|'            ; add nice delimeter
    jsr putchar
    ldy #0              ; number of bytes to print (third segment)
@nextchar:
    phy                 ; y will be garbed in putchar routine
    lda (MALB),y        ; load byte again
    cmp #$20            ; check if value is less than $20
    bcc @printdot       ; if so, print a dot
    cmp #$7F            ; check if value is greater than or equal to $7F
    bcs @printdot       ; if so, print a dot
    jmp @next
@printdot:
    lda #'.'            ; load dot character
@next:
    jsr putchar         ; print character
    ply                 ; restore y
    iny
    cpy #16             ; check if 16 characters have been consumed
    bne @nextchar       ; if not, next character
    lda #'|'            ; else print terminating char
    jsr putchar
    lda MALB            ; load low byte of monitor address
    clc                 ; prepare for add (clear carry)
    adc #16             ; add 16
    sta MALB            ; store in low byte
    lda MAHB            ; load high byte
    adc #0              ; add with carry (if there is a carry)
    sta MAHB            ; store back in high byte
    lda NRLINES
    ora NRLINES+1
    beq @endlines       ; if zero, then exit, else decrement
    lda NRLINES
    sec                 ; set carry flag for subtraction
    sbc #1              ; subtract 1 from low byte of NRLINES
    sta NRLINES         ; store
    bcs @nextlinefar    ; if carry set, no borrow and continue
    dec NRLINES+1       ; else, also decrement high byte
@nextlinefar:
    jsr newline
    jmp @nextline
@endlines:
    ora BUF2
    bne @askcontinue
    rts
@askcontinue:
    jsr newline
    lda #>@contstr
    ldx #<@contstr
    jsr putstr
@trychar:
    jsr getchar
    cmp #00
    beq @trychar
    cmp #'Q'
    beq @clearexit
    cmp #'q'
    beq @clearexit
    lda #15
    sta NRLINES
    stz NRLINES+1
    jsr clearline
    jmp @nextline
@clearexit:
    jsr clearline
    rts

@contstr:
    .asciiz " -- Press q to quit or any other key to continue --"


;-------------------------------------------------------------------------------
; PRINTHEADER routine
;
; Print header row
;-------------------------------------------------------------------------------
printheader:
    jsr newline
    ldx #6
    lda #' '
@nextspace:
    jsr putchar
    dex
    bne @nextspace
    ldx #0
@nextchar:
    txa
    jsr puthex
    lda #' '
    jsr putchar
    inx
    cpx #8
    beq @addspace
    cpx #16
    bne @nextchar
    jsr newline
    rts
@addspace:
    lda #' '
    jsr putchar
    jsr putchar
    jmp @nextchar
